function Test-Dependency {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory, ParameterSetName = 'Executable')]
    [hashtable] $Executable,

    [Parameter(Mandatory, ParameterSetName = 'Module')]
    [hashtable] $Module,

    [switch]$Detailed
  )

  process {
    if ($Module) {
      $HasVersionRange = !($Module.Keys -match 'Version')
      $ValidVersions = Get-Module -ListAvailable -Name $Module.Name -Verbose:$false
      | Where-Object -FilterScript {
        if ($HasVersionRange) {
          return $true
        }

        if ($Module.MinimumVersion -and ($_.Version -lt $Module.MinimumVersion)) {
          return $false
        }

        if ($Module.MaximumVersion -and ($_.Version -gt $Module.MaximumVersion)) {
          return $false
        }

        $true
      }

      $Prefix = "Dependency module '$($Module.Name)' is"
      if ($ValidVersions) {
        Write-Verbose "$Prefix available with $($ValidVersions.Count) version(s)."
        return $Detailed ? $ValidVersions : $true
      } else {
        if ($HasVersionRange) {
          Write-Verbose "Keys: $($Module.Keys)"
          $VersionRange = 'any'
        } else {
          $VersionRange += $Module.MinimumVersion ? $Module.MinimumVersion.ToString() : '0.0.1'
          $VersionRange += ' to '
          $VersionRange += $Module.MaximumVersion ? $Module.MaximumVersion.ToString() : 'any'
        }

        Write-Warning "$Prefix not available in version range: $VersionRange"
        return $false
      }
    } elseif ($Executable) {
      $SearchParameters = @{
        Name        = $Executable.Name
        CommandType = 'Application'
        ErrorAction = 'SilentlyContinue'
        OutVariable = 'AvailableExecutables'
      }
      $null = Get-Command @SearchParameters

      $Name = $Executable.DisplayName ? $Executable.DisplayName : $Executable.Name
      $Prefix = "Dependency executable '$($Name)' is"
      if ($AvailableExecutables) {
        Write-Verbose "$Prefix available at paths:`n`t$($AvailableExecutables.Source -join "`n`t")"
        return $Detailed ? $AvailableExecutables : $true
      } else {
        Write-Warning "$Prefix not available locally"
        return $false
      }
    }
  }
}
