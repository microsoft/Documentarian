---
external help file:
Module Name: Documentarian.ModuleAuthor
online version:
schema: 2.0.0
ms.date: 03/10/2023
---

# Find-ParameterWithAttribute

## SYNOPSIS
Returns a list of cmdlets and parameters that have the specified attribute type.

## SYNTAX

```
Find-ParameterWithAttribute [-AttributeKind] <ParameterAttributeKind> [[-CommandName] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet returns a list of cmdlets and parameters that have the specified attribute type. This
is useful for finding cmdlets that have experimental parameters, parameters that have validation
attributes, or other specific attributes.

## EXAMPLES

### Example 1: Find all cmdlets with parameters that get their value from the remaining arguments

```powershell
Find-ParameterWithAttribute -AttributeKind ValueFromRemaining
```

```Output
Cmdlet                    Parameter           ValueFromRemainingArguments ParameterSetName
------                    ---------           --------------------------- ----------------
ForEach-Object            RemainingScripts                           True ScriptBlockSet
ForEach-Object            ArgumentList                               True PropertyAndMethodSet
Get-Command               ArgumentList                               True __AllParameterSets
Join-Path                 AdditionalChildPath                        True __AllParameterSets
New-Module                ArgumentList                               True __AllParameterSets
Read-Host                 Prompt                                     True __AllParameterSets
Trace-Command             ArgumentList                               True commandSet
Write-Host                Object                                     True __AllParameterSets
Write-Output              InputObject                                True __AllParameterSets
```

### Example 2: Find all cmdlets with parameters that get their value from the pipeline

```powershell
Find-ParameterWithAttribute -AttributeKind ValueFromPipeline -CommandName Get-Process
```

```Output
Cmdlet      Parameter   Pipeline                     ParameterSetName
------      ---------   --------                     ----------------
Get-Process Name        ByValue(False), ByName(True) Name, NameWithUserName
Get-Process Id          ByValue(False), ByName(True) Id, IdWithUserName
Get-Process InputObject ByValue(True), ByName(False) InputObject, InputObjectWithUserName
```

### Example 3: Find all cmdlets with parameters that support wildcards

```powershell
Find-ParameterWithAttribute -AttributeKind SupportsWildcards
```

```Output
Cmdlet                      Parameter           SupportsWildcards ParameterSetName
------                      ---------           ----------------- ----------------
ConvertTo-Contraction       Path                             True __AllParameterSets
Find-ParameterWithAttribute CommandName                      True __AllParameterSets
Get-BranchStatus            GitLocation                      True __AllParameterSets
Get-DocumentLink            IncludeKind                      True FilterByKind
Get-DocumentLink            ExcludeKind                      True FilterByKind
Get-DocumentLink            MatchMarkdown                    True __AllParameterSets
Get-DocumentLink            MatchText                        True __AllParameterSets
Get-DocumentLink            MatchDestination                 True __AllParameterSets
Get-DocumentLink            MatchReferenceID                 True __AllParameterSets
Get-DocumentLink            NotMatchMarkdown                 True __AllParameterSets
Get-DocumentLink            NotMatchText                     True __AllParameterSets
Get-DocumentLink            NotMatchDestination              True __AllParameterSets
Get-DocumentLink            NotMatchReferenceID              True __AllParameterSets
Get-Metadata                Path                             True AsYaml, AsObject, AsHash
Get-ValeStyle               Name                             True ByName
Remove-Metadata             Path                             True __AllParameterSets
Set-Metadata                Path                             True __AllParameterSets
Update-Headings             Path                             True __AllParameterSets
Update-Metadata             Path                             True __AllParameterSets
Update-ParameterOrder       Path                             True __AllParameterSets
```

## PARAMETERS

### -AttributeKind

Specifies the type of attribute you want to find. Possible values are:

- `DontShow`
- `Experimental`
- `HasValidation`
- `SupportsWildcards`
- `ValueFromPipeline`
- `ValueFromRemaining`

```yaml
Type: ParameterAttributeKind
Parameter Sets: (All)
Aliases:
Accepted values: DontShow, Experimental, HasValidation, SupportsWildcards, ValueFromPipeline, ValueFromRemaining

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommandName

The name of the command you want to search. If you don't specify a value, the cmdlet
searches all commands.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Get-ParameterInfo](Get-ParameterInfo.md)
