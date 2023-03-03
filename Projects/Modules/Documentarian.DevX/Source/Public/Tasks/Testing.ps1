# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Synopsis: Define shared Pester configuration for test tasks
task ConfigurePester -Data $PSBoundParameters InitializeDevXConfiguration, {
  $Script:PesterConfiguration = New-PesterConfiguration
  $Script:PesterConfiguration.Output.Verbosity = 'Detailed'
}

# Synopsis: Run unit tests for internal functionality
task Unit -If (!$SkipUnitTests) ConfigurePester, {
  $UnitTestPath = Join-Path -Path $BuildRoot -ChildPath Source
  if (Get-ChildItem -Path $UnitTestPath -Recurse -Include '*.Tests.ps1') {
    $Configuration = $Script:PesterConfiguration
    $Configuration.Run.Path = $UnitTestPath
    $Configuration.Filter.Tag = 'Unit'
    $Configuration.TestResult = @{
      Enabled       = $true
      OutputPath    = Join-Path -Path $BuildRoot -ChildPath "$($Script:DevX.ModuleName).Unit.Results.xml"
      TestSuiteName = $Script:DevX.ModuleName
    }
    Invoke-Pester -Configuration $Configuration
  }
}

# Synopsis: Run acceptance tests on composed module
task Acceptance -If (!$SkipAcceptanceTests) ConfigurePester, {
  $AcceptanceTestPath = Join-Path -Path $BuildRoot -ChildPath Spec
  if (
    (Test-Path -Path $AcceptanceTestPath) -and
    (Get-ChildItem -Path $AcceptanceTestPath -Recurse -Include '*.Tests.ps1')
  ) {
    $Configuration = $Script:PesterConfiguration
    $Configuration.Run.Path = $AcceptanceTestPath
    $Configuration.Filter.Tag = 'Acceptance'
    $Configuration.TestResult = @{
      Enabled       = $true
      OutputPath    = Join-Path -Path $BuildRoot -ChildPath "$($Script:DevX.ModuleName).Acceptance.Results.xml"
      TestSuiteName = $Script:DevX.ModuleName
    }
    Invoke-Pester -Configuration $Configuration
  }
}

# Synopsis: Run all tests; Acceptance disabled for now
task Test ConfigurePester, Unit, Acceptance
