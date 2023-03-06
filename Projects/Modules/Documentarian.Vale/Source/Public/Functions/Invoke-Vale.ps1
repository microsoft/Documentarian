# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/Get-Vale.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Invoke-Vale {
  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  [OutputType([String])]
  param(
    [parameter(Mandatory)]
    [string[]]$ArgumentList
  )

  begin {
    $Vale = Get-Vale
  }

  process {
    if ($ArgumentList.Count -eq 0) {
      Write-Verbose 'No arguments specified for Vale, returning null'
      return $null
    }

    if ("$ArgumentList" -notmatch '--output json') {
      $ArgumentList += @('--output', 'JSON')
    }

    $RawResult = & $Vale @ArgumentList 2>&1

    $ValeErrors = $RawResult | Where-Object -FilterScript {
      $_ -is [System.Management.Automation.ErrorRecord]
    } | ForEach-Object -Process { $_.Exception.Message } | Join-String -Separator "`n"

    $ValeOutput = $RawResult | Where-Object -FilterScript {
      $_ -is [String]
    } | Join-String -Separator "`n"

    if ($ValeErrors) {
      try {
        $Result = $ValeErrors | ConvertFrom-Json -ErrorAction Stop
        switch ($Result.Code) {
          # E201 is the code for "well-known" error types from Vale
          'E201' {
            if ($Result.Text -match "The path '(?<StylePath>[^']+)' does not exist") {
              $StylePath = $Matches.StylePath
              $Message = @(
                "Vale styles not synced to '$StylePath'"
                "as expected by the configuration in '$($Result.Path)';"
                'run Sync-Vale to download them.'
              ) -join ' '

              $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                ([System.IO.DirectoryNotFoundException]$Message),
                'Vale.StylePathNotFound',
                [System.Management.Automation.ErrorCategory]::ResourceUnavailable,
                ($ArgumentList -join ' ')
              )

              $PSCmdlet.ThrowTerminatingError($ErrorRecord)
            }
          }
          # E100 is the code for unexpected errors in Vale
          'E100' {
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
              ([System.Exception]$_),
              "Vale.$($Result.Code)",
              [System.Management.Automation.ErrorCategory]::FromStdErr,
              ($ArgumentList -join ' ')
            )

            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
          }
          default {
            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
              ([System.Exception]$_),
              'Vale.UnhandledError',
              [System.Management.Automation.ErrorCategory]::FromStdErr,
              ($ArgumentList -join ' ')
            )

            $PSCmdlet.WriteError($ErrorRecord)
          }
        }
      } catch [System.ArgumentException] {
        # If we're in this catch, it's because there were non-JSON errors.
        # These can only be checked by parsing the stderr strings.
        if ($ValeErrors -match 'unknown flag:\s(?<FlagName>.+)$') {
          $FlagName = $Matches.FlagName
          $Message = "Invalid flag '$FlagName' passed to Vale."

          $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
            ([System.ArgumentException]$Message),
            'Vale.InvalidFlag',
            [System.Management.Automation.ErrorCategory]::InvalidArgument,
            ($ArgumentList -join ' ')
          )

          $PSCmdlet.ThrowTerminatingError($ErrorRecord)
        }

        $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
            ([System.Exception]$ValeErrors),
          'Vale.UnhandledError',
          [System.Management.Automation.ErrorCategory]::FromStdErr,
            ($ArgumentList -join ' ')
        )

        $PSCmdlet.WriteError($ErrorRecord)
      }
    }

    # At this point, any errors have been handled and we can try converting the
    # stdout from json to object. If this fails, it's because Vale hasn't
    # implemented a JSON output for the command or subcommand.
    try {
      $Result = $ValeOutput | ConvertFrom-Json -Depth 99 -AsHashtable
    } catch [System.ArgumentException] {
      # Version is a basic string, even with '--output JSON'
      if ($ArgumentList -contains '-v' -or $ArgumentList -contains '--version') {
        return $ValeOutput
      }
      # Help is a basic string, even with '--output JSON'
      if ($ArgumentList -contains '-h' -or $ArgumentList -contains '--help') {
        return $ValeOutput
      }

      # If something else happened, we need to throw an error on invalid result
      $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
        ([System.Exception]$_),
        'Vale.InvalidResult',
        [System.Management.Automation.ErrorCategory]::InvalidResult,
        ($ArgumentList -join ' ')
      )
      $PSCmdlet.ThrowTerminatingError($ErrorRecord)
    }

    return $Result
  }
}
