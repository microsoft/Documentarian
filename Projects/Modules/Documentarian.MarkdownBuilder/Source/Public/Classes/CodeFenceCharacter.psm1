# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/CodeFenceCharacters.psm1

class CodeFenceCharacter {
    # The code fence character. Valid options are `Backtick` and `Tilde`.
    [CodeFenceCharacters] $Value

    CodeFenceCharacter() {
        <#
            .SYNOPSIS
            Creates a new CodeFenceCharacter object with the backtick character.

            .DESCRIPTION
            Creates a new CodeFenceCharacter object with the backtick character.
        #>

        $this.Value = [CodeFenceCharacters]::Backtick
    }

    CodeFenceCharacter([CodeFenceCharacters] $character) {
        <#
            .SYNOPSIS
            Creates a new CodeFenceCharacter object with the specified character.

            .DESCRIPTION
            Creates a new CodeFenceCharacter object with the specified character.

            .PARAMETER Character
            The character to use for the code fence. Valid options are `Backtick` and `Tilde`.
        #>

        $this.Value = $character
    }

    CodeFenceCharacter([string] $character) {
        <#
            .SYNOPSIS
            Creates a new CodeFenceCharacter object with the specified character.

            .DESCRIPTION
            Creates a new CodeFenceCharacter object with the specified character. You can
            specify the character by its name, such as `Backtick` or `Tilde`. You can also
            specify the character as a literal string, such as `` ` `` or `~`.

            .PARAMETER Character
            The character to use for the code fence. Valid options are listed in the table below:

            | Character | Named String | Literal String |
            | :-------- | :----------: | :------------: |
            | `` ` ``   |   Backtick   |    `` ` ``     |
            | `~`       |    Tilde     |      `~`       |
        #>

        switch ($character) {
            { $_ -in @('Backtick', '`') } {
                $this.Value = [CodeFenceCharacters]::Backtick
            }
            { $_ -in @('Tilde', '~') } {
                $this.Value = [CodeFenceCharacters]::Tilde
            }
            default {
                $Message = @(
                    "Invalid CodeFenceCharacter: '$character'"
                    "Valid options are: 'Backtick', 'Tilde', '``', '~'."
                ) -join ' - '

                throw [System.ArgumentException]::new($Message)
            }
        }
    }

    [string] ToString() {
        <#
            .SYNOPSIS
            Converts the CodeFenceCharacter object to a string.

            .DESCRIPTION
            Converts the CodeFenceCharacter object to a string.
        #>

        switch ($this.Value) {
            Backtick {
                return '`'
            }
            Tilde {
                return '~'
            }
            default {
                throw [System.InvalidOperationException]::new(
                    "Invalid code fence character value '$($this.Character)'"
                )
            }
        }

        return '`'
    }
}
