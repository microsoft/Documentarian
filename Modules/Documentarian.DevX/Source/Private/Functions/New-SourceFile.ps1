using module ../../Public/Classes/SourceFile.psm1

function New-SourceFile {
  [CmdletBinding()]
  [OutputType([SourceFile])]
  param(
    [string]$NameSpace,
    [string]$Path
  )

  process {
    [SourceFile]::new($NameSpace, $Path)
  }
}
