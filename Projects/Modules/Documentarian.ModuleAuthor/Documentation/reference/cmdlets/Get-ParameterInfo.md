---
external help file:
Module Name: Documentarian.ModuleAuthor
online version:
ms.date: 03/10/2023
schema: 2.0.0
---

# Get-ParameterInfo

## SYNOPSIS

Gets information about a cmdlet parameter in Markdown format.

## SYNTAX

### AsMarkdown (Default)

```
Get-ParameterInfo [-ParameterName] <String[]> [-CmdletName] <String> [-ShowAll]
 [<CommonParameters>]
```

### AsObject

```
Get-ParameterInfo [-ParameterName] <String[]> [-CmdletName] <String> [-AsObject]
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet gets information about one or more parameters for a cmdlet formatted as Markdown that's
compatible with cmdlet reference documentation. You can also get the information a a PowerShell
object.

This cmdlet is useful for updating existing parameters that have changed or adding new parameter
when a cmdlet has been updated.

## EXAMPLES

### Example 1 - Parameter information as an object

```powershell
Get-ParameterInfo -ParameterName Path -CmdletName Get-Metadata -AsObject
```

```Output
Name          : Path
HelpText      : {{Placeholder}}}
Type          : System.String
ParameterSet  : (All)
Aliases       :
Required      : False
Position      :
FromRemaining : False
Pipeline      : ByValue (False), ByName (False)
Dynamic       : False
Wildcard      : True
```

### Example 2 - Parameter information as Markdown

This example is getting information about two parameters. One of the parameters is a dynamic
parameter that is made available by the **FileSystem** provider.

```powershell
Get-ParameterInfo -ParameterName LiteralPath, Stream -CmdletName Remove-Item
```

~~~Output
### -LiteralPath

{{Placeholder}}

```yaml
Type: System.String[]
Parameter Sets: LiteralPath
Aliases: PSPath, LP

Required: True
Position: Named
Default value: None
Value From Remaining: False
Accept pipeline input: ByValue (False), ByName (True)
Dynamic: False
Accept wildcard characters: False
```

### -Stream

{{Placeholder}}

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Value From Remaining: False
Accept pipeline input: ByValue (False), ByName (False)
Dynamic: True (FileSystem provider)
Accept wildcard characters: False
```
~~~

## PARAMETERS

### -AsObject

This parameter causes the cmdlet to return a PowerShell object instead of Markdown text.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: AsObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CmdletName

The name of the cmdlet that has the specified **ParameterName**.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParameterName

The name of one or more parameters belonging to the **CmdletName**.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowAll

By default the cmdlet markdown that is compatible with PlatyPS v0.14.x. When you specify this
parameter the output includes extra parameter metadata that is supported by PlatyPS v2.x.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: AsMarkdown
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

## INPUTS

### None

## OUTPUTS

### ParameterInfo

### System.String

## NOTES

## RELATED LINKS

[Get-Syntax](Get-Syntax.md)
