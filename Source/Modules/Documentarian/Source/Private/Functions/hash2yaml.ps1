# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function hash2yaml {

    [CmdletBinding()]
    param([hashtable]$MetaHash)

    ### This is a naive implementation of a YAML serializer. It is not intended to be a complete
    ### implementation. It converts all members of the hashtable to single-line strings, and does
    ### not support any of the more complex YAML features. It is intended to be used to serialize
    ### the metadata hashtable that is passed to the Markdown template.

    ForEach-Object {
        '---'
        ForEach ($key in ($MetaHash.keys | Sort-Object)) {
            if ('' -ne $MetaHash.$key) {
                '{0}: {1}' -f $key, $MetaHash.$key
            }
        }
        '---'
    }

}
