---
external help file: Documentarian.MarkdownBuilder-help.xml
Locale: en-US
Module Name: Documentarian.MarkdownBuilder
online version: https://microsoft.github.io/Documentarian/modules/markdownbuilder/reference/cmdlets/start-codefence
schema: 2.0.0
title: Start-CodeFence
---

# Start-CodeFence

## SYNOPSIS
Starts a new code fence in a **MarkdownBuilder** object.

## SYNTAX

```
Start-CodeFence [[-Language] <String>]
                [[-Builder] <MarkdownBuilder>]
                [[-Character] <CodeFenceCharacter>]
                [[-Length] <Int32>]
                [[-LineEnding] <LineEnding>]
                [-PassThru]
                [<CommonParameters>]
```

## DESCRIPTION

The `Start-CodeFence` function opens a new fenced code block in a **MarkdownBuilder** object. The
**MarkdownBuilder** keeps internal track of opened code fences and ensures that they have enough
fence characters to be valid when they include a nested code fence. You can specify the fence
character and length or use the defaults for the **MarkdownBuilder** object. When you're done adding
code in the fence, you can use the `Stop-CodeFence` function to close the fence.

If you don't pass a **MarkdownBuilder** object to this function, it creates one. If you specify the
**Character**, **Length**, or **LineEnding** parameters but not the **Builder** parameter, the
values you specify for those parameters are used as the defaults for the new object.

If you specify the **PassThru** parameter, the function returns the **MarkdownBuilder** object. If
the function detects that it's called in a pipeline, it returns the **MarkdownBuilder** object
regardless of whether you specify the **PassThru** parameter.

## EXAMPLES

### Example 1

This example shows options for getting output from the `Start-CodeFence` function.

```powershell
Start-CodeFence -Language yaml -Character ~
Start-CodeFence -Language yaml -Character ~ -PassThru
Start-CodeFence -Language yaml -Character ~ | ForEach-Object { "$_" }
```

```output
DefaultLineEnding     : LF
DefaultFenceCharacter : Tilde
DefaultFenceLength    : 3
StringBuilder         : ~~~yaml

~~~yaml
```

### Example 2

This example shows how you can use the function for nested code blocks.

```powershell
New-Builder -DefaultCodeFenceCharacter ~ |
    Start-CodeFence -Language markdown |
    Add-Line 'This line is inside the Markdown fence.' |
    Start-CodeFence -Language yaml |
    Add-Line 'this: is YAML in Markdown' |
    Stop-CodeFence |
    Add-Line 'This line is after the nested fence.' |
    Stop-CodeFence |
    Add-Line 'This line is after the fences are closed.' |
    ForEach-Object { "$_" }
```

```output
~~~~markdown
This line is inside the Markdown fence.

~~~yaml
this: is YAML in Markdown
~~~

This line is after the nested fence.
~~~~

This line is after the fences are closed.
```

## PARAMETERS

### `-Builder`

The **MarkdownBuilder** object to open the code fence in. If you don't specify a value for this
parameter, the function creates a new **MarkdownBuilder**. If you call this function in a pipeline
after another **Documentarian.MarkdownBuilder** function, that function passes a
**MarkdownBuilder** object to this function through the pipeline.

```yaml
Type: MarkdownBuilder
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### `-Character`

Specifies the character to use for the code fence. If you don't specify a value for this parameter,
the function uses the default fence character of the **MarkdownBuilder** object.

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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-Language`

The language ID to use for the fence around the code block. If you don't specify a value for this
parameter, the fence is created without a language ID.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-Length`

The number of fence characters to use for the code fence. This value must be an integer greater
than or equal to 3. If you don't specify a value for this parameter, the function uses the default
fence length of the **MarkdownBuilder** object.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
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
