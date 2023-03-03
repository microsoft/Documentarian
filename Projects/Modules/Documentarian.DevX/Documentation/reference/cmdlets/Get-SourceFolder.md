---
title: Get-SourceFolder
summary: Get-SourceFolder...
external help file: Documentarian.DevX-help.xml
Module Name: Documentarian.DevX
online version:
schema: 2.0.0
---

# Get-SourceFolder

## Synopsis

{{ Fill in the Synopsis }}

## SYNTAX

### ByPreset (Default)

```powershell
Get-SourceFolder
 [-Preset <String>]
 [-PublicFolder <String>]
 [-PrivateFolder <String>]
 [-SourceFolder <String>]
 [<CommonParameters>]
```

### WithSpecificFolders

```powershell
Get-SourceFolder
 [-Category <String[]>]
 [-Scope <String[]>]
 [-Preset <String>]
 [-PublicFolder <String>]
 [-PrivateFolder <String>]
 [<CommonParameters>]
```

### ByOption

```powershell
Get-SourceFolder
 -Category <String[]>
 -Scope <String[]>
 -PublicFolder <String>
 -PrivateFolder <String>
 -SourceFolder <String>
 [<CommonParameters>]
```

### WithSourceFolder

```powershell
Get-SourceFolder
 [-SourceFolder <String>]
 [<CommonParameters>]
```

## Description

{{ Fill in the Description }}

## Examples

### Example 1

```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## Parameters

### `-Category`

{{ Fill Category Description }}

```yaml
Type: String[]
Parameter Sets: WithSpecificFolders
Aliases:
Accepted values: Classes, Enums, Functions

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String[]
Parameter Sets: ByOption
Aliases:
Accepted values: Classes, Enums, Functions

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-Preset`

{{ Fill Preset Description }}

```yaml
Type: String
Parameter Sets: ByPreset, WithSpecificFolders
Aliases:
Accepted values: Ordered, Functions, All

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-PrivateFolder`

{{ Fill PrivateFolder Description }}

```yaml
Type: String
Parameter Sets: ByPreset, WithSpecificFolders
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ByOption
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-PublicFolder`

{{ Fill PublicFolder Description }}

```yaml
Type: String
Parameter Sets: ByPreset, WithSpecificFolders
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ByOption
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-Scope`

{{ Fill Scope Description }}

```yaml
Type: String[]
Parameter Sets: WithSpecificFolders
Aliases:
Accepted values: Public, Private

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String[]
Parameter Sets: ByOption
Aliases:
Accepted values: Public, Private

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-SourceFolder`

{{ Fill SourceFolder Description }}

```yaml
Type: String
Parameter Sets: ByPreset, WithSourceFolder
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ByOption
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`,
-InformationAction, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, `-WarningAction`, and `-WarningVariable`. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## Inputs

### None

## Outputs

### SourceFolder

## Notes

## Related Links
