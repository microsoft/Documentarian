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
    Context 'when the source code defines an enum' {
        Context 'with only unparsed decorating comments' {
            BeforeAll {
                $EnumName = 'HelpInfoTestEnumBasic'
                $EnumFile = Resolve-Path -Path "$PSScriptRoot/Fixtures/Enums/Basic.psm1" |
                    Select-Object -ExpandProperty Path

                $HelpInfo = Resolve-HelpInfo -Path $EnumFile
            }

            it 'returns an EnumHelpInfo object' {
                $HelpInfo | Should -BeOfType [EnumHelpInfo]
            }

            it 'has the correct name' {
                $HelpInfo.Name | Should -Be $EnumName
            }

            it 'has a synopsis' {
                $HelpInfo.Synopsis | Should -Not -BeNullOrEmpty
            }

            it 'has no description' {
                $HelpInfo.Description | Should -BeNullOrEmpty
            }

            it 'has no examples' {
                $HelpInfo.Examples | Should -BeNullOrEmpty
            }

            it 'has no notes' {
                $HelpInfo.Notes | Should -BeNullOrEmpty
            }

            it 'is not a flags enum' {
                $HelpInfo.IsFlagsEnum | Should -Be $false
            }

            context 'values' {
                BeforeAll {
                    $Values = $HelpInfo.Values
                }

                it 'has 7 values' {
                    $Values.Count | Should -Be 7
                }

                context 'First' {
                    BeforeAll {
                        $First = $Values[0]
                    }

                    it 'has the correct label' {
                        $First.Label | Should -Be 'First'
                    }

                    it 'has a description' {
                        $First.Description | Should -Not -BeNullOrEmpty
                    }

                    it 'does not have an explicit value' {
                        $First.HasExplicitValue | Should -Be $false
                    }

                    it 'has a Value of 0' {
                        $First.Value | Should -Be 0
                    }
                }

                context 'Second' {
                    BeforeAll {
                        $Second = $Values[1]
                    }

                    it 'has the correct label' {
                        $Second.Label | Should -Be 'Second'
                    }

                    it 'has a description' {
                        $Second.Description | Should -Not -BeNullOrEmpty
                    }

                    it 'does not have an explicit value' {
                        $Second.HasExplicitValue | Should -Be $false
                    }

                    it 'has a Value of 1' {
                        $Second.Value | Should -Be 1
                    }
                }

                context 'Third' {
                    BeforeAll {
                        $Third = $Values[2]
                    }

                    it 'has the correct label' {
                        $Third.Label | Should -Be 'Third'
                    }

                    it 'has a description ' {
                        $Third.Description | Should -Not -BeNullOrEmpty
                    }

                    it 'has an explicit value' {
                        $Third.HasExplicitValue | Should -Be $true
                    }

                    it 'has a Value of 5' {
                        $Third.Value | Should -Be 5
                    }
                }

                context 'Fourth' {
                    BeforeAll {
                        $Fourth = $Values[3]
                    }

                    it 'has the correct label' {
                        $Fourth.Label | Should -Be 'Fourth'
                    }

                    it 'has a description from a comment beside it.' {
                        $Expected = 'A one-line comment block decorating the Fourth value.'
                        $Fourth.Description | Should -Be $Expected
                    }

                    it 'has an explicit value' {
                        $Fourth.HasExplicitValue | Should -Be $true
                    }

                    it 'has a Value of 7' {
                        $Fourth.Value | Should -Be 7
                    }
                }

                context 'Fifth' {
                    BeforeAll {
                        $Fifth = $Values[4]
                    }

                    it 'has the correct label' {
                        $Fifth.Label | Should -Be 'Fifth'
                    }

                    it 'has a description from multiple comments above it' {
                        $Expected = 'A multi-line set of comments documenting the Fifth value.'
                        $Lines = $Fifth.Description -split '\r?\n'
                        $Lines[0] | Should -Be $Expected
                        $Lines.Count | Should -Be 5
                    }

                    it 'does not have an explicit value' {
                        $Fifth.HasExplicitValue | Should -Be $false
                    }

                    it 'has a Value of 8' {
                        $Fifth.Value | Should -Be 8
                    }
                }

                context 'Sixth' {
                    BeforeAll {
                        $Sixth = $Values[5]
                    }

                    it 'has the correct label' {
                        $Sixth.Label | Should -Be 'Sixth'
                    }

                    it 'has a description from the comment block above it' {
                        $Expected = 'A one-line comment block decorating the Sixth Value.'
                        $Sixth.Description | Should -Be $Expected
                    }

                    it 'does not have an explicit value' {
                        $Sixth.HasExplicitValue | Should -Be $false
                    }

                    it 'has a Value of 9' {
                        $Sixth.Value | Should -Be 9
                    }
                }

                context 'Seventh' {
                    BeforeAll {
                        $Seventh = $Values[6]
                    }

                    it 'has the correct label' {
                        $Seventh.Label | Should -Be 'Seventh'
                    }

                    it 'has no description' {
                        $Seventh.Description | Should -BeNullOrEmpty
                    }

                    it 'has an explicit value' {
                        $Seventh.HasExplicitValue | Should -Be $true
                    }

                    it 'has a Value of 11' {
                        $Seventh.Value | Should -Be 11
                    }
                }
            }
        }
    }
}