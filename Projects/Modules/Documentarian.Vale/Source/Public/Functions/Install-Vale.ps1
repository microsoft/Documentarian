# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/ValeInstallScope.psm1

function Install-Vale {
  [CmdletBinding()]
  [OutputType([System.IO.FileInfo])]
  param(
    [string]$Version = 'latest',
    [ValeInstallScope]$Scope = [ValeInstallScope]::Workspace,
    [switch]$PassThru
  )

  begin {
    $ApiUrlBase = 'https://api.github.com/repos/errata-ai/vale/releases'
    $OSArchitecture = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
    $Architecture = switch ($OSArchitecture) {
      X64 { '64-bit' }
      Arm64 { 'arm64' }
      default {
        $Message = @(
          "No Vale release available for this CPU architecture ($OSArchitecture)."
          'Vale is packaged for x64 and ARM64 only.'
        ) -join ' '
        throw $Message
      }
    }

    $OS = if ($IsLinux) {
      'Linux'
    } elseif ($IsMacOS) {
      'macOS'
    } elseif ($Architecture -eq 'arm64') {
      throw 'Detected ARM64 architecture for Windows; Vale does not release for this platform.'
    } else {
      'Windows'
    }
    $Extension = $OS -eq 'Windows' ? '.zip' : '.tar.gz'

    $PackageNamePattern = "vale_\d+\.\d+\.\d+_${OS}_${Architecture}${Extension}"
    $ChecksumNamePattern = '_checksums.txt$'

    $BaseInstallPath = if ($Scope -eq 'User') {
      Get-Item -Path ~
    } else {
      Get-Location
    }
    $InstallFolderPath = Join-Path -Path $BaseInstallPath -ChildPath '.vale'
    $TempFolderPath = Join-Path -Path 'Temp:' -ChildPath (New-Guid).Guid
    $ArchiveFilePath = Join-Path -Path $TempFolderPath -ChildPath "vale${Extension}"
  }

  process {
    Write-Verbose "Detected Operating System: $OS"
    Write-Verbose "Detected CPU Architecture: $Architecture"

    $ApiUrl = if ($Version -eq 'latest') {
      Write-Verbose 'Checking for latest version...'
      $ApiUrlBase, $Version.ToLowerInvariant() | Join-String -Separator '/'
    } else {
      $ApiUrlBase, 'tags', $Version | Join-String -Separator '/'
    }

    try {
      $Release = Invoke-RestMethod -Uri $ApiUrl -Verbose:$false
    } catch {
      throw "Unable to retrieve vale from GitHub at version: $Version"
    }

    Write-Verbose "Downloading vale at version $($Release.name)..."

    $PackageAsset = $Release.Assets | Where-Object -Property name -Match $PackageNamePattern
    $ChecksumAsset = $Release.Assets | Where-Object -Property name -Match $ChecksumNamePattern

    $null = New-Item -Path $TempFolderPath -ItemType Directory

    Invoke-WebRequest -Uri $PackageAsset.browser_download_url -OutFile $ArchiveFilePath -Verbose:$false

    # Now that the archive exists, we need to grab the real path to it, as Temp:\ is a PSDrive.
    $ArchiveFilePath = Get-Item -Path $ArchiveFilePath | Select-Object -ExpandProperty FullName

    Write-Verbose 'Verifying package checksum...'

    $PackageChecksum = (Get-FileHash -Path $ArchiveFilePath).Hash.Trim()
    $ExpectedChecksum = Invoke-WebRequest -Uri $ChecksumAsset.browser_download_url -ContentType $ChecksumAsset.content_type -Verbose:$false
    | Select-Object -ExpandProperty RawContent
    | ForEach-Object {
      $ChecksumLine = ($_ -split '\r?\n') -match $PackageNamePattern
      $ChecksumLine -split '\s' | Select-Object -First 1
    }
    Write-Verbose "Expected checksum: $ExpectedChecksum"
    Write-Verbose "Package checksum:  $PackageChecksum"

    if ($ExpectedChecksum -ne $PackageChecksum) {
      throw "Downloaded package checksum '$PackageChecksum' did not match expected checksum '$ExpectedChecksum'"
    }

    if (Test-Path -Path $InstallFolderPath) {
      Write-Verbose "Overriding existing Vale install in '$InstallFolderPath'..."
    } else {
      $null = New-Item -ItemType Directory -Path $InstallFolderPath
    }

    Write-Verbose "Expanding archive '$ArchiveFilePath'..."
    if ($Extension -eq '.zip') {
      Expand-Archive -Path $ArchiveFilePath -DestinationPath $InstallFolderPath -Force
    } else {
      tar -xvf $ArchiveFilePath -C $InstallFolderPath
    }

    $InstalledBinary = Get-Item -Path "$InstallFolderPath\vale*"
    Write-Verbose "Installed vale to '$($InstalledBinary.FullName)'"

    Write-Verbose "Cleaning up temp folder '$TempFolderPath'"
    Remove-Item -Path $TempFolderPath -Recurse -Force

    if ($PassThru) {
      $InstalledBinary
    }
  }
}
