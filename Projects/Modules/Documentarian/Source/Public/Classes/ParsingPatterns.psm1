# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
  <#Category#>'PSUseConsistentIndentation',
  <#CheckId#>$null,
  Justification = 'Easier readability for regex strings from arrays'
)]
class ParsingPatterns {
  # Anything following this is the start of a valid inline/block for Markdown. The value can be
  # used to find code fence openings, link reference definitions, etc.
  static [string] $LineLead = @(
    '^'                              # Anchors to start of line
    '(?<Lead>'                       # Lead captures whitespace + block notation
      '(?<LeadingWhiteSpace>\s*)'    # May start with any amount of leading whitespace
      '(?<BlockNotation>'            # May be in a list or blockquote
        "(?'BlockQuoteBefore'>\s+)*" # Blockquote, like '> ```', '>  > ```', etc.
        '(?<ListNotation>'           # A list can follow a block quote
          '(?<OrderedList>\d+\. )'   # Ordered list, like '1. ```' or '15. ```'
          '|'                        #
          '(?<UnorderedList>[-+*] )' # Unordered list, like '- ```', '* ```', or '+ ```'
        ')?'                         #
        "(?'BlockQuoteAfter'>\s+)?"  # Blockquotes can come after a list, too, but only once
      ')?'                           # Doesn't need to have a block
    ')'                              # Close lead capture group
  ) -join ''

  # Returns a pattern for finding everything inside square brackets using balance groups with an optional name.
  # To use the same pattern more than once in a regex, the balance groups need unique names.
  static [string] InSquareBrackets([string]$BalanceGroupName) {
    $OpenGroup = "Open$BalanceGroupName"
    $CloseGroup = [string]::IsNullOrWhiteSpace($BalanceGroupName) ? 'Close' : $BalanceGroupName
    return @(
      '(?:'                                # Open bracket group finder
        '(?:'                              #
          "(?<$OpenGroup>\[)"              # Open balance group starts with [
          '(?:`` .* ``|`[^`]*`|[^\[\]])*'  # Anything inside inline code or not-[]
        ')+'                               # At least one
        '(?:'                              #
          "(?<$CloseGroup-$OpenGroup>\])"  # Push to stack on ]
          '(?:`` .* ``|`[^`]*`|[^\[\]])*?' # Anything inside inline code or not-[]
        ')+?'                              # At least one
      ')+?'                                # Must match at least once
      "(?($OpenGroup)(?!))"                # If open exists (ie not-matching # of ]), fail
    ) -join ''
  }

  # This will return the whole thing, need to trim [] from start and end for
  # text. Need to reparse text for nested.
  static [string] InSquareBrackets() {
    return [ParsingPatterns]::InSquareBrackets('')
  }

  # Double backticks are difficult - we can't reuse capture groups inside a
  # pattern to know that we're closing the right one. We'll just assume it's
  # always `` ... `` for now. Theoretically you could nest them but that
  # seems like a tiny edge case for most documents.
  static [string] $MultitickInlineCode = @(
    '(?<open>`{2,}) '    # Multi-backtick inline code opens with 2+ backticks and a space
    '(?<text>(?:'        # Capture everything until the code closes, don't capture sub-group
      '.(?!\k<open>))*.' # Anything not followed by the code closer, then that character too
    ')'                  # Close the text capture group
    '\k<open>'           # The code is closed only by the same number of backticks it opened with.
  ) -join ''

  # Finds the opening for a codefence with leading components and the actual fence. This is useful
  # so we can effectively find the matching closing fence.
  static [string] $OpenCodeFence = @(
    [ParsingPatterns]::LineLead # Retrieves any leading whitespace/block syntax
    '(?<Fence>`{3,}|~{3,})'     # Fences can be backticks or tildes, don't care about after.
  ) -join ''

  # Finds any comment block, including unclosed comment blocks so we know if a multi-line comment
  # is starting. Used for ignoring otherwise valid syntax.
  static [string] $HtmlCommentBlock = @(
    "(?'OpenComment'<!--)"
    "(?'InComments'(?:.(?!-->))*.)"
    "(?'CloseComment'-->)?"
  ) -join ''

  # Only used for discovering the closure point of a multi-line HTML comment so we can ignore
  # otherwise valid syntax that comes before the closure.
  static [string] $ClosingMultiLineHtmlComment = @(
    '^'
    "(?'InComments'(?:.(?!-->))*.)"
    "(?'CloseComment'-->)"
    "(?'AfterComment'.*)"
  ) -join ''

  # Finds a match within a set of single backticks, the most common syntax for inline code.
  static [string] InsideSingleBacktick([string]$InnerPattern) {
    return @(
      '`[^`]*'      # Opening backtick followed by zero-or-more not-backticks
      $InnerPattern # Inner regex between close and open
      '[^`]*`'      # zero-or-more not-backticks followed by closing backtick
    ) -join ''
  }

  # Helper method for discovering whether a string of text is inside any inline code blocks
  # for a given line of Markdown.
  static [bool] NotInsideInlineCode([string]$Line, [string]$FullMatch) {
    $EscapedMatch = [regex]::Escape($FullMatch)
    $SingleBacktickPattern = [ParsingPatterns]::InsideSingleBacktick($EscapedMatch)

    # First find all multitick codeblocks, grab their raw value
    $MultitickCodeBlocks = [regex]::Matches($Line, [ParsingPatterns]::MultitickInlineCode)?.Value

    # If the text is inside a multitick codeblock, it's in a codeblock.
    # If it isn't inside a multitick codeblock, it might still be in a single-tick codeblock.
    if (($MultitickCodeBlocks.Count -ge 1) -and ($MultitickCodeBlocks -match $EscapedMatch)) {
      return $false
    } elseif ($Line -match $SingleBacktickPattern) {
      return $false
    }

    # The text wasn't inside any codeblocks
    return $true
  }

  # Needed to make it easier to read the combined pattern; also reused for reference definitions.
  static [string] $LinkDefinition = @(
    '(?<Destination>\S+)' # The URL component, capture any non-whitespace
    '(?:\s+(?:'           # The title component, leads with non-captured whitespace
      "'(?<Title>[^']*)'" # May be wrapped in non-captured single-quotes
      '|'                 # or
      '"(?<Title>[^"]*)"' # May be wrapped in non-captured double-quotes
    '))?'                 # Make sure title is optional.
  ) -join ''

  # Finds a Markdown link in a given line. This pattern is likely hugely non-performant on a
  # non-split document. It's also not codeblock-aware. Only use it on a single line known not
  # to be inside a Markdown codeblock.
  static [string] $Link = @(
    '(?<IsImage>!)?'                        # If the link has a ! prefix, it's an image
    "(?<Text>$(                           #
      # [ParsingPatterns]::InSquareBracketsP # Need to retrieve the text inside the brackets.
      [ParsingPatterns]::InSquareBrackets('Text')             # Need to retrieve the text inside the brackets.
    ))"                                   #
    '(?!:)'                                 # Ignore if followed by colon - that's a ref def
    '(?:'                                   # Text can be followed by an inline def/ref/null
      "\($(                                 #
        [ParsingPatterns]::LinkDefinition   # Inline Definition, optional destination/title
      )\)"                                  #
      '|'                                   #
      "(?<ReferenceID>$(                  #
        # [ParsingPatterns]::InSquareBracketsP
        [ParsingPatterns]::InSquareBrackets('ReferenceID')             # Need to retrieve the text inside the brackets.
      ))"                                 #
    ')?'                                    # The definition and reference syntax is optional
  ) -join ''

  # Finds a link reference definition, which can be inside a block.
  static [string] $LinkReferenceDefinition = @(
    [ParsingPatterns]::LineLead           # Retrieves any leading whitespace/block syntax
    "(?<ReferenceID>$(                  #
      # [ParsingPatterns]::InSquareBrackets # Need to retrieve the text inside the brackets as ID
      [ParsingPatterns]::InSquareBrackets()
    ))"                                 #
    ':\s+'                                # Must be followed by a colon and at least one space
    [ParsingPatterns]::LinkDefinition     # Inline Definition, optional destination/title
  ) -join ''
}
