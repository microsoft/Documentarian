# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation

class CommandInfoArgumentTransformation : ArgumentTransformationAttribute {
    [Object] Transform([EngineIntrinsics] $engineIntrinsics, [Object] $inputData) {
        $cmd = $inputData

        if ($inputData -isnot [CommandInfo]) {
            $cmd = $engineIntrinsics.InvokeCommand.GetCommand(
                [string] $inputData,
                [CommandTypes]::All)
        }

        if (-not $cmd) {
            throw [CommandNotFoundException]::new("Unable to find command '$inputData'.")
        }

        if ($cmd.CommandType -eq [CommandTypes]::Alias) {
            return $cmd.ResolvedCommand
        }

        return $cmd
    }
}
