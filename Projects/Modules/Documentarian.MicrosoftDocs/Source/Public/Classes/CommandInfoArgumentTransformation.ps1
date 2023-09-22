# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation

class CommandInfoArgumentTransformation : ArgumentTransformationAttribute {
    [Object] Transform([EngineIntrinsics] $engineIntrinsics, [Object] $inputData) {
        $transformedCommands = foreach ($command in $inputData) {
            $cmd = $command

            if ($command -isnot [CommandInfo]) {
                $cmd = $engineIntrinsics.InvokeCommand.GetCommand(
                    [string] $command,
                    [CommandTypes]::All)
            }

            if (-not $cmd) {
                throw [CommandNotFoundException]::new("Unable to find command '$command'.")
            }

            if ($cmd.CommandType -eq [CommandTypes]::Alias) {
                $cmd.ResolvedCommand
                continue
            }

            $cmd
        }

        return $transformedCommands
    }
}
