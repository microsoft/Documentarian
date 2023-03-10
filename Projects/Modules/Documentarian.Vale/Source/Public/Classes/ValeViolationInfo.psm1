# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./ValeViolationAction.psm1
using module ./ValeViolationPosition.psm1
using module ../Enums/ValeAlertLevel.psm1

class ValeViolationInfo {
    [ValeViolationPosition] $Position
    [string]                $RuleName
    [ValeAlertLevel]        $AlertLevel
    [string]                $Message
    [string]                $MatchingText
    [ValeViolationAction]   $Action
    [string]                $RuleLink
    [string]                $Description

    ValeViolationInfo() {}

    ValeViolationInfo([hashtable]$Info) {
        $this.SetInfo($Info, $null)
    }

    ValeViolationInfo([hashtable]$Info, [System.IO.FileInfo]$File) {
        $this.SetInfo($Info, $File)
    }

    [void] SetInfo([hashtable]$Info, [System.IO.FileInfo]$File) {
        $this.Position = [ValeViolationPosition]@{
            FileInfo    = $File
            Line        = $Info.Line
            StartColumn = $Info.Span[0]
            EndColumn   = $Info.Span[1]
        }
        if ($null -ne $Info.Action) {
            $this.Action = [ValeViolationAction]@{
                Name       = $Info.Action.Name
                Parameters = $Info.Action.Params
            }
        }
        $this.Description = $Info.Description
        $this.MatchingText = $Info.Match
        $this.Message = $Info.Message
        $this.RuleLink = $Info.Link
        $this.RuleName = $Info.Check
    }
}
