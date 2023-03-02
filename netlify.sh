# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
#! /usr/bin/bash

# Download the powershell '.tar.gz' archive
curl -L -o /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v7.3.3/powershell-7.3.3-linux-x64.tar.gz
mkdir pwsh
tar zxf /tmp/powershell.tar.gz -C ./pwsh
chmod +x ./pwsh/pwsh

./pwsh/pwsh -command "Install-Module -Name InvokeBuild -Repository PSGallery -Force"
./pwsh/pwsh -command "Invoke-Build -Task BuildSite"
