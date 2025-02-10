# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

BeforeAll {
    $ModuleName = 'Documentarian.ModuleAuthor'
    $SourceModuleRoot = Split-Path -Parent $PSScriptRoot | Split-Path -Parent
    $Module = Get-Module -ListAvailable -Name $ModuleName -ErrorAction SilentlyContinue

    # If the module isn't available, update the PSModulePath and look again
    if ($null -eq $Module) {
        . $SourceModuleRoot/Tools/Update-PSModulePath
        Update-PSModulePath
        $Module = Get-Module -ListAvailable -Name $ModuleName -ErrorAction SilentlyContinue
    }

    # If it still isn't available, build it
    if ($null -eq $Module) {
        Push-Location -Path $SourceModuleRoot
        Invoke-Build -ErrorAction Stop
        Pop-Location
    }

    Import-Module $ModuleName
}

Describe 'Inspecting a source code for HelpInfo' -Tag Acceptance {
    Context 'when the source code defines a class' {
        Context 'with mixed parsing and non-parsing comments' {
            BeforeAll {
                $ClassName = 'HelpInfoTestClassFull'
                $ClassFile = Resolve-Path -Path "$PSScriptRoot/Fixtures/Classes/Full.psm1" |
                    Select-Object -ExpandProperty Path

                $HelpInfo = Resolve-HelpInfo -Path $ClassFile
            }

            It 'the HelpInfo is a ClassHelpInfo object' {
                $HelpInfo | Should -BeOfType [ClassHelpInfo]
            }
            It 'the HelpInfo has the correct Name' {
                $HelpInfo.Name | Should -Be $ClassName
            }
            It "the HelpInfo has a synopsis from the body's parsed comment" {
                $HelpInfo.Synopsis | Should -Not -BeNullOrEmpty
                $HelpInfo.Synopsis | Should -Match 'The synopsis for the class'
            }
            It "the HelpInfo has a description from the body's parsed comment" {
                $HelpInfo.Description | Should -Not -BeNullOrEmpty
            }
            It "the HelpInfo has no notes from the body's parsed comment" {
                $HelpInfo.Notes | Should -BeNullOrEmpty
            }

            Context 'Examples' {
                BeforeAll {
                    $Examples = $HelpInfo.Examples
                }
                It 'has 2 examples' {
                    $Examples.Count | Should -Be 2
                }
                Context 'Example 1' {
                  BeforeAll {
                      $Example = $Examples[0]
                  }
                  It 'has no title' {
                      $Example.Title | Should -BeNullOrEmpty
                  }
                  It 'has a body' {
                      $Example.Body | Should -Not -BeNullOrEmpty
                  }
                }
                Context 'Example 2' {
                    BeforeAll {
                        $Example = $Examples[1]
                    }
                    It 'has a title' {
                        $Example.Title | Should -Be 'Second Example'
                    }
                    It 'has a body' {
                        $Example.Body | Should -Not -BeNullOrEmpty
                    }
                }
            }

            Context 'HelpInfo constructors' {
                It 'has only the default Constructor' {
                    $HelpInfo.Constructors.Count | Should -Be 1
                    $DefaultConstructor = $HelpInfo.Constructors[0]
                    $DefaultSignature = "$ClassName()"
                    $DefaultConstructor.Parameters.Count   | Should -Be 0
                    $DefaultConstructor.Signature.Full     | Should -Be $DefaultSignature
                    $DefaultConstructor.Signature.TypeOnly | Should -Be $DefaultSignature
                }
            }

            Context 'HelpInfo properties' {
                BeforeAll {
                    $Properties = $HelpInfo.Properties
                }
                it 'has 4 properties' {
                    $Properties.Count | Should -Be 4
                }
                context 'First property' {
                    BeforeAll {
                        $Property = $Properties[0]
                    }
                    it 'has a synopsis from the parsed decorating comment block' {
                        $Property.Synopsis | Should -Not -BeNullOrEmpty
                    }
                    it 'has a description from the parsed decorating comment block' {
                        $Property.Description | Should -Not -BeNullOrEmpty
                    }
                    it 'is not hidden' {
                        $Property.IsHidden | Should -Be $false
                    }
                    it 'is not static' {
                        $Property.IsStatic | Should -Be $false
                    }
                    it 'is type System.String' {
                        $Property.Type | Should -Be 'System.String'
                    }
                    it 'has no initial value' {
                        ($null -eq $Property.InitialValue) | Should -Be $true
                    }
                    it 'has only the ValidateNotNullOrEmpty attribute' {
                        $Property.Attributes.Count | Should -Be 1
                        $Property.Attributes |
                        Where-Object Definition -eq '[ValidateNotNullOrEmpty()]' |
                        Should -Not -BeNullOrEmpty
                    }
                }
                context 'Second property' {
                    BeforeAll {
                        $Property = $Properties[1]
                    }

                    it 'has a synopsis from the decorating comment block' {
                        $Property.Synopsis.Trim() | Should -Be 'A one-line block comment for the Second, its Synopsis.'
                    }
                    it 'has a description from the class comment block' {
                        $Property.Description | Should -Not -BeNullOrEmpty
                    }
                    it 'is not hidden' {
                        $Property.IsHidden | Should -Be $false
                    }
                    it 'is static' {
                        $Property.IsStatic | Should -Be $true
                    }
                    it 'is type System.Int32' {
                        $Property.Type | Should -Be 'System.Int32'
                    }
                    it 'has an initial value of 3' {
                        $Property.InitialValue | Should -Be '3'
                    }
                    it 'has no attributes' {
                        $Property.Attributes.Count | Should -Be 0
                    }
                }
                context 'Third property' {
                    BeforeAll {
                        $Property = $Properties[2]
                    }
                    it 'has a synopsis from the decorating comment block' {
                        $Property.Synopsis | Should -Be "The Third property's Synopsis."
                    }
                    it 'has a description from the decorating comment block' {
                        $Property.Description | Should -Be "The Third property's Description."
                    }
                    it 'is hidden' {
                        $Property.IsHidden | Should -Be $true
                    }
                    it 'is not static' {
                        $Property.IsStatic | Should -Be $false
                    }
                    it 'is type System.Int32' {
                        $Property.Type | Should -Be 'System.Int32'
                    }
                    it 'has no initial value' {
                        ($null -eq $Property.InitialValue) | Should -Be $true
                    }
                    it 'has only the ValidateRange attribute' {
                        $Property.Attributes.Count | Should -Be 1
                            $Property.Attributes |
                            Where-Object Definition -eq '[ValidateRange(1, 5)]' |
                            Should -Not -BeNullOrEmpty
                    }
                }
                context 'Fourth property' {
                    BeforeAll {
                        $Property = $Properties[3]
                    }
                    it 'has a synopsis from the class comment block' {
                        $Property.Synopsis | Should -Not -BeNullOrEmpty
                    }
                    it 'has a description from the decorating comment block' {
                        $Property.Description | Should -Be "The Fourth property's Description."
                    }
                    it 'is hidden' {
                        $Property.IsHidden | Should -Be $true
                    }
                    it 'is static' {
                        $Property.IsStatic | Should -Be $true
                    }
                    it 'is type System.String' {
                        $Property.Type | Should -Be 'System.String'
                    }
                    it 'has an initial value of "Default Value"' {
                        $Property.InitialValue | Should -Be "'Default Value'"
                    }
                    it 'has no attributes' {
                        $Property.Attributes.Count | Should -Be 0
                    }
                }
            }

            Context 'HelpInfo methods' {
                BeforeAll {
                    $Methods = $HelpInfo.Methods
                }
                It 'has 3 methods' {
                    $Methods.Count | Should -Be 3
                }
                Context 'DoNothing()' {
                    BeforeAll {
                        $Method = $Methods[0]
                    }

                    it 'has 3 overloads' {
                        $Method.Overloads.Count | Should -Be 3
                    }
                    it 'has a synopsis taken from the first declared overload' {
                        $Method.Synopsis | Should -Not -BeNullOrEmpty
                        $OverloadSynopsis = $Method.Overloads[0].Synopsis
                        $Method.Synopsis | Should -Be $OverloadSynopsis
                    }

                    Context 'DoNothing()' {
                        BeforeAll {
                            $Overload = $Method.Overloads[0]
                            $FullSignature = 'DoNothing()'
                            $TypeSignature = 'DoNothing()'
                        }
                        it 'has a synopsis from the internal parsed decorating comment block' {
                            $Overload.Synopsis | Should -Be 'Synopsis for this overload.'
                        }
                        it 'has a description' {
                            $Overload.Description | Should -Not -BeNullOrEmpty
                        }
                        it 'has no examples' {
                            $Overload.Examples.Count | Should -Be 0
                        }
                        it 'has no exceptions' {
                            $Overload.Exceptions.Count | Should -Be 0
                        }
                        it 'returns System.Void' {
                            $Overload.ReturnType | Should -Be 'System.Void'
                        }
                        it 'is not hidden' {
                            $Overload.IsHidden | Should -Be $false
                        }
                        it 'is not static' {
                            $Overload.IsStatic | Should -Be $false
                        }
                        it 'has the correct signature' {
                            $Overload.Signature.Full | Should -Be $FullSignature
                            $Overload.Signature.TypeOnly | Should -Be $TypeSignature
                        }
                        it 'has no attributes' {
                            $Overload.Attributes.Count | Should -Be 0
                        }
                        it 'has no parameters' {
                            $Overload.Parameters.Count | Should -Be 0
                        }
                    }

                    Context 'DoNothing(System.String)' {
                        BeforeAll {
                            $Overload = $Method.Overloads[1]
                            $FullSignature = 'DoNothing([string]$first)'
                            $TypeSignature = 'DoNothing(System.String)'
                        }
                        it 'has a synopsis from the external parsed decorating comment block' {
                            $Overload.Synopsis | Should -Not -BeNullOrEmpty
                        }
                        it 'has a description from the external parsed decorating comment block' {
                            $Overload.Description | Should -Not -BeNullOrEmpty
                        }
                        it 'has no examples' {
                            $Overload.Examples.Count | Should -Be 0
                        }
                        it 'has no exceptions' {
                            $Overload.Exceptions.Count | Should -Be 0
                        }
                        it 'returns System.Void' {
                            $Overload.ReturnType | Should -Be 'System.Void'
                        }
                        it 'is not hidden' {
                            $Overload.IsHidden | Should -Be $false
                        }
                        it 'is not static' {
                            $Overload.IsStatic | Should -Be $false
                        }
                        it 'has the correct signature' {
                            $Overload.Signature.Full | Should -Be $FullSignature
                            $Overload.Signature.TypeOnly | Should -Be $TypeSignature
                        }
                        it 'has no attributes' {
                            $Overload.Attributes.Count | Should -Be 0
                        }
                        context 'parameters' {
                            BeforeAll {
                                $Parameters = $Overload.Parameters
                            }

                            it 'has 1 parameter' {
                                $Parameters.Count | Should -Be 1
                            }
                            context '[string]$first' {
                                BeforeAll {
                                    $Parameter = $Parameters[0]
                                }
                                it 'is named "first"' {
                                    $Parameter.Name | Should -Be 'first'
                                }
                                it 'is type System.String' {
                                    $Parameter.Type | Should -Be 'System.String'
                                }
                                it "has a description from the overload's decorating comment block" {
                                    $Parameter.Description | Should -Not -BeNullOrEmpty
                                }
                            }
                        }
                    }

                    Context 'DoNothing(System.String, System.Int32)' {
                        BeforeAll {
                            $Overload = $Method.Overloads[2]
                            $FullSignature = 'DoNothing([string]$first, [int]$third)'
                            $TypeSignature = 'DoNothing(System.String, System.Int32)'
                        }
                        it 'has a synopsis from the internal parsed decorating comment block' {
                            $Overload.Synopsis | Should -Not -BeNullOrEmpty
                        }
                        it 'has a description from the internal parsed decorating comment block' {
                            $Overload.Description | Should -Not -BeNullOrEmpty
                        }
                        it 'has no examples' {
                            $Overload.Examples.Count | Should -Be 0
                        }
                        it 'has no exceptions' {
                            $Overload.Exceptions.Count | Should -Be 0
                        }
                        it 'returns System.Void' {
                            $Overload.ReturnType | Should -Be 'System.Void'
                        }
                        it 'is not hidden' {
                            $Overload.IsHidden | Should -Be $false
                        }
                        it 'is not static' {
                            $Overload.IsStatic | Should -Be $false
                        }
                        it 'has the correct signature' {
                            $Overload.Signature.Full | Should -Be $FullSignature
                            $Overload.Signature.TypeOnly | Should -Be $TypeSignature
                        }
                        it 'has no attributes' {
                            $Overload.Attributes.Count | Should -Be 0
                        }
                        context 'parameters' {
                            BeforeAll {
                                $Parameters = $Overload.Parameters
                            }

                            it 'has 2 parameters' {
                                $Parameters.Count | Should -Be 2
                            }
                            context '[string]$first' {
                                BeforeAll {
                                    $Parameter = $Parameters[0]
                                }
                                it 'is named "first"' {
                                    $Parameter.Name | Should -Be 'first'
                                }
                                it 'is type System.String' {
                                    $Parameter.Type | Should -Be 'System.String'
                                }
                                it "has a description from the overload's decorating comment block" {
                                    $Pattern = [Regex]::Escape('The documentation for the `$first` parameter.')
                                    $Parameter.Description | Should -Match $Pattern
                                }
                            }
                            context '[int]$third' {
                                BeforeAll {
                                    $Parameter = $Parameters[1]
                                }
                                it 'is named "third"' {
                                    $Parameter.Name | Should -Be 'third'
                                }
                                it 'is type System.Int32' {
                                    $Parameter.Type | Should -Be 'System.Int32'
                                }
                                it 'has a description from its decorating comment block' {
                                    $Parameter.Description | Should -Not -BeNullOrEmpty
                                }
                            }
                        }
                    }
                }
                Context 'Repeat()' {
                    BeforeAll {
                        $Method = $Methods[1]
                    }

                    it 'has 2 overloads' {
                        $Method.Overloads.Count | Should -Be 2
                    }
                    it 'has a synopsis from the class decorating comment block' {
                        $Method.Synopsis | Should -Not -BeNullOrEmpty
                    }

                    Context 'Repeat(System.String)' {
                        BeforeAll {
                            $Overload = $Method.Overloads[0]
                            $FullSignature = 'Repeat([string]$a)'
                            $TypeSignature = 'Repeat(System.String)'
                        }
                        it 'reuse the synopsis from the method' {
                            $Overload.Synopsis | Should -Not -BeNullOrEmpty
                            $Overload.Synopsis | Should -Be $Method.Synopsis
                        }
                        it 'has no description' {
                            $Overload.Description | Should -BeNullOrEmpty
                        }
                        it 'has no examples' {
                            $Overload.Examples.Count | Should -Be 0
                        }
                        it 'has no exceptions' {
                            $Overload.Exceptions.Count | Should -Be 0
                        }
                        it 'returns System.String' {
                            $Overload.ReturnType | Should -Be 'System.String'
                        }
                        it 'is not hidden' {
                            $Overload.IsHidden | Should -Be $false
                        }
                        it 'is not static' {
                            $Overload.IsStatic | Should -Be $false
                        }
                        it 'has the correct signature' {
                            $Overload.Signature.Full | Should -Be $FullSignature
                            $Overload.Signature.TypeOnly | Should -Be $TypeSignature
                        }
                        it 'has no attributes' {
                            $Overload.Attributes.Count | Should -Be 0
                        }
                        context 'parameters' {
                            BeforeAll {
                                $Parameters = $Overload.Parameters
                            }

                            it 'has 1 parameter' {
                                $Parameters.Count | Should -Be 1
                            }
                            context '[string]$a' {
                                BeforeAll {
                                    $Parameter = $Parameters[0]
                                }
                                it 'is named "a"' {
                                    $Parameter.Name | Should -Be 'a'
                                }
                                it 'is type System.String' {
                                    $Parameter.Type | Should -Be 'System.String'
                                }
                                it 'has no description' {
                                    $Parameter.Description | Should -BeNullOrEmpty
                                }
                            }
                        }
                    }

                    Context 'Repeat(System.String, System.Int32)' {
                        BeforeAll {
                            $Overload = $Method.Overloads[1]
                            $FullSignature = 'Repeat([string]$a, [int]$b)'
                            $TypeSignature = 'Repeat(System.String, System.Int32)'
                        }
                        it "reuses the method's synopsis" {
                            $Overload.Synopsis | Should -Not -BeNullOrEmpty
                            $Overload.Synopsis | Should -Be $Method.Synopsis
                        }
                        it 'has a description from its internal parsed decorating comment block' {
                            $Overload.Description | Should -Not -BeNullOrEmpty
                        }
                        it 'has no examples' {
                            $Overload.Examples.Count | Should -Be 0
                        }
                        it 'has no exceptions' {
                            $Overload.Exceptions.Count | Should -Be 0
                        }
                        it 'returns System.String' {
                            $Overload.ReturnType | Should -Be 'System.String'
                        }
                        it 'is hidden' {
                            $Overload.IsHidden | Should -Be $true
                        }
                        it 'is not static' {
                            $Overload.IsStatic | Should -Be $false
                        }
                        it 'has the correct signature' {
                            $Overload.Signature.Full | Should -Be $FullSignature
                            $Overload.Signature.TypeOnly | Should -Be $TypeSignature
                        }
                        it 'has no attributes' {
                            $Overload.Attributes.Count | Should -Be 0
                        }
                        context 'parameters' {
                            BeforeAll {
                                $Parameters = $Overload.Parameters
                            }

                            it 'has 2 parameters' {
                                $Parameters.Count | Should -Be 2
                            }
                            context '[string]$a' {
                                BeforeAll {
                                    $Parameter = $Parameters[0]
                                }
                                it 'is named "a"' {
                                    $Parameter.Name | Should -Be 'a'
                                }
                                it 'is type System.String' {
                                    $Parameter.Type | Should -Be 'System.String'
                                }
                                it 'has no description' {
                                    $Parameter.Description | Should -BeNullOrEmpty
                                }
                            }
                            context '[int]$b' {
                                BeforeAll {
                                    $Parameter = $Parameters[1]
                                }
                                it 'is named "b"' {
                                    $Parameter.Name | Should -Be 'b'
                                }
                                it 'is type System.Int32' {
                                    $Parameter.Type | Should -Be 'System.Int32'
                                }
                                it 'has no description' {
                                    $Parameter.Description | Should -BeNullOrEmpty
                                }
                            }
                        }
                    }
                }
                Context 'ToUpper()' {
                    BeforeAll {
                        $Method = $Methods[2]
                    }

                    it 'has 1 overloads' {
                        $Method.Overloads.Count | Should -Be 1
                    }
                    it 'has a synopsis from its first overload' {
                        $Method.Synopsis | Should -Not -BeNullOrEmpty
                        $OverloadSynopsis = $Method.Overloads[0].Synopsis
                        $Method.Synopsis | Should -Be $OverloadSynopsis
                    }

                    Context 'ToUpper(System.String)' {
                        BeforeAll {
                            $Overload = $Method.Overloads[0]
                            $FullSignature = 'ToUpper([string]$a)'
                            $TypeSignature = 'ToUpper(System.String)'
                        }
                        it 'has a synopsis from its internal parsed decorating comment block' {
                            $Overload.Synopsis | Should -Not -BeNullOrEmpty
                        }
                        it 'has a description from its internal parsed decorating comment block' {
                            $Overload.Description | Should -Not -BeNullOrEmpty
                        }
                        context 'examples' {
                            BeforeAll {
                                $Examples = $Overload.Examples
                            }

                            it 'has 2 examples' {
                                $Examples.Count | Should -Be 2
                            }
                            context 'Example 1' {
                                BeforeAll {
                                    $Example = $Examples[0]
                                }
                                it 'has no title' {
                                    $Example.Title | Should -BeNullOrEmpty
                                }
                                it 'has a body' {
                                    $Example.Body | Should -Not -BeNullOrEmpty
                                }
                            }
                            context 'Example 2' {
                                BeforeAll {
                                    $Example = $Examples[1]
                                }
                                it 'has a title' {
                                    $Example.Title | Should -Be 'Another Example'
                                }
                                it 'has a body' {
                                    $Example.Body | Should -Not -BeNullOrEmpty
                                }
                            }
                        }
                        context 'exceptions' {
                            BeforeAll {
                                $Exceptions = $Overload.Exceptions
                            }

                            it 'has 1 exception' {
                                $Exceptions.Count | Should -Be 1
                            }
                            context 'System.ArgumentException' {
                                BeforeAll {
                                    $Exception = $Exceptions[0]
                                }
                                it 'is type System.ArgumentException' {
                                    $Exception.Type | Should -Be 'System.ArgumentException'
                                }
                                it 'has a description' {
                                    $Exception.Description | Should -Not -BeNullOrEmpty
                                }
                            }
                        }
                        it 'returns System.String' {
                            $Overload.ReturnType | Should -Be 'System.String'
                        }
                        it 'is not hidden' {
                            $Overload.IsHidden | Should -Be $false
                        }
                        it 'is static' {
                            $Overload.IsStatic | Should -Be $true
                        }
                        it 'has the correct signature' {
                            $Overload.Signature.Full | Should -Be $FullSignature
                            $Overload.Signature.TypeOnly | Should -Be $TypeSignature
                        }
                        it 'has no attributes' {
                            $Overload.Attributes.Count | Should -Be 0
                        }
                        context 'parameters' {
                            BeforeAll {
                                $Parameters = $Overload.Parameters
                            }

                            it 'has 1 parameter' {
                                $Parameters.Count | Should -Be 1
                            }
                            context '[string]$a' {
                                BeforeAll {
                                    $Parameter = $Parameters[0]
                                }
                                it 'is named "a"' {
                                    $Parameter.Name | Should -Be 'a'
                                }
                                it 'is type System.String' {
                                    $Parameter.Type | Should -Be 'System.String'
                                }
                                it "has a description from the overload's parsed decorating comment block" {
                                    $Parameter.Description | Should -Not -BeNullOrEmpty
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
