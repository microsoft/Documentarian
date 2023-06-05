---
external help file: Documentarian.MarkdownBuilder-help.xml
Locale: en-US
Module Name: Documentarian.MarkdownBuilder
online version: https://microsoft.github.io/Documentarian/modules/markdownbuilder/reference/cmdlets/add-heading/
schema: 2.0.0
title: Add-Heading
---

# Add-Heading

## SYNOPSIS
Adds a heading to a **MarkdownBuilder** object.

## SYNTAX

```
Add-Heading [-Content] <String>
            [[-Level] <Int32>]
            [[-Builder] <MarkdownBuilder>]
            [[-LineEnding] <LineEnding>]
            [-PassThru]
            [<CommonParameters>]
```

## DESCRIPTION

Adds an ATX style heading to a **MarkdownBuilder** object. If you don't specify the **Level**
parameter, it adds an H2 by default.

If you don't pass a **MarkdownBuilder** object to this function, it creates one. If you specify the
**LineEnding** parameter but not the **Builder** parameter, the value you specified is used as the
default line ending for the new object.

If you specify the **PassThru** parameter, the function returns the **MarkdownBuilder** object. If
the function detects that it's called in a pipeline, it returns the **MarkdownBuilder** object
regardless of whether you specify the **PassThru** parameter.

## EXAMPLES

### Example 1

This example shows options for getting output from the `Add-Heading` function.

```powershell
Add-Heading -Content 'My Heading'
Add-Heading -Content 'My Heading' -PassThru
Add-Heading -Content 'My Heading' | ForEach-Object { "$_" }
```

```output
DefaultLineEnding     : LF
DefaultFenceCharacter : Backtick
DefaultFenceLength    : 3
StringBuilder         : ## My Heading

## My Heading
```

The first statement shows that the function has no output by default. The second statement shows
the **MarkdownBuilder** is output when you use the **PassThru** parameter. The last statement shows
that the function outputs the **MarkdownBuilder** if any other function is called after it in the
pipeline.

## PARAMETERS

### `-Builder`

The **MarkdownBuilder** object to add the heading to. If you don't specify a value for this
parameter, the function creates a new **MarkdownBuilder**. If you call this function in a pipeline
after another **Documentarian.MarkdownBuilder** function, that function passes a
**MarkdownBuilder** object to this function through the pipeline.

```yaml
Type: MarkdownBuilder
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### `-Content`

The content of the heading after the ATX heading prefix. Don't include the leading `#` characters.
The function adds them for you based on the value of the **Level** parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-Level`

The heading level to add. Headings must be between 1 and 6, inclusive. The default heading level is
2.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-LineEnding`

The line ending to use for the heading. You can specify a **LineEnding** object or a string to cast
to a **LineEnding** object. If you don't specify a line ending, the function uses the default line
ending for the **MarkdownBuilder** object.

If you specify a string, you can use the shorthand, literal, or regex value for the line ending you
want to use. Valid options are listed in the table below:

|            Name             | Shorthand String | Literal String | Regex String |
| :-------------------------- | :--------------: | :------------: | :----------: |
| Carriage Return             |       `CR`       |    `` `r ``    |     `\r`     |
| Line Feed                   |       `LF`       |    `` `n ``    |     `\n`     |
| Carriage Return + Line Feed |      `CRLF`      |   `` `r`n ``   |    `\r\n`    |

```yaml
Type: LineEnding
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-PassThru`

Passes the **MarkdownBuilder** object through the pipeline. By default, the function doesn't return
any output. Even if you don't specify this parameter, the function outputs the **MarkdownBuilder**
object when the function is called at the beginning of or in the middle of a pipeline.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`,
`-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, `-WarningAction`, and `-WarningVariable`. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### MarkdownBuilder

You can pipe a **MarkdownBuilder** object to this function.

## OUTPUTS

### MarkdownBuilder

By default, this function returns no output to the pipeline. When you specify the **PassThru**
parameter or call another function after this one in the pipeline, it outputs the updated
**MarkdownBuilder** object.

## NOTES

## RELATED LINKS
