---
external help file: sdwheeler.DocsHelpers-help.xml
Module Name: sdwheeler.DocsHelpers
ms.date: 09/09/2021
schema: 2.0.0
---

# Get-Syntax

## Synopsis
Displays the syntax of a cmdlet.

## Syntax

```
Get-Syntax [-CmdletName] <String> [-Markdown] [<CommonParameters>]
```

## Description

The cmdlet is similar to the output you get from `Get-Command -Syntax`. By default, the syntax information is returned as an object. You can also return it as formatted Markdown source that can be easily pasted into a cmdlet Markdown file.

## Examples

### Example 1 - Get the syntax of a command as Markdown text

```powershell
Get-Syntax Get-Command -Markdown
```

~~~markdown
### CmdletSet (Default)

```
Get-Command [[-ArgumentList] <Object[]>] [-Verb <string[]>] [-Noun <string[]>]
 [-Module <string[]>] [-FullyQualifiedModule <ModuleSpecification[]>] [-TotalCount <int>]
 [-Syntax] [-ShowCommandInfo] [-All] [-ListImported] [-ParameterName <string[]>]
 [-ParameterType <PSTypeName[]>]
```

### AllCommandSet

```
Get-Command [[-Name] <string[]>] [[-ArgumentList] <Object[]>] [-Module <string[]>]
 [-FullyQualifiedModule <ModuleSpecification[]>] [-CommandType <CommandTypes>] [-TotalCount <int>]
 [-Syntax] [-ShowCommandInfo] [-All] [-ListImported] [-ParameterName <string[]>]
 [-ParameterType <PSTypeName[]>] [-UseFuzzyMatching] [-UseAbbreviationExpansion]
```
~~~

### Example 2 - Get the syntax of a command as an object

```powershell
Get-Syntax Get-Command | Format-Table -Wrap
```

```Output
Cmdlet      ParameterSetName IsDefault Parameters
------      ---------------- --------- ----------
Get-Command CmdletSet             True [[-ArgumentList] <Object[]>] [-Verb <string[]>] [-Noun <string[]>] [-Module
                                       <string[]>] [-FullyQualifiedModule <ModuleSpecification[]>] [-TotalCount <int>]
                                       [-Syntax] [-ShowCommandInfo] [-All] [-ListImported] [-ParameterName <string[]>]
                                       [-ParameterType <PSTypeName[]>] [<CommonParameters>]
Get-Command AllCommandSet        False [[-Name] <string[]>] [[-ArgumentList] <Object[]>] [-Module <string[]>]
                                       [-FullyQualifiedModule <ModuleSpecification[]>] [-CommandType <CommandTypes>]
                                       [-TotalCount <int>] [-Syntax] [-ShowCommandInfo] [-All] [-ListImported]
                                       [-ParameterName <string[]>] [-ParameterType <PSTypeName[]>] [-UseFuzzyMatching]
                                       [-UseAbbreviationExpansion] [<CommonParameters>]
```

## Parameters

### -CmdletName

The name of the cmdlet for which you want syntax information.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Markdown

Outputs the syntax information as formatted Markdown. The Markdown is suitable for updating the
syntax blocks in a `cmdlet.md` file.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## Inputs

### None

## Outputs

### System.Object

## Notes

## Related links
