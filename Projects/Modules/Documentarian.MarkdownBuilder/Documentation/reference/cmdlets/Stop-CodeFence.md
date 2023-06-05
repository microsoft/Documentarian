---
external help file: Documentarian.MarkdownBuilder-help.xml
Locale: en-US
Module Name: Documentarian.MarkdownBuilder
online version: https://microsoft.github.io/Documentarian/modules/markdownbuilder/reference/cmdlets/stop-codefence
schema: 2.0.0
title: Stop-CodeFence
---

# Stop-CodeFence

## SYNOPSIS
Stops the last opened code fence in a **MarkdownBuilder** object.

## SYNTAX

```
Stop-CodeFence [[-Builder] <MarkdownBuilder>]
               [[-LineEnding] <LineEnding>]
               [-PassThru]
               [<CommonParameters>]
```

## DESCRIPTION

The `Stop-CodeFence` function closes the most recently opened fenced code block in a
**MarkdownBuilder** object. The **MarkdownBuilder** keeps internal track of opened code fences and
ensures that the closing fence has the correct characters and length.

If you don't pass a **MarkdownBuilder** object to this function, it creates one. If you specify the
**LineEnding** parameter but not the **Builder** parameter, the value you specified is used as the
default line ending for the new object.

If you specify the **PassThru** parameter, the function returns the **MarkdownBuilder** object. If
the function detects that it's called in a pipeline, it returns the **MarkdownBuilder** object
regardless of whether you specify the **PassThru** parameter.

## EXAMPLES

### Example 1

This example shows options for getting output from the `Stop-CodeFence` function.

```powershell
Start-CodeFence -Language yaml -Character ~ | Stop-CodeFence
Start-CodeFence -Language yaml -Character ~ | Stop-CodeFence -PassThru
Start-CodeFence -Language yaml -Character ~ | Stop-CodeFence | ForEach-Object {
    "$_"
}
```

```output
DefaultLineEnding     : LF
DefaultFenceCharacter : Backtick
DefaultFenceLength    : 3
StringBuilder         : ~~~yaml
                        ~~~

~~~yaml
~~~
```

### Example 2

This example shows how you can use the function for nested code blocks.

```powershell
New-Builder -DefaultCodeFenceCharacter ~ |
    Start-CodeFence -Language markdown -Length 3 |
    Add-Line 'This line is inside the Markdown fence.' |
    Start-CodeFence -Language yaml -Length 5 |
    Add-Line 'this: is YAML in Markdown' |
    Stop-CodeFence |
    Add-Line 'This line is after the nested fence.' |
    Stop-CodeFence |
    Add-Line 'This line is after the fences are closed.' |
    ForEach-Object { "$_" }
```

```output
~~~~~~markdown
This line is inside the Markdown fence.

~~~~~yaml
this: is YAML in Markdown
~~~~~

This line is after the nested fence.
~~~~~~

This line is after the fences are closed.
```

Note that even though the first code fence was opened with a length of 3, the nested fence was
opened with a length of 5. The **MarkdownBuilder** automatically updated the fence length of the
outer code fence to 6, ensuring the inner fence is correctly contained and the output Markdown is
valid.

## PARAMETERS

### `-Builder`

The **MarkdownBuilder** object to close the code fence in. If you don't specify a value for this
parameter, the function creates a new **MarkdownBuilder**. If you call this function in a pipeline
after another **Documentarian.MarkdownBuilder** function, that function passes a
**MarkdownBuilder** object to this function through the pipeline.

```yaml
Type: MarkdownBuilder
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### `-LineEnding`

The line ending to use for the code fence. You can specify a **LineEnding** object or a string to
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
Position: 1
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
