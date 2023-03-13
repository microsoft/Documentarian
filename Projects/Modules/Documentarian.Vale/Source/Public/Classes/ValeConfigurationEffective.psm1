# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./ValeConfigurationIgnore.psm1
using module ./ValeConfigurationFormatTypeAssociation.psm1
using module ./ValeConfigurationFormatLanguageAssociation.psm1
using module ./ValeConfigurationFormatTransform.psm1
using module ../Enums/ValeAlertLevel.psm1


class ValeConfigurationEffective {
    [ValeConfigurationIgnore[]]
    $BlockIgnores
    [string[]]
    $Checks
    [ValeConfigurationFormatTypeAssociation[]]
    $FormatTypeAssociations
    [hashtable]
    $AsciidoctorAttributes       # A set of key-value pairs for `Asciidoctor` attributes
    [ValeConfigurationFormatLanguageAssociation[]]
    $FormatLanguageAssociations
    [string[]]
    $GlobalBaseStyles  # Maps to `GBaseStyles`
    [hashtable]
    $GlobalChecks      # Maps to `GChecks`
    [string[]]
    $IgnoredClasses
    [string[]]
    $IgnoredScopes
    [ValeAlertLevel]
    $MinimumAlertLevel # Maps to `MinAlertLevel`
    [string[]]
    $Vocabularies
    [hashtable]
    $RuleToLevel
    [hashtable]
    $SyntaxBaseStyles  # Maps to `SBaseStyles`
    [hashtable]
    $SyntaxChecks      # Maps to `SChecks`
    [string[]]
    $SkippedScopes
    [ValeConfigurationFormatTransform[]]
    $FormatTransformationStylesheets
    [string]
    $StylesPath
    [ValeConfigurationIgnore[]]
    $TokenIgnores
    [string]
    $WordTemplate
    [string]
    $RootIniPath
    [string]
    $DictionaryPath
    [string]
    $NlpEndpoint

    ValeConfigurationEffective() {}

    ValeConfigurationEffective([hashtable]$Info) {
        $Info.BlockIgnores.GetEnumerator() | ForEach-Object -Process {
            $this.BlockIgnores += [ValeConfigurationIgnore]@{
                GlobPattern    = $_.Key
                IgnorePatterns = $_.Value
            }
        }

        $this.Checks = $Info.Checks

        $Info.Formats.GetEnumerator() | ForEach-Object -Process {
            $this.FormatTypeAssociations += [ValeConfigurationFormatTypeAssociation]@{
                ActualFormat    = $_.Key
                EffectiveFormat = $_.Value
            }
        }

        $this.AsciidoctorAttributes = $Info.Asciidoctor

        $Info.FormatToLang.GetEnumerator() | ForEach-Object -Process {
            $this.FormatLanguageAssociations += [ValeConfigurationFormatLanguageAssociation]@{
                GlobPattern = $_.Key
                LanguageID  = $_.Value
            }
        }

        $this.GlobalBaseStyles = $Info.GBaseStyles
        $this.GlobalChecks = $Info.GChecks
        $this.IgnoredClasses = $Info.IgnoredClasses
        $this.IgnoredScopes = $Info.IgnoredScopes
        $this.MinimumAlertLevel = [ValeAlertLevel]($Info.MinAlertLevel)
        $this.Vocabularies = $Info.Vocab

        $this.SyntaxBaseStyles = $Info.SBaseStyles
        $this.SyntaxChecks = $Info.SChecks
        $this.SkippedScopes = $Info.SkippedScopes

        $Info.Stylesheets.GetEnumerator() | ForEach-Object -Process {
            $this.FormatTransformationStylesheets += [ValeConfigurationFormatTransform]@{
                GlobPattern = $_.Key
                Path        = $_.Value
            }
        }

        $this.StylesPath = $Info.StylesPath

        $Info.TokenIgnores.GetEnumerator() | ForEach-Object -Process {
            $this.TokenIgnores += [ValeConfigurationIgnore]@{
                GlobPattern    = $_.Key
                IgnorePatterns = $_.Value
            }
        }

        $this.WordTemplate = $Info.WordTemplate
        $this.RootIniPath = $Info.RootINI
        $this.DictionaryPath = $Info.DictionaryPath
        $this.NlpEndpoint = $Info.NLPEndpoint
    }
}
