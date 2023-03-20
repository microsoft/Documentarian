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
  [OutputType([hashtable])]
  [OutputType([String])]
  param(
    [parameter(Mandatory)]
    [string[]]$ArgumentList
  )

  begin {
    $Vale = Get-Vale
    $Patterns = @{
      MissingConfigFile   = "\[--config\] Runtime error\s+path '(?<ConfigPath>[^']+)' does not exist"
      MissingStyleFolder  = "The path '(?<StylePath>[^']+)' does not exist"
      InvalidFlag         = 'unknown flag:\s(?<FlagName>.+)$'
      InvalidGlobalOption = 'is a syntax-specific option'
    }
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
            if ($Result.Text -match $Patterns.MissingStyleFolder) {
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
            } elseif ($Result.Text -match $Patterns.InvalidGlobalOption) {
              $Message = @(
                "Invalid value at '$($Result.Path):$($Result.Line):$($Result.Span)'."
                $Result.Text
              ) -join ' '
              $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                ([System.Runtime.Serialization.SerializationException]$Message),
                'Vale.InvalidConfigurationValue',
                [System.Management.Automation.ErrorCategory]::InvalidData,
                ($ArgumentList -join ' ')
              )

              $PSCmdlet.ThrowTerminatingError($ErrorRecord)
            } else {
              $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
              ([System.Exception]$_),
                'Vale.UnhandledError',
                [System.Management.Automation.ErrorCategory]::FromStdErr,
              ($ArgumentList -join ' ')
              )

              $PSCmdlet.WriteError($ErrorRecord)
            }
          }
          # E100 is the code for unexpected errors in Vale
          'E100' {
            if ($Result.Text -match $Patterns.MissingConfigFile) {
              $Message = @(
                'Specified Vale configuration file'
                "'$($Matches.ConfigPath)'"
                "doesn't exist."
              ) -join ' '

              $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                ([System.IO.FileNotFoundException]$Message),
                'Vale.ConfigurationFileNotFound',
                [System.Management.Automation.ErrorCategory]::ResourceUnavailable,
                ($ArgumentList -join ' ')
              )

              $PSCmdlet.ThrowTerminatingError($ErrorRecord)
            }

            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
              ([System.Exception]$_),
              "Vale.$($Result.Code)",
              [System.Management.Automation.ErrorCategory]::FromStdErr,
              ($ArgumentList -join ' ')
            )

            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
          }

          # Indicates there was a completely unhandled error.
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
        if ($ValeErrors -match $Patterns.InvalidFlag) {
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
      # Sync doesn't return any stdout, only progress that we can't capture
      # usefully anyway. This check is naive, but should work as long as there
      # is no other bare-argument 'sync' included.
      if ('sync' -in $ArgumentList) {
        return ''
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
