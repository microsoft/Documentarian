---
external help file: Documentarian.MarkdownBuilder-help.xml
Locale: en-US
Module Name: Documentarian.MarkdownBuilder
online version: https://microsoft.github.io/Documentarian/modules/markdownbuilder/reference/cmdlets/add-frontmatter/
schema: 2.0.0
title: Add-FrontMatter
---

# Add-FrontMatter

## SYNOPSIS
Adds front matter to a **MarkdownBuilder** object.

## SYNTAX

```
Add-FrontMatter [-FrontMatter] <Hashtable>
                [[-Format] <String>]
                [[-Builder] <MarkdownBuilder>]
                [[-LineEnding] <LineEnding>]
                [-PassThru]
                [<CommonParameters>]
```

## DESCRIPTION

Adds front matter to a **MarkdownBuilder** object from a given hashtable of key-value pairs.

If you don't pass a **MarkdownBuilder** object to this function, it creates one. If you specify the
**LineEnding** parameter but not the **Builder** parameter, the value you specified is used as the
default line ending for the new object.

If you specify the **PassThru** parameter, the function returns the **MarkdownBuilder** object. If
the function detects that it's called in a pipeline, it returns the **MarkdownBuilder** object
regardless of whether you specify the **PassThru** parameter.

## EXAMPLES

### Example 1

This example shows options for getting output from the `Add-FrontMatter` function.

```powershell
$Metadata = @{
    title = 'My Document'
    date  = Get-Date -Format 'yyyy-MM-dd'
}
Add-FrontMatter -FrontMatter $Metadata
Add-FrontMatter -FrontMatter $Metadata -PassThru
Add-FrontMatter -FrontMatter $Metadata | ForEach-Object { "$_" }
```

```output
DefaultLineEnding     : LF
DefaultFenceCharacter : Backtick
DefaultFenceLength    : 3
StringBuilder         : ---
                        date: 2023-06-04
                        title: My Document
                        ---

---
date: 2023-06-04
title: My Document
---
```

The first statement shows that the function has no output by default. The second statement shows
the **MarkdownBuilder** is output when you use the **PassThru** parameter. The last statement shows
that the function outputs the **MarkdownBuilder** if any other function is called after it in the
pipeline.

## PARAMETERS

### `-Builder`

The **MarkdownBuilder** object to add the front matter to. If you don't specify a value for this
parameter, the function creates a new **MarkdownBuilder**. If you call this function in a pipeline
after another **Documentarian.MarkdownBuilder** function, that function passes a
**MarkdownBuilder** object to this function through the pipeline.

```yaml
Type: MarkdownBuilder
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### `-Format`

The format of the front matter. The only supported format is YAML.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: YAML
Accept pipeline input: False
Accept wildcard characters: False
```

### `-FrontMatter`

The key-value pairs to add as front matter.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-LineEnding`

The line ending to use for the front matter. You can specify a **LineEnding** object or a string to
cast to a **LineEnding** object. If you don't specify a line ending, the function uses the default
line ending for the **MarkdownBuilder** object.

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
Position: 4
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
Default value: False
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
