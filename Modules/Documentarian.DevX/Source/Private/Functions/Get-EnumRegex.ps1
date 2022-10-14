function Get-EnumRegex {
  [CmdletBinding()]
  [OutputType([String])]
  param(
    [Parameter(Mandatory)]
    [ValidateScript({ $_.IsEnum })]
    [Type]$EnumType
  )

  "(?<$($EnumType.Name)>($($EnumType.GetEnumNames() -join '|')))"
}
