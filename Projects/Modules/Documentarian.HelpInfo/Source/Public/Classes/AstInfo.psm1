# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ./DecoratingComments/DecoratingComment.psm1
using module ./DecoratingComments/DecoratingCommentsRegistry.psm1

class AstInfo {
    <#
        .SYNOPSIS
        Represents a parsed AST object with its tokens, errors, and any decorating comment.

        .DESCRIPTION
        The AstInfo object is a convenience wrapper around parsing and inspecting AST objects. You
        can use it to create an object that includes properties for the target AST object itself,
        the tokens discovered when parsing the AST, the parsing errors, and any comment that
        decorated the AST object.

        The ModuleAuthor uses this class extensively to inspect PowerShell code for reference
        documentation.

        Instead of creating the class directly, you can use the `Get-AstInfo` function to build the
        object. If you need to find a nested AST object, you can use the `Find-AstInfo` function
        with the `-AsAstInfo` parameter.
    #>

    <#
        .SYNOPSIS
        The parsed AST.

        .DESCRIPTION
        The Ast property represents the parsed AST object. It can be any type of AST, like a
        TypeDefinitionAst or AttributeAst.
    #>
    [Ast] $Ast

    <#
        .SYNOPSIS
        The tokens discovered while parsing the AST.

        .DESCRIPTION
        When parsing a file or text block, PowerShell populates a list of Token objects when it
        returns the parsed AST object. These tokens include the comments for the file.
    #>
    [Token[]] $Tokens

    <#
        .SYNOPSIS
        The errors from parsing the target.

        .DESCRIPTION
        When parsing a file or text block, PowerShell populates a list of parse errors when it
        returns the parsed AST object.
    #>
    [ParseError[]] $Errors

    <#
        .SYNOPSIS
        The comment that decorates the target AST.

        .DESCRIPTION
        Because it's common practice to add a comment about a piece of code immediately before or
        inside the code, the AstInfo object captures any comments that decorate the AST so the
        comment can be used when generating documentation or inspecting an AST.
    #>
    [DecoratingComment] $DecoratingComment

    AstInfo([ScriptBlock]$scriptBlock) {
        <#
            .SYNOPSIS
            Creates an AstInfo object from a script block.

            .DESCRIPTION
            Creates an AstInfo object from a script block, parsing the ScriptBlock as a string
            and finding any decorating comment. The decorating comment isn't parsed.

            .PARAMETER scriptBlock
            The ScriptBlock to parse.
        #>

        $t, $e = $null
        $this.Ast = [Parser]::ParseInput(
            $scriptBlock.ToString(),
            [ref]$t,
            [ref]$e
        )
        $this.Tokens = $t
        $this.Errors = $e

        $this.DecoratingComment = [DecoratingComment]::new($this.Ast, $this.Tokens)
    }

    AstInfo([ScriptBlock]$scriptBlock, [DecoratingCommentsRegistry]$registry) {
        <#
            .SYNOPSIS
            Creates an AstInfo object from a script block.

            .DESCRIPTION
            Creates an AstInfo object from a script block, parsing the ScriptBlock as a string
            and finding any decorating comment. If the ScriptBlock included a decorating comment,
            it's parsed with the passed DecoratingCommentsRegistry.

            .PARAMETER scriptBlock
            The ScriptBlock to parse.

            .PARAMETER registry
            The DecoratingCommentsRegistry to parse any decorating comments with. The registry
            has a list of DecoratingCommentsBlockSchema and DecoratingCommentsBlockKeyword objects,
            which it uses to parse any comment block that decorates the ScriptBlock.
        #>

        $t, $e = $null
        $this.Ast = [Parser]::ParseInput(
            $scriptBlock.ToString(),
            [ref]$t,
            [ref]$e
        )
        $this.Tokens = $t
        $this.Errors = $e

        $this.DecoratingComment = [DecoratingComment]::new($this.Ast, $this.Tokens, $registry)
    }

    AstInfo([string]$Path) {
        <#
            .SYNOPSIS
            Creates an AstInfo object from the path to a PowerShell file.

            .DESCRIPTION
            Creates an AstInfoobject from the path to a PowerShell file.
        #>

        # Need to initialize the variables before we can pass them by reference.
        $t, $e = $null

        $this.Ast = [Parser]::ParseFile(
            $Path,
            [ref]$t,
            [ref]$e
        )
        $this.Tokens = $t
        $this.Errors = $e

        $this.DecoratingComment = [DecoratingComment]::new($this.Ast, $this.Tokens)
    }

    AstInfo([string]$Path, [DecoratingCommentsRegistry]$registry) {
        <#
            .SYNOPSIS
            Creates an **AstInfo** object from the path to a script file.

            .DESCRIPTION
            Creates an **AstInfo** object from the path to a script file.
        #>

        # Need to initialize the variables before we can pass them by reference.
        $t, $e = $null

        $this.Ast = [Parser]::ParseFile(
            $Path,
            [ref]$t,
            [ref]$e
        )

        $this.Tokens = $t
        $this.Errors = $e

        $this.DecoratingComment = [DecoratingComment]::new($this.Ast, $this.Tokens, $registry)
    }

    AstInfo([Ast]$targetAst) {
        <#
            .SYNOPSIS
            Creates an **AstInfo** object from an already-parsed AST.

            .DESCRIPTION
            Creates an **AstInfo** object from an already-parsed AST. It doesn't define the tokens
            or errors.
        #>

        # Need to initialize the variables before we can pass them by reference.
        $t, $e = $null
        $this.Ast = [Parser]::ParseInput(
            $targetAst.Extent.Text,
            [ref]$t,
            [ref]$e
        )
        $this.Tokens = $t
        $this.Errors = $e

        $this.DecoratingComment = [DecoratingComment]::new($this.Ast, $this.Tokens)
    }

    AstInfo([Ast]$targetAst, [DecoratingCommentsRegistry]$registry) {
        <#
            .SYNOPSIS
            Creates an **AstInfo** object from an already-parsed AST.

            .DESCRIPTION
            Creates an **AstInfo** object from an already-parsed AST. It re-parses the AST to find
            any tokens in it, so those can be used to look for a decorating comment. This is only
            effective when `$targetAst` is an AST object that has a script block body. It uses the
            passed registry to parse the decorating comment block, if it finds one.
        #>

        # Need to initialize the variables before we can pass them by reference.
        $t, $e = $null
        $this.Ast = [Parser]::ParseInput(
            $targetAst.Extent.Text,
            [ref]$t,
            [ref]$e
        )
        $this.Tokens = $t
        $this.Errors = $e

        $this.DecoratingComment = [DecoratingComment]::new($this.Ast, $this.Tokens, $registry)
    }

    AstInfo([Ast]$targetAst, [Token[]]$tokens) {
        <#
            .SYNOPSIS
            Creates an **AstInfo** object from an already-parsed AST and its tokens.

            .DESCRIPTION
            Creates an **AstInfo** object from an already-parsed AST, tokens. It uses the AST and
            the tokens to find any decorating comment, but doesn't parse them automatically.
        #>

        $this.Ast = $targetAst
        $this.Tokens = $tokens

        $this.DecoratingComment = [DecoratingComment]::new($this.Ast, $this.Tokens)
    }

    AstInfo(
        [Ast]$targetAst,
        [Token[]]$tokens,
        [DecoratingCommentsRegistry]$registry
    ) {
        <#
            .SYNOPSIS
            Creates an **AstInfo** object from an already-parsed AST, tokens, and errors and
            parses any decorating comment.

            .DESCRIPTION
            Creates an **AstInfo** object from an already-parsed AST, tokens, and errors. It uses
            the specified DecoratedCommentsRegistry to parse the AST's decorating comment, if it
            has one.
        #>

        $this.Ast = $targetAst
        $this.Tokens = $tokens

        $this.DecoratingComment = [DecoratingComment]::new($this.Ast, $this.Tokens, $registry)
    }
}
