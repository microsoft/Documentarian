# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../DecoratingCommentsBlockKeyword.psm1
using module ../DecoratingCommentsBlockKeywords.psm1
using module ../DecoratingCommentsBlockSchema.psm1

class DecoratingCommentsBlockSchemasClassOverload : DecoratingCommentsBlockSchema {
  <#
        .SYNOPSIS
        Represents the schema for a comment decorating an overload in a class.

        .DESCRIPTION
        This class represents the schema for a block comment that decorates the
        member definition of an class constructor or method overload in
        PowerShell code.

        It parses the following keywords from the decorating comment:

        - `Synopsis` - A brief description of the overload's purpose. The
          keyword must have a block of text after it.
        - `Description` - A full description of the overload, with details.
          The keyword must have a block of text after it.
        - `Example` - An example of using the overload. You can document
          multiple examples by specifying the keyword once for each example.
          The keyword must have a block of text after it.
        - `Parameter` - Describes the purpose and usage for one of the
          overload's parameters. You must specify the name of the parameter
          you're describing after the keyword on the same line, then a block of
          text after it. Specify the keyword once for each parameter.
        - `Exception` - Describes when and why the method may intentionally
          throw a specific exception. You must specify the full type name of
          the exception after the keyword on the same line, then a block of
          text after it. Specify the keyword once for each exception.
    #>

  <#
        .SYNOPSIS
        The name of the parser schema to use for a decorated comment.

        .DESCRIPTION
        The **Name** property is used to select the correct parser schema for a
        decorated comment.

        If a decorated comment declares the `Schema` keyword, the
        **DecoratingCommentsRegistry** tries to retrieve the correct schema by
        matching the keyword's value first to a schema's  **Name** and then
        **Alias**. Schemas can share aliases, but not names.

        If a decorated comment doesn't declare the `Schema` keyword, the caller
        needs to decide which schema to use based on the current context.
    #>
  static [string] $Name = 'ClassOverload'

  <#
        .SYNOPSIS
        A list of alternate names for the parser schema.

        .DESCRIPTION
        The **Aliases** property is used to select the correct parser schema
        for a decorated comment.

        If a decorated comment declares the `Schema` keyword, the
        **DecoratingCommentsRegistry** tries to retrieve the correct schema by
        matching the keyword's value first to a schema's  **Name** and then
        **Alias**. Schemas can share aliases, but not names.

        If a decorated comment doesn't declare the `Schema` keyword, the caller
        needs to decide which schema to use based on the current context.

    #>
  static [string[]] $Aliases = @(
    'ClassConstructor'
    'ClassMethod'
  )

  <#
        .SYNOPSIS
        The Keywords this schema uses for retrieving documentation from a
        comment.

        .DESCRIPTION
        The Keywords property is the list of DecoratingCommentsBlockKeyword objects
        that this schema recognizes when parsing a comment block decorating
        a code snippet.
    #>
  static [DecoratingCommentsBlockKeyword[]] $Keywords = @(
    [DecoratingCommentsBlockKeywords]::Synopsis
    [DecoratingCommentsBlockKeywords]::Description
    [DecoratingCommentsBlockKeywords]::Example
    [DecoratingCommentsBlockKeywords]::Parameter
    [DecoratingCommentsBlockKeywords]::Exception
  )
}
