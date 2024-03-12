# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Test-HelpInfoUri {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'ByName')]
        [string[]]$Module,

        [Parameter(ValueFromPipeline, ParameterSetName = 'ByObject')]
        [object]$InputObject,

        [string]$OutPath
    )

    begin {
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            throw 'This function requires PowerShell 7 or higher'
        }
        # Used for short-circuiting checks against already-checked modules
        $TestedModules = @()
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ByObject') {
            # We can infer the Module from the input object. If it's a
            # CommandInfo, it might have the module info or name. If it's
            # a PSModuleInfo, use it. Otherwise, cast to string.
            foreach ($Object in $InputObject) {
                switch ($Object) {
                    { $_ -is [System.Management.Automation.CommandInfo] } {
                        if ($Object.Module) {
                            $Module = $Object.Module
                        } elseif ($Object.ModuleName) {
                            $Module = $Object.ModuleName
                        } else {
                            $Module = $Object.ToString()
                        }
                    }

                    { $_ -is [PSModuleInfo] } {
                        $Module = $Object
                    }

                    default {
                        $Module = $Object.ToString()
                    }
                }
            }
        }

        # Don't bother searching the same module more than
        # once since we always check latest version
        $Module = $Module | Select-Object -Unique

        foreach ($modname in $Module) {
            # To support pipeline, skip if a module has already
            # been tested, otherwise add to the test list.
            if ($modname -in $TestedModules) {
                continue
            } else {
                $TestedModules += $modname
            }

            $output = [pscustomobject]@{
                Module  = $modname
                Code    = $null
                Message = $null
            }

            $mod = Get-Module -Name $modname -ListAvailable | Select-Object -First 1

            # If the input wasn't a module, return the failed result immediately
            if ($null -eq $mod) {
                $output.Message = 'Module not found'
                $output.Code = 0x2
                $output
                continue
            }

            # If the input was a module, we have the component parts needed to check it
            Write-Verbose "$($mod.Name) - $($mod.Guid) - $($mod.HelpInfoUri)"
            $output.Module = $mod.Name

            # If the module doesn't have a HelpInfoUri, we know it can't be reached
            if ($null -eq $mod.HelpInfoUri) {
                $output.Message = 'HelpInfoUri is null or empty'
                $output.Code = 0x0000138f
                $output
                continue
            }

            # Resolve the URI from the manifest, which may include redirection.
            try {
                # If successful, then the URI probably points to a browsable directory
                $response = Invoke-WebRequest -Uri $mod.HelpInfoUri -ErrorAction Stop
                continue
            } catch {
                if ($_.Exception.Response.StatusCode.value__ -ne 404) {
                    # If the response is anything other than 404, then the URI is probably invalid
                    $output.Code = $_.Exception.Response.StatusCode.value__
                    $output.Message = $_.Exception.Response.StatusCode
                    $output
                    continue
                } else {
                    # If the response is 404, then the URI is probably valid, especially when
                    # hosted in an Azure blobstore. You can't browse to the URI, but you can
                    # download the file using a fully qualified URI to the file. A true 404 problem
                    # will be caught later.
                    $baseUri = $_.TargetObject.RequestUri.AbsoluteUri
                }
            }

            # Construct the URI: the last segment is always <Name>_<Guid>_HelpInfo.xml
            $HelpInfoUri = [uri]($baseUri, $mod.Name, '_', $mod.Guid, '_HelpInfo.xml' -join '')
            Write-Verbose "HelpInfoUri: $HelpInfoUri"

            # Try to get the HelpInfo.xml to determine validity
            try {
                $params = @{
                    Uri         = $HelpInfoUri
                    Method      = 'Get'
                    ErrorAction = 'Stop'
                }
                if ($OutPath) {
                    $params.Add(
                        'OutFile',
                        (Join-Path -Path $OutPath -ChildPath $HelpInfoUri.Segments[-1])
                    )
                }
                $response = Invoke-WebRequest @params
                $output.Code = $response.StatusCode
                $output.Message = 'HelpInfoUri is valid'
                $output
            } catch {
                $output.Code = $_.Exception.Response.StatusCode.value__
                $output.Message = $_.Exception.Response.StatusCode
                $output
            }
        }
    }
}
