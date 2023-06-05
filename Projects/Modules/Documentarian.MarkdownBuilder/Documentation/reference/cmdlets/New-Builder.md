---
external help file: Documentarian.MarkdownBuilder-help.xml
Locale: en-US
Module Name: Documentarian.MarkdownBuilder
online version: https://microsoft.github.io/Documentarian/modules/markdownbuilder/reference/cmdlets/add-line/
schema: 2.0.0
title: New-Builder
---

# New-Builder

## SYNOPSIS
Creates an instance of the **MarkdownBuilder** object.

## SYNTAX

### FromContent (Default)

```
New-Builder [-Content <String>]
            [-DefaultLineEnding <LineEnding>]
            [-DefaultCodeFenceCharacter <CodeFenceCharacter>]
            [-DefaultCodeFenceLength <Int32>]
            [<CommonParameters>]
```

### FromStringBuilder

```
New-Builder [-StringBuilder <StringBuilder>]
            [-DefaultLineEnding <LineEnding>]
            [-DefaultCodeFenceCharacter <CodeFenceCharacter>]
            [-DefaultCodeFenceLength <Int32>]
            [<CommonParameters>]
```

## DESCRIPTION

The `New-Builder` function creates an instance of the **MarkdownBuilder** class. You can use this
object to programmatically write Markdown in your PowerShell functions and scripts. You can pass
the **MarkdownBuilder** object to the other functions in this module, like `Add-Line` and
`Start-CodeFence`.

## EXAMPLES

### Example 1

This example creates a new **MarkdownBuilder** with the default options.

```powershell
New-Builder
```

```output
DefaultLineEnding     : LF
DefaultFenceCharacter : Backtick
DefaultFenceLength    : 3
StringBuilder         :
```

### Example 2

This example creates a new **MarkdownBuilder** that uses the tilde (`~`) for code fences and CRLF
line endings.

```powershell
New-Builder -DefaultCodeFenceCharacter Tilde -DefaultLineEnding CRLF
```

```output
DefaultLineEnding     : CRLF
DefaultFenceCharacter : Tilde
DefaultFenceLength    : 3
StringBuilder         :
```

### Example 3

This example creates a new **MarkdownBuilder** from an existing string of Markdown content.

```powershell
$Content = @'
# My Document

This is the leading text. Any lines or code fences added with the `Add-Line` or
`Start-CodeFence` functions is added after this text.
'@
$builder = New-Builder -Content $Content

$builder.ToString()

$builder | Add-Heading -Level 2 -Content 'From MarkdownBuilder'
$builder | Add-Line -Content 'This is new content.'
$builder.ToString()
```

### Example 4

This example creates a new **MarkdownBuilder** from an existing **System.Text.StringBuilder**
object.

```powershell

```

## PARAMETERS

### `-Content`

Creates an instance of the **MarkdownBuilder** with this string in the wrapped
**System.Text.StringBuilder** object. If you don't specify this parameter or the **StringBuilder**
parameter, the new **MarkdownBuilder** is created without any content in it.

You can't use this parameter with the **StringBuilder** parameter.

```yaml
Type: String
Parameter Sets: FromContent
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-DefaultCodeFenceCharacter`

Specifies the default character to use for code fences. If you don't specify a value for this
parameter, the function uses the default fence character of the **MarkdownBuilder**'s constructor,
which is the backtick (`` ` ``). You can override the default when you create a new code fence.

You can specify the name of the character or the literal character. Valid options are listed in the
table below:

| Character | Named String | Literal String |
| :-------- | :----------: | :------------: |
| `` ` ``   |   Backtick   |    `` ` ``     |
| `~`       |    Tilde     |      `~`       |

```yaml
Type: CodeFenceCharacter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-DefaultCodeFenceLength`

The number of fence characters to use for code fences. This value must be an integer greater than
or equal to 3. If you don't specify a value for this parameter, the function uses the default fence
length of the **MarkdownBuilder**'s constructor, which is `3`. You can override the default when
you create a new code fence.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-DefaultLineEnding`

The characters to use when adding new lines to the **MarkdownBuilder**. You can specify a
**LineEnding** object or a string to cast to a **LineEnding** object. If you don't specify a line
ending, the function uses the default line ending for the **MarkdownBuilder**'s constructor, which
is LF (`` `n ``). You can override the default when you add a line.

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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-StringBuilder`

Creates an instance of the **MarkdownBuilder** with this object as the wrapped
**System.Text.StringBuilder** object.

You can't use this parameter with the **Content** parameter.

```yaml
Type: StringBuilder
Parameter Sets: FromStringBuilder
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

### None

You can't pipe any values to this function.

## OUTPUTS

### MarkdownBuilder

This function always outputs a new instance of the **MarkdownBuilder** class.

## NOTES

## RELATED LINKS
