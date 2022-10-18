# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/ParsedDocument.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/New-ParsedDocument.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Get-Document {
  [CmdletBinding()]
  [OutputType([ParsedDocument])]
  param(
    [string[]]$Path
  )

  begin {
    $Pipeline = New-Object -TypeName Markdig.MarkdownPipelineBuilder
    $Pipeline = [Markdig.MarkdownExtensions]::Configure($Pipeline, 'Advanced+Yaml')
  }

  process {
    $Files = Get-Item -Path $Path
    if ($Files.PSIsContainer) {
      $Files = Get-ChildItem -Path $Path -Recurse | Where-Object -FilterScript {
        $_.Extension -eq '.md'
      }
    }

    foreach ($File in $Files) {
      if ($File.Extension -ne '.md') {
        continue
      }
      $ParsedDocumentParameters = @{
        FileInfo = $File
      }
      $ParsedDocumentParameters.RawContent = Get-Content -Path $File.FullName -Raw
      if ($ParsedDocumentParameters.RawContent.Length -gt 0) {
        $ParsedDocumentParameters.ParsedMarkdown = [Markdig.Parsers.MarkdownParser]::Parse(
          $ParsedDocumentParameters.RawContent, $Pipeline.Build()
        )
      } else {
        $ParsedDocumentParameters.ParsedMarkdown = $null
      }

      $FrontMatterToken = $ParsedDocumentParameters.ParsedMarkdown | Where-Object -FilterScript {
        $_.Parser -is [Markdig.Extensions.Yaml.YamlFrontMatterParser]
      }

      if ($FrontMatterToken) {
        $ParsedDocumentParameters.FrontMatter = $FrontMatterToken.Lines.ToString().Trim()
        | ConvertFrom-Yaml -Ordered

        $Body = $ParsedDocumentParameters.RawContent -split '---'
        | Select-Object -Skip 2
        | Join-String -Separator '---'
        $ParsedDocumentParameters.Body = $Body.TrimStart()
      } else {
        $ParsedDocumentParameters.Body = $ParsedDocumentParameters.RawContent
      }

      New-ParsedDocument @ParsedDocumentParameters
    }
  }
}
