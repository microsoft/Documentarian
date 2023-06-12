# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Generic
using namespace System.Collections.Specialized
using module ./DecoratingComments.psm1
using module ./DecoratingCommentsBlockKeyword.psm1
using module ./DecoratingCommentsBlockKeywords.psm1
using module ./DecoratingCommentsBlockSchema.psm1
using module ./Schemas/DecoratingCommentsBlockSchemasClass.psm1
using module ./Schemas/DecoratingCommentsBlockSchemasClassOverload.psm1
using module ./Schemas/DecoratingCommentsBlockSchemasClassProperty.psm1
using module ./Schemas/DecoratingCommentsBlockSchemasDefault.psm1
using module ./Schemas/DecoratingCommentsBlockSchemasEnum.psm1

class DecoratingCommentsRegistry {
    [List[DecoratingCommentsBlockKeyword]] $Keywords

    [List[DecoratingCommentsBlockSchema]] $Schemas

    DecoratingCommentsRegistry() {
        $this.Initialize()
    }

    DecoratingCommentsRegistry([DecoratingCommentsBlockSchema[]]$schemas) {
        $this.Initialize($schemas)
    }

    DecoratingCommentsRegistry(
        [DecoratingCommentsBlockSchema[]]$schemas,
        [DecoratingCommentsBlockKeyword[]]$keywords
    ) {
        $this.Initialize($schemas, $keywords)
    }

    DecoratingCommentsRegistry([bool]$withoutDefaults) {
        if ($withoutDefaults) {
            $this.InitializeLists()
        } else {
            $this.Initialize()
        }
    }

    DecoratingCommentsRegistry([DecoratingCommentsBlockSchema[]]$schemas, [bool]$withoutDefaults) {
        if ($withoutDefaults) {
            $this.InitializeWithoutDefaults($schemas)
        } else {
            $this.Initialize($schemas)
        }
    }

    DecoratingCommentsRegistry(
        [DecoratingCommentsBlockSchema[]]$schemas,
        [DecoratingCommentsBlockKeyword[]]$keywords,
        [bool]$withoutDefaults
    ) {
        if ($withoutDefaults) {
            $this.InitializeWithoutDefaults($schemas, $keywords)
        } else {
            $this.Initialize($schemas, $keywords)
        }
    }

    [void] InitializeLists() {
        $this.InitializeLists($false)
    }

    [void] InitializeLists([boolean]$force) {
        if ($null -eq $this.Keywords -or $force) {
            $this.Keywords = [List[DecoratingCommentsBlockKeyword]]::new()
            $this.Keywords.Add([DecoratingCommentsBlockKeywords]::Schema)
        }
        if ($null -eq $this.Schemas -or $force) {
            $this.Schemas = [List[DecoratingCommentsBlockSchema]]::new()
        }
    }

    [void] Initialize() {
        $this.InitializeLists()

        $this.RegisterDefaultSchemas()
        $this.RegisterDefaultKeywords()
    }

    [void] Initialize([DecoratingCommentsBlockSchema[]]$schemas) {
        $this.InitializeLists()

        $this.RegisterDefaultSchemas()

        $schemas | ForEach-Object -Process {
            $this.RegisterSchema($_, $true)
        }

        $this.RegisterDefaultKeywords()
    }

    [void] Initialize(
        [DecoratingCommentsBlockSchema[]]$schemas,
        [DecoratingCommentsBlockKeyword[]]$keywords
    ) {
        $this.InitializeLists()

        $this.RegisterDefaultSchemas()

        $schemas | ForEach-Object -Process {
            $this.RegisterSchema($_, $true)
        }

        $this.RegisterDefaultKeywords()

        $keywords | ForEach-Object -Process {
            $this.RegisterKeyword($_, $true)
        }
    }

    [void] InitializeWithoutDefaults() {
        $this.InitializeLists()
    }

    [void] InitializeWithoutDefaults([DecoratingCommentsBlockSchema[]]$schemas) {
        $this.InitializeLists()

        $schemas | ForEach-Object -Process {
            $this.RegisterSchema($_, $true)
        }
    }

    [void] InitializeWithoutDefaults(
        [DecoratingCommentsBlockSchema[]]$schemas,
        [DecoratingCommentsBlockKeyword[]]$keywords
    ) {
        $this.InitializeLists()

        $schemas | ForEach-Object -Process {
            $this.RegisterSchema($_)
        }

        $keywords | ForEach-Object -Process {
            $this.RegisterKeyword($_, $true)
        }
    }

    [void] Initialize([bool]$force) {
        $this.InitializeLists($force)

        $this.RegisterDefaultSchemas()
        $this.RegisterDefaultKeywords()
    }

    [void] Initialize([DecoratingCommentsBlockSchema[]]$schemas, [bool]$force) {
        $this.InitializeLists($force)

        $this.RegisterDefaultSchemas()

        $schemas | ForEach-Object -Process {
            $this.RegisterSchema($_, $true)
        }

        $this.RegisterDefaultKeywords()
    }

    [void] Initialize(
        [DecoratingCommentsBlockSchema[]]$schemas,
        [DecoratingCommentsBlockKeyword[]]$keywords,
        [bool]$force
    ) {
        $this.InitializeLists($force)

        $this.RegisterDefaultSchemas()

        $schemas | ForEach-Object -Process {
            $this.RegisterSchema($_, $true)
        }

        $this.RegisterDefaultKeywords()

        $keywords | ForEach-Object -Process {
            $this.RegisterKeyword($_, $true)
        }
    }

    [void] InitializeWithoutDefaults([bool]$force) {
        $this.InitializeLists($force)
    }

    [void] InitializeWithoutDefaults([DecoratingCommentsBlockSchema[]]$schemas, [bool]$force) {
        $this.InitializeLists($force)

        $schemas | ForEach-Object -Process {
            $this.RegisterSchema($_, $true)
        }
    }

    [void] InitializeWithoutDefaults(
        [DecoratingCommentsBlockSchema[]]$schemas,
        [DecoratingCommentsBlockKeyword[]]$keywords,
        [bool]$force
    ) {
        $this.InitializeLists($force)

        $schemas | ForEach-Object -Process {
            $this.RegisterSchema($_)
        }

        $keywords | ForEach-Object -Process {
            $this.RegisterKeyword($_, $true)
        }
    }

    [string] GetCommentSchemaValue([string]$comment) {
        $SchemaKeyword = $this.GetSchemaKeyword()

        return [DecoratingCommentsBlockSchema]::GetKeywordValue($SchemaKeyword.Pattern, $comment)
    }

    static [DecoratingCommentsRegistry] Get() {
        if ($null -ne [DecoratingCommentsRegistry]::Global) {
            return [DecoratingCommentsRegistry]::Global
        }
        return [DecoratingCommentsRegistry]::new()
    }

    static [DecoratingCommentsRegistry] $Global = $Global:ModuleAuthorDecoratingCommentsRegistry

    [DecoratingCommentsBlockSchema] GetDefaultSchema() {
        if ($RegisteredDefaultSchema = $this.GetRegisteredSchema('Default')) {
            return $RegisteredDefaultSchema
        }

        return [DecoratingCommentsBlockSchemasDefault]::new()
    }

    [DecoratingCommentsBlockSchema[]] GetEnumeratedRegisteredSchemas() {
        return $this.Schemas
    }

    [DecoratingCommentsBlockKeyword[]] GetEnumeratedRegisteredKeywords() {
        return $this.Keywords
    }

    [DecoratingCommentsBlockKeyword] GetRegisteredKeyword([string]$name) {
        return $this.Keywords | Where-Object -FilterScript {
            $_.Name -eq $name
        } | Select-Object -First 1
    }

    [DecoratingCommentsBlockSchema] GetRegisteredSchema([string]$schemaValue) {
        if ($AliasedSchema = $this.GetRegisteredSchemaByAlias($schemaValue)) {
            return $AliasedSchema
        }
        if ($NamedSchema = $this.GetRegisteredSchemaByName($schemaValue)) {
            return $NamedSchema
        }

        return $null
    }

    [DecoratingCommentsBlockSchema] GetRegisteredSchemaByName([string]$schemaValue) {
        return $this.GetReversedSchemaArray() | Where-Object {
            ($_.GetName() -eq $schemaValue)
        } | Select-Object -First 1
    }

    [DecoratingCommentsBlockSchema] GetRegisteredSchemaByAlias([string]$schemaValue) {
        return $this.GetReversedSchemaArray() | Where-Object {
            $schemaValue -in $_.GetAliases()
        } | Select-Object -First 1
    }

    [DecoratingCommentsBlockSchema] GetRegisteredSchemaFromAst([ast]$decoratedAst) {
        switch ($decoratedAst) {
            { $_ -is [TypeDefinitionAst] -and $_.IsEnum } {
                return $this.GetRegisteredSchema('Enum')
            }
            { $_ -is [TypeDefinitionAst] -and $_.IsClass } {
                return $this.GetRegisteredSchema('Class')
            }
            { $_ -is [PropertyMemberAst] -and $_.Parent.IsEnum } {
                return $this.GetRegisteredSchema('EnumValue')
            }
            { $_ -is [PropertyMemberAst] -and $_.Parent.IsClass } {
                return $this.GetRegisteredSchema('ClassProperty')
            }
            { $_ -is [FunctionMemberAst] -and $_.IsConstructor } {
                return $this.GetRegisteredSchema('ClassConstructor')
            }
            { $_ -is [FunctionMemberAst] -and !$_.IsConstructor } {
                return $this.GetRegisteredSchema('ClassMethod')
            }
        }

        return $null
    }

    [DecoratingCommentsBlockSchema] GetRegisteredSchemaFromCommentBlock([string]$comment) {
        $Value = $this.GetCommentSchemaValue($comment)

        if ($Value -match '\S+') {
            return $this.GetRegisteredSchema($Value)
        }

        return $null
    }

    [DecoratingCommentsBlockKeyword] GetSchemaKeyword() {
        if ($RegisteredSchemaKeyword = $this.GetRegisteredKeyword('Schema')) {
            return $RegisteredSchemaKeyword
        }

        return [DecoratingCommentsBlockKeywords]::Schema
    }

    [string[]] GetRegisteredSchemaNames() {
        return $this.Schemas | ForEach-Object -Process { $_.GetName() }
    }

    [OrderedDictionary] FindAndParseCommentBlock(
        [Ast]$targetAst,
        [Token[]]$tokens
    ) {
        return $this.FindAndParseCommentBlock($targetAst, $tokens, $null)
    }

    [OrderedDictionary] FindAndParseCommentBlock(
        [Ast]$targetAst,
        [Token[]]$tokens,
        [string]$schemaName
    ) {
        $comment = [DecoratingComments]::FindDecoratingCommentBlock($targetAst, $tokens)

        if ($null -eq $comment) {
            return $null
        }

        return $this.ParseDecoratingCommentBlock($comment, $schemaName, $targetAst)
    }

    [OrderedDictionary] ParseDecoratingCommentBlock([string]$comment) {
        $Schema = $this.SelectSchema($comment)
        return $Schema.Parse($comment)
    }

    [OrderedDictionary] ParseDecoratingCommentBlock([string]$comment, [string]$schemaName) {
        $Schema = $this.SelectSchema($comment, $schemaName)
        return $Schema.Parse($comment)
    }

    [OrderedDictionary] ParseDecoratingCommentBlock([string]$comment, [ast]$decoratedAst) {
        $Schema = $this.SelectSchema($comment, $decoratedAst)
        return $Schema.Parse($comment)
    }

    [OrderedDictionary] ParseDecoratingCommentBlock(
        [string]$comment,
        [string]$schemaName,
        [ast]$decoratedAst
    ) {
        $Schema = $this.SelectSchema($comment, $schemaName, $decoratedAst)
        return $Schema.Parse($comment)
    }

    [void] RegisterDefaultKeywords() {
        $this.RegisterDefaultKeywords($false)
    }

    [void] RegisterDefaultKeywords([bool]$force) {
        $this.InitializeLists()

        [DecoratingCommentsRegistry]::BuiltInKeywords | ForEach-Object -Process {
            $this.RegisterKeyword($_, $force)
        }
    }

    [void] RegisterKeyword([DecoratingCommentsBlockKeyword]$keyword) {
        $this.RegisterKeyword($keyword, $false, $false)
    }

    [void] RegisterKeyword([DecoratingCommentsBlockKeyword]$keyword, [bool]$force) {
        $this.RegisterKeyword($keyword, $force, $false)
    }

    [DecoratingCommentsBlockKeyword] RegisterKeyword(
        [DecoratingCommentsBlockKeyword]$keyword,
        [bool]$force,
        [bool]$passThru
    ) {
        $this.InitializeLists()

        $IsRegistered = $false
        if ($keyword.Name -notin $this.Keywords.Name) {
            $this.Keywords.Add($keyword)
            $IsRegistered = $true
        } elseif ($force) {
            $index = $this.Keywords.FindIndex({ $args[0].Name -eq $keyword.Name })
            $this.Keywords[$index] = $keyword
            $IsRegistered = $true
        }

        if ($passThru -and $IsRegistered) {
            return $keyword
        }

        return $null
    }

    [void] RegisterKeywords([DecoratingCommentsBlockKeyword[]]$keywords) {
        $this.RegisterKeywords($keywords, $false, $false)
    }

    [void] RegisterKeywords([DecoratingCommentsBlockKeyword[]]$keywords, [bool]$force) {
        $this.RegisterKeywords($keywords, $force, $false)
    }

    [DecoratingCommentsBlockKeyword[]] RegisterKeywords(
        [DecoratingCommentsBlockKeyword[]]$keywords,
        [bool]$force,
        [bool]$passThru
    ) {
        $this.InitializeLists()

        if ($passThru) {
            [DecoratingCommentsBlockKeyword[]]$RegisteredKeywords = @()
            foreach ($keyword in $keywords) {
                if ($RegisteredKeyword = $this.RegisterKeyword($keyword, $force, $passThru)) {
                    $RegisteredKeywords += $RegisteredKeyword
                }
            }
            return $RegisteredKeywords
        }

        foreach ($keyword in $keywords) {
            $this.RegisterKeyword($keyword, $force)
        }

        return ([DecoratingCommentsBlockKeyword[]]@())
    }

    [void] RegisterDefaultSchemas() {
        $this.RegisterDefaultSchemas($false)
    }

    [void] RegisterDefaultSchemas([bool]$force) {
        $this.InitializeLists()

        [DecoratingCommentsRegistry]::BuiltInSchemas | ForEach-Object -Process {
            $this.RegisterSchema($_, $force)
        }
    }

    [void] RegisterSchema([DecoratingCommentsBlockSchema]$schema) {
        $this.RegisterSchema($schema, $false, $false)
    }

    [void] RegisterSchema([DecoratingCommentsBlockSchema]$schema, [bool]$force) {
        $this.RegisterSchema($schema, $force, $false)
    }

    [DecoratingCommentsBlockSchema] RegisterSchema(
        [DecoratingCommentsBlockSchema]$schema,
        [bool]$force,
        [bool]$passThru
    ) {
        $this.InitializeLists()

        $IsSchemaNew = $schema.GetName() -notin $this.GetRegisteredSchemaNames()
        $RegisteredSchema = $false

        if ($IsSchemaNew) {
            $this.Schemas.Add($schema)
            $RegisteredSchema = $true
        } elseif ($force) {
            $index = $this.Schemas.FindIndex({
                ($args[0] -as [DecoratingCommentsBlockSchema]).GetName() -eq $schema.GetName()
            })
            $this.Schemas[$index] = $schema
            $RegisteredSchema = $true
        }

        if ($IsSchemaNew -or $force) {
            $this.RegisterKeywords($schema.GetKeywords(), $force)
        }

        if ($passThru -and $RegisteredSchema) {
            return $schema
        }

        return $null
    }

    [void] RegisterSchemas([DecoratingCommentsBlockSchema[]]$schemas) {
        $this.RegisterSchemas($schemas, $false)
    }

    [void] RegisterSchemas([DecoratingCommentsBlockSchema[]]$schemas, [bool]$force) {
        $this.InitializeLists()

        foreach ($schema in $schemas) {
            $this.RegisterSchema($schema, $force)
        }
    }

    [DecoratingCommentsBlockSchema[]] RegisterSchemas(
        [DecoratingCommentsBlockSchema[]]$schemas,
        [bool]$force,
        [bool]$passThru
    ) {
        $this.InitializeLists()

        if ($passThru) {
            [DecoratingCommentsBlockSchema[]]$RegisteredSchemas = @()
            foreach ($schema in $schemas) {
                if ($RegisteredSchema = $this.RegisterSchema($schema, $force, $passThru)) {
                    $RegisteredSchemas += $RegisteredSchema
                }
            }
            return $RegisteredSchemas
        }

        foreach ($schema in $schemas) {
            $this.RegisterSchema($schema, $force)
        }

        return ([DecoratingCommentsBlockSchema[]]@())
    }

    [DecoratingCommentsBlockSchema] SelectSchema([string]$comment) {
        return $this.SelectSchema($comment, $null, $null)
    }

    [DecoratingCommentsBlockSchema] SelectSchema([string]$comment, [string]$schemaName) {
        return $this.SelectSchema($comment, $schemaName, $null)
    }

    [DecoratingCommentsBlockSchema] SelectSchema([string]$comment, [ast]$decoratedAst) {
        return $this.SelectSchema($comment, $null, $decoratedAst)
    }

    [DecoratingCommentsBlockSchema] SelectSchema(
        [string]$comment,
        [string]$schemaName,
        [ast]$decoratedAst
    ) {
        $CommentSchemaValue = $this.GetCommentSchemaValue($comment)
        if ($CommentSchemaValue -match '\S+') {
            if ($SelectedSchema = $this.GetRegisteredSchema($CommentSchemaValue)) {
                return $SelectedSchema
            }
        }

        if ($schemaName -match '\S+') {
            if ($SelectedSchema = $this.GetRegisteredSchemaByName($schemaName)) {
                return $SelectedSchema
            }
        }

        if ($null -ne $decoratedAst) {
            if ($SelectedSchema = $this.GetRegisteredSchemaFromAst($decoratedAst)) {
                return $SelectedSchema
            }
        }

        return $this.GetDefaultSchema()
    }

    [DecoratingCommentsBlockSchema] SelectSchemaByName([string]$schemaName) {
        if ($SelectedSchema = $this.GetRegisteredSchema($schemaName)) {
            return $SelectedSchema
        }

        return $this.GetDefaultSchema()
    }

    [DecoratingCommentsBlockSchema] SelectSchemaFromAst([ast]$decoratedAst) {
        if ($SelectedSchema = $this.GetRegisteredSchemaFromAst($decoratedAst)) {
            return $SelectedSchema
        }

        return $this.GetDefaultSchema()
    }

    [DecoratingCommentsBlockSchema] SelectSchemaFromCommentBlock([string]$comment) {
        if ($SelectedSchema = $this.GetRegisteredSchemaFromCommentBlock($comment)) {
            return $SelectedSchema
        }

        return $this.GetDefaultSchema()
    }

    [bool] UnregisterKeyword([string]$name) {
        $keyword = $this.GetRegisteredKeyword($name)
        return $this.UnregisterKeyword($keyword)
    }

    [bool] UnregisterKeyword([DecoratingCommentsBlockKeyword]$keyword) {
        return $this.Keywords.Remove($keyword)
    }

    [bool] UnregisterSchema([string]$schemaValue) {
        $schema = $this.GetRegisteredSchema($schemaValue)
        return $this.UnregisterSchema($schema)
    }

    [bool] UnregisterSchema([DecoratingCommentsBlockSchema]$schema) {
        return $this.Schemas.Remove($schema)
    }

    [bool] UnregisterSchemaByAlias([string]$alias) {
        $schema = $this.GetRegisteredSchemaByAlias($alias)
        return $this.UnregisterSchema($schema)
    }

    [bool] UnregisterSchemaByName([string]$name) {
        $schema = $this.GetRegisteredSchemaByName($name)
        return $this.UnregisterSchema($schema)
    }

    hidden [DecoratingCommentsBlockSchema[]] GetReversedSchemaArray() {
        $SchemaArray = $this.Schemas -as [DecoratingCommentsBlockSchema[]]
        [array]::Reverse($SchemaArray)
        return $SchemaArray
    }

    static [DecoratingCommentsBlockSchema[]]
    $BuiltInSchemas = @(
        [DecoratingCommentsBlockSchemasDefault]::new()
        [DecoratingCommentsBlockSchemasClass]::new()
        [DecoratingCommentsBlockSchemasClassOverload]::new()
        [DecoratingCommentsBlockSchemasClassProperty]::new()
        [DecoratingCommentsBlockSchemasEnum]::new()
    )

    static [DecoratingCommentsBlockSchema] GetBuiltInSchema([string]$schema) {
        return [DecoratingCommentsRegistry]::GetBuiltInSchemas($schema) | Select-Object -First 1
    }

    static [DecoratingCommentsBlockSchema] GetBuiltInSchemas([string]$schema) {
        return [DecoratingCommentsRegistry]::BuiltInSchemas | Where-Object {
            ($_.GetName() -eq $schema) -or ($schema -in $_.GetAliases())
        }
    }

    static [DecoratingCommentsBlockKeyword[]]
    $BuiltInKeywords = [DecoratingCommentsRegistry]::GetBuiltInKeywords()

    static [DecoratingCommentsBlockKeyword] GetBuiltInKeyword([string]$keyword) {
        return [DecoratingCommentsRegistry]::GetBuiltInKeywords($keyword) | Select-Object -First 1
    }

    static [DecoratingCommentsBlockKeyword[]] GetBuiltInKeywords([string]$keyword) {
        return [DecoratingCommentsRegistry]::BuiltInKeywords | Where-Object {
            ($_.Name -eq $keyword)
        }
    }

    hidden static [DecoratingCommentsBlockKeyword[]] GetBuiltInKeywords() {
        return [DecoratingCommentsBlockKeywords].GetProperties() | Where-Object -FilterScript {
            ($_.PropertyType.FullName -eq [DecoratingCommentsBlockKeyword].FullName)
        } | ForEach-Object {
            $_.GetGetMethod().Invoke($null, $null)
        }
    }
}
