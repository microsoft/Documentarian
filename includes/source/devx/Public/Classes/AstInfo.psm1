# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language

class AstInfo {
  [ScriptBlockAst]$Ast
  [Token[]]$Tokens
  [ParseError[]]$Errors

  AstInfo([ScriptBlock]$ScriptBlock) {
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
    $t, $e = $null
    $this.Ast = [Parser]::ParseFile(
      $Path,
      [ref]$t,
      [ref]$e
    )
    $this.Tokens = $t
    $this.Errors = $e
  }

  AstInfo([ScriptBlockAst]$ast) {
    $this.Ast = $ast
  }

  AstInfo([ScriptBlockAst]$ast, [Token[]]$tokens, [ParseError[]]$errors) {
    $this.Ast = $ast
    $this.Tokens = $tokens
    $this.Errors = $errors
  }
}
