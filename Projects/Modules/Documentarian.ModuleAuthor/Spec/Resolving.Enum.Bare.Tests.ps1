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
        Context 'without any comments' {
            BeforeAll {
                $EnumName = 'HelpInfoTestEnumBare'
                $EnumFile = Resolve-Path -Path "$PSScriptRoot/Fixtures/Enums/Bare.psm1" |
                    Select-Object -ExpandProperty Path

                $HelpInfo = Resolve-HelpInfo -Path $EnumFile
            }

            it 'returns an EnumHelpInfo object' {
                $HelpInfo | Should -BeOfType [EnumHelpInfo]
            }

            it 'has the correct name' {
                $HelpInfo.Name | Should -Be 'HelpInfoTestEnumBare'
            }

            it 'has no synopsis' {
                $HelpInfo.Synopsis | Should -BeNullOrEmpty
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

                    it 'has no description' {
                        $First.Description | Should -BeNullOrEmpty
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

                    it 'has no description' {
                        $Second.Description | Should -BeNullOrEmpty
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

                    it 'has no description' {
                        $Third.Description | Should -BeNullOrEmpty
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

                    it 'has no description' {
                        $Fourth.Description | Should -BeNullOrEmpty
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

                    it 'has no description' {
                        $Fifth.Description | Should -BeNullOrEmpty
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

                    it 'has no description' {
                        $Sixth.Description | Should -BeNullOrEmpty
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