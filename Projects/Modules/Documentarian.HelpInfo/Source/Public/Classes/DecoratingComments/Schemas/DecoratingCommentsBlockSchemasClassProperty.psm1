# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../DecoratingCommentsBlockKeyword.psm1
using module ../DecoratingCommentsBlockKeywords.psm1
using module ../DecoratingCommentsBlockSchema.psm1

class DecoratingCommentsBlockSchemasClassProperty : DecoratingCommentsBlockSchema {
    <#
        .SYNOPSIS
        Represents the schema for a comment decorating a class property.

        .DESCRIPTION
        This class represents the schema for a block comment that decorates the
        member definition of an class property in PowerShell code.

        It parses the following keywords from the decorating comment:

        - `Synopsis` - A brief description of the property's purpose. The
          keyword must have a block of text after it.
        - `Description` - A full description of the property, with details.
          The keyword must have a block of text after it.
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
    static [string] $Name = 'ClassProperty'

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
    )
}
