# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/BulletListStyle.psm1
using module ../Classes/MarkdownList.psm1

class BulletList : MarkdownList {

    static
    [BulletListStyle]
    $DefaultStyle = [BulletListStyle]::Hyphen

    [BulletListStyle]
    $Style

    [string[]]
    $Items

    hidden Initialize([hashtable]$properties) {
        <#
            .SYNOPSIS
                Initializes the BulletList object with default values.

            .DESCRIPTION
                Initializes the BulletList object with default values, setting the instance
                **Style** to the value of the **DefaultStyle** static property and the **Items**
                property an empty array.

                This method is called by the constructors of the class before overriding these
                defaults, if necessary.
        #>

        $this.Style = [BulletList]::DefaultStyle
        $this.Items = @()

        foreach ($key in $properties.Keys) {
            $this.$key = $properties[$key]
        }
    }

    BulletList() {
        <#
            .SYNOPSIS
                Creates a new BulletList object with default values.

            .DESCRIPTION
                Creates a new BulletList object with default values. An instance of this class is
                used to render items in a Markdown bullet list, handling indentation and bullet
                style.
        #>

        $this.Initialize(@{})
    }

    BulletList([string[]]$items) {
        <#
            .SYNOPSIS
                Creates a new BulletList object with the specified items.

            .DESCRIPTION
                Creates a new BulletList object with the specified items. An instance of this class
                is used to render items in a Markdown bullet list, handling indentation and bullet
                style.

                Use this constructor when creating a top-level list. The style of the list is used
                to determine the bullet style for the text.

            .PARAMETER items
                The items to add to the bullet list.
        #>

        $this.Initialize(@{ Items = $items })
    }

    BulletList([BulletListStyle]$Style) {
        <#
            .SYNOPSIS
                Creates a new BulletList object with the specified style.

            .DESCRIPTION
                Creates a new BulletList object with the specified style. An instance of this class
                is used to render items in a Markdown bullet list, handling indentation and bullet
                style.

                Use this constructor when creating a top-level list. The style of the list is used
                to determine the bullet style for the text.

            .PARAMETER Style
                The style of the bullet list. Valid styles include:

                  - `Hyphen`
                  - `Plus`
                  - `Asterisk`

                The default style is `Hyphen`.
        #>

        $this.Initialize(@{ Style = $Style })
    }

    BulletList([string[]]$items, [BulletListStyle]$Style) {
        <#
            .SYNOPSIS
                Creates a new BulletList object with the specified items and style.

            .DESCRIPTION
                Creates a new BulletList object with the specified items and style. An instance of
                this class is used to render items in a Markdown bullet list, handling indentation
                and bullet style.

                Use this constructor when creating a top-level list. The style of the list is used
                to determine the bullet style for the text.

            .PARAMETER items
                The items to add to the bullet list.

            .PARAMETER Style
                The style of the bullet list. Valid styles include:

                  - `Hyphen`
                  - `Plus`
                  - `Asterisk`

                The default style is `Hyphen`.
        #>

        $this.Initialize(@{
                Items = $items
                Style = $Style
            })
    }

    [string] GetPrefix() {
        <#
            .SYNOPSIS
                Gets the prefix for the bullet list.

            .DESCRIPTION
                Gets the prefix for the bullet list. The prefix is the string that is used to
                insert the bullet style and indentation level of the list for the first line of
                a list item in Markdown.

            .EXAMPLE
                ```powershell
                $list   = [BulletList]::new(2, [BulletListStyle]::Plus)
                $prefix = $list.GetPrefix()
                "'$prefix'"
                ```

                ```output
                '  + '
                ```

            .OUTPUTS
                [string]
                    The prefix for the bullet list.
        #>

        $prefix = switch ($this.Style) {
            Hyphen   { '- ' }
            Plus     { '+ ' }
            Asterisk { '* ' }
        }

        return $prefix
    }

    [string[]] FormatListItem([string]$content) {
        <#
            .SYNOPSIS
                Formats the specified content as a bullet list item.

            .DESCRIPTION
                Formats the specified content as a bullet list item. The content is indented and
                prefixed with the appropriate bullet style.

            .EXAMPLE
                $list = [BulletList]::new(2, [BulletListStyle]::Plus)
                $list.FormatListItem("This is a list item.")
                # Output: "    + This is a list item."

            .PARAMETER content
                The content to format as a bullet list item.

            .OUTPUTS
                [string[]]
                    The formatted bullet list item.
        #>

        $prefix = $this.GetPrefix()

        return [MarkdownList]::FormatListItem($content, $prefix)
    }

    [string[]] FormatListItem([int]$index) {
        <#
            .SYNOPSIS
                Formats the specified index as a bullet list item.

            .DESCRIPTION
                Formats the specified index as a bullet list item. The index is indented and
                prefixed with the appropriate bullet style.

            .EXAMPLE
                $list = [BulletList]::new(2, [BulletListStyle]::Plus)
                $list.FormatListItem(1)
                # Output: "    + 1."

            .PARAMETER index
                The index to format as a bullet list item.

            .OUTPUTS
                [string[]]
                    The formatted bullet list item.
        #>

        $listItem = $this.Items[$index]

        if ([string]::IsNullOrEmpty($listItem)) {
            $Message = @(
                "The list item at index $index is null or empty,"
                'or no entry at that index exists.'
            ) -join ' '

            throw [ArgumentNullException]::new($Message)
        }

        return $this.FormatListItem($listItem)
    }

    [string[]] FormatList() {
        <#
            .SYNOPSIS
                Formats the list items as a bullet list.

            .DESCRIPTION
                Formats the list items as a bullet list. Each item is indented and prefixed with
                the appropriate bullet style.

            .EXAMPLE
                $list = [BulletList]::new(2, [BulletListStyle]::Plus)
                $list.Items = @("Item 1", "Item 2", "Item 3")
                $list.FormatList()
                # Output:
                #     + Item 1
                #     + Item 2
                #     + Item 3

            .OUTPUTS
                [string[]]
                    The formatted bullet list.
        #>

        [string[]]$listLines = @()

        foreach ($item in $this.Items) {
            $listLines += $this.FormatListItem($item)
        }

        return $listLines
    }

    static [string[]] FormatList([string[]]$items) {
        <#
            .SYNOPSIS
                Formats the specified items as a bullet list.
            .DESCRIPTION
                Formats the specified items as a bullet list. Each item is indented and prefixed
                with the default bullet style and a depth of one.
        #>

        return [BulletList]::new($items).FormatList()
    }

    static [string[]] FormatList([string[]]$items, [BulletListStyle]$style) {
        <#
            .SYNOPSIS
                Formats the specified items as a bullet list.
            .DESCRIPTION
                Formats the specified items as a bullet list. Each item is indented and prefixed
                with the specified bullet style and a depth of one.
        #>

        return [BulletList]::new($items, $style).FormatList()
    }
}
