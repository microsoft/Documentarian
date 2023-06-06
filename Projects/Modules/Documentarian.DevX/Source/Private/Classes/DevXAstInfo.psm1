# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language

class DevXAstInfo {
  [ScriptBlockAst]$Ast
  [Token[]]$Tokens
  [ParseError[]]$Errors

  DevXAstInfo([ScriptBlock]$ScriptBlock) {
    $t, $e = $null
    $this.Ast = [Parser]::ParseInput(
      $ScriptBlock.ToString(),
      [ref]$t,
      [ref]$e
    )
    $this.Tokens = $t
    $this.Errors = $e
  }

  DevXAstInfo([string]$Path) {
    $t, $e = $null
    $this.Ast = [Parser]::ParseFile(
      $Path,
      [ref]$t,
      [ref]$e
    )
    $this.Tokens = $t
    $this.Errors = $e
  }

  DevXAstInfo([ScriptBlockAst]$ast) {
    $this.Ast = $ast
  }

  DevXAstInfo([ScriptBlockAst]$ast, [Token[]]$tokens, [ParseError[]]$errors) {
    $this.Ast = $ast
    $this.Tokens = $tokens
    $this.Errors = $errors
  }
}
