# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language

class AstInfo {
    # The abstract syntax tree (AST) of the target.
    [Ast] $Ast

    # The parsed tokens of the target.
    [Token[]]        $Tokens

    # The errors from parsing the target.
    [ParseError[]]   $Errors

    AstInfo([ScriptBlock]$ScriptBlock) {
        <#
            .SYNOPSIS
            Creates an **AstInfo** object from a script block.

            .DESCRIPTION
            Creates an **AstInfo** object from a script block.
        #>

        $t, $e = $null
        $this.Ast = [Parser]::ParseInput(
            $ScriptBlock.ToString(),
            [ref]$t,
            [ref]$e
        )
        $this.Tokens = $t
        $this.Errors = $e
    }

    AstInfo([string]$Path) {
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
    }

    AstInfo([Ast]$ast) {
        <#
            .SYNOPSIS
            Creates an **AstInfo** object from an already-parsed AST.

            .DESCRIPTION
            Creates an **AstInfo** object from an already-parsed AST. It doesn't define the tokens
            or errors.
        #>

        $this.Ast = $ast
    }

    AstInfo([Ast]$ast, [Token[]]$tokens, [ParseError[]]$errors) {
        <#
            .SYNOPSIS
            Creates an **AstInfo** object from an already-parsed AST, tokens, and errors.

            .DESCRIPTION
            Creates an **AstInfo** object from an already-parsed AST, tokens, and errors.
        #>

        $this.Ast = $ast
        $this.Tokens = $tokens
        $this.Errors = $errors
    }
}
