# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/LinkKind.psm1
using module ./Position.psm1
using module ./ParsingPatterns.psm1

class DocumentLink {
  [LinkKind] $Kind
  [string]   $Text
  [uri]      $Destination
  [string]   $Title
  [string]   $ReferenceID
  [Position] $Position
  [string]   $Markdown

  # Shorthand method for determining if this link is for an image
  [bool] IsImage() {
    return $this.Kind.ToString() -match '^Image'
  }

  # Shorthand method for determining if this link is for text
  [bool] IsText() {
    return $this.Kind.ToString() -match '^Text'
  }

  # Shorthand method for determining if this link has a reference
  [bool] HasReference() {
    return $this.Kind.ToString() -match 'Reference$'
  }

  [bool] IsSelfReferential() {
    return $this.Kind.ToString() -match 'SelfReference$'
  }

  # Shorthand method for determining if this link is a reference
  [bool] IsReference() {
    return $this.Kind.ToString() -match '^Reference'
  }

  DocumentLink() {
    # Re-defined to support alternate constructors
  }

  # Generate a document link from a match group for [ParsingPatterns]::Link
  DocumentLink([System.Text.RegularExpressions.Group]$LinkMatch) {
    [DocumentLink]::New($LinkMatch, 0)
  }

  # Generate a document link from a match group for [ParsingPatterns]::Link
  DocumentLink([System.Text.RegularExpressions.Group]$LinkMatch, [int]$LineNumber) {
    $this.Position = [Position]@{
      FileInfo    = $null
      LineNumber  = $LineNumber
      StartColumn = $LinkMatch.Index + 1
    }
    $this.Text = [DocumentLink]::TrimSquareBrackets(
      $LinkMatch.Groups.Where({ $_.Name -eq 'Text' }).Value
    )
    $this.Destination = $LinkMatch.Groups.Where({ $_.Name -eq 'Destination' }).Value
    $this.Title = $LinkMatch.Groups.Where({ $_.Name -eq 'Title' }).Value
    $this.ReferenceID = [DocumentLink]::TrimSquareBrackets(
      $LinkMatch.Groups.Where({ $_.Name -eq 'ReferenceID' }).Value
    )
    $this.Markdown = $LinkMatch.Value

    $IsImage = $LinkMatch.Groups.Where({ $_.Name -eq 'IsImage' }).Value -eq '!'
    $IsInline = ![string]::IsNullOrWhiteSpace($this.Destination)
    $HasReference = ![string]::IsNullOrWhiteSpace($this.ReferenceID)

    if ($IsImage -and $IsInline) {
      $this.Kind = [LinkKind]::ImageInline
    } elseif ($IsImage -and $HasReference) {
      $this.Kind = [LinkKind]::ImageUsingReference
    } elseif ($IsImage) {
      $this.Kind = [LinkKind]::ImageSelfReference
    } elseif ($IsInline) {
      $this.Kind = [LinkKind]::TextInline
    } elseif ($HasReference) {
      $this.Kind = [LinkKind]::TextUsingReference
    } else {
      $this.Kind = [LinkKind]::TextSelfReference
    }
  }

  # Trim square brackets when using balance groups, like to find text and reference IDs
  hidden static [string] TrimSquareBrackets([string]$Text) {
    if ($Text -match '^\[(?<Inner>.*)\]$') {
      return $Matches.Inner
    }

    return $Text
  }

  # Parses a file's content for Markdown links, parsing one line at a time to support ignoring any
  # links in multiline codeblocks or comments, and ensuring the returned objects have the FileInfo
  # property defined with the input file's values.
  static [DocumentLink[]] Parse([System.IO.FileInfo]$FileInfo) {
    $Content = Get-Content -Raw -Path $FileInfo.FullName
    [DocumentLink[]]$Links = [DocumentLink]::Parse($Content)
    | ForEach-Object -Process {
      # Add the file info to each link
      $_.Position.FileInfo = $FileInfo
      # Emit the link for the list
      $_
    }

    return $Links
  }

  # Parses an arbitrary block of text for Markdown links, parsing one line at a time to support
  # ignoring any links in multiline codeblocks or comments.
  static [DocumentLink[]] Parse([string]$Markdown) {
    [DocumentLink[]]$Links = @()
    [DocumentLink[]]$DiscoveredLinks = @()
    $Lines = $Markdown -split '\r?\n|`r'
    $InCodeFence = $false    # This is set to true when a code fence opens to ignore lines til close
    $CodeFenceClose = $null  # This is defined when a code fence is found and nulled when closed
    $InCommentBlock = $false # This is set to true when a comment block opens without closing
    for ($i = 1; $i -le $Lines.Count ; $i++) {
      $CommentBlocks = @()       # This holds the enclosed comment blocks for a line
      $IgnoreAfterIndex = $null  # Points to a comment block that doesn't close on this line
      $IgnoreBeforeIndex = $null # Points to closing of a multi-line comment block
      $LinkMatches = $null       # Holds discovered links on this line
      $Line = $Lines[$i - 1]     # Editors/humans use a 1-index array for file lines

      # Before we process anything else, check if we're in a code fence and closing it
      if ($InCodeFence) {
        if ($Line -eq $CodeFenceClose) {
          $InCodeFence = $false
          $CodeFenceClose = $null
        }
        # Regardless whether this line closes the code fence, no valid links can be here.
        continue
      } elseif ($InCommentBlock) {
        # If we're not in a code fence, we might be in a comment block and need to see if it closes.
        # If it does, we need to mark the index so we ignore links before the closure.
        if ($Line -match [ParsingPatterns]::ClosingMultiLineHtmlComment) {
          $ClosingMatch = $Matches
          $InCommentBlock = $false
          $IgnoreBeforeIndex = ($ClosingMatch.InComments + $ClosingMatch.CloseComment).Length
        }
      }

      # Look for new HTML comments. We need to capture fully enclosed comments and mark any unclosed
      # comments so we can ignore links in comments. We can have any number of comments on a line.
      $HtmlCommentMatches = [regex]::Matches($Line, [ParsingPatterns]::HtmlCommentBlock)
      if ($HtmlCommentMatches.Count) {
        $CommentBlocks = $HtmlCommentMatches.Groups
        | Where-Object { $_.Name -eq 'InComments' }
        | Select-Object -ExpandProperty Value
        if ($CommentBlocks) {
        }
        $UnclosedHtmlComment = $HtmlCommentMatches
        | Where-Object {
          $_.Groups | Where-Object {
            $_.Name -eq 'CloseComment' -and (-not $_.Success)
          }
        } | Select-Object -First 1
        if ($UnclosedHtmlComment) {
          $IgnoreAfterIndex = $UnclosedHtmlComment.Index
          $InCommentBlock = $true
        }
      }

      # If the line opens a code fence, capture the closing pattern and continue
      # if ($Line -match [DocumentLink]::OpenCodeFencePattern) {
      if ($Line -match [ParsingPatterns]::OpenCodeFence) {
        $InCodeFence = $true
        $CodeFenceClose = @(
          $Matches.Lead -replace '([0-9]|\.|-|\+|\*)', ' '
          $Matches.Fence
        ) -join ''
        continue
      }

      # Check for link references first - less expensive and no valid links follow them.
      if ($Line -match [ParsingPatterns]::LinkReferenceDefinition) {
        $ReferenceMatchInfo = $Matches
        $FullMatch = $ReferenceMatchInfo.0
        if ([ParsingPatterns]::NotInsideInlineCode($Line, $FullMatch)) {
          $Properties = @{
            Position    = [Position]@{
              LineNumber  = $i
              StartColumn = $ReferenceMatchInfo.Lead.Length
            }
            ReferenceID = [DocumentLink]::TrimSquareBrackets($ReferenceMatchInfo.ReferenceID)
            Destination = $ReferenceMatchInfo.Destination
            Title       = $ReferenceMatchInfo.Title
            Markdown    = $FullMatch
            Kind        = [LinkKind]::ReferenceDefinition
          }

          $DiscoveredLinks += [DocumentLink]$Properties
        }

        # Reset before next line
        $ReferenceMatchInfo = $null
        continue
      }

      # Find all links in the line, ignoring them if in comment blocks or code
      if ($LinkMatches = [regex]::Matches($Line, [ParsingPatterns]::Link)) {
        foreach ($LinkMatch in $LinkMatches) {
          $FullMatch = $LinkMatch.Value
          $Index = $LinkMatch.Index
          $NotInsideComment = $true

          # If there was an unclosed comment block on this line, ignore links after it started
          if ($IgnoreAfterIndex -and ($Index -gt $IgnoreAfterIndex)) {
            $NotInsideComment = $false
          }

          # If this line closed a multi-line comment block, ignore links before it closed
          if ($IgnoreBeforeIndex -and ($Index -le $IgnoreBeforeIndex)) {
            $NotInsideComment = $false
          }

          # If this line had closed comment blocks, ignore links inside them
          foreach ($Block in $CommentBlocks) {
            if ($Block -match [regex]::Escape($FullMatch)) {
              $NotInsideComment = $false
            }
          }

          $NotInsideInlineCode = [ParsingPatterns]::NotInsideInlineCode($Line, $FullMatch)
          if ($NotInsideComment -and $NotInsideInlineCode) {
            $Link = [DocumentLink]::New($LinkMatch, $i)
            $DiscoveredLinks += $Link
            # Look for nested links, setting their position relative to their parent
            if (![string]::IsNullOrWhiteSpace($Link.Text)) {
              if ($NestedLinks = [DocumentLink]::ParseNested($Link.Text, 1, 5)) {
                foreach ($NestedLink in $NestedLinks) {
                  $NestedLink.Position.LineNumber = $Link.Position.LineNumber
                  $NestedLink.Position.StartColumn += $Link.Position.StartColumn
                  $DiscoveredLinks += $NestedLink
                }
              }
            }
          }
        }
      }
    }

    # Need to discard self-reference links without a definition - they're technically
    # not links at all.
    $ReferenceDefinitions = $DiscoveredLinks | Where-Object -FilterScript { $_.IsReference() }
    foreach ($Link in $DiscoveredLinks) {
      if (!$Link.IsSelfReferential() -or ($Link.Text -in $ReferenceDefinitions.ReferenceID)) {
        $Links += $Link
      }
    }

    return $Links
  }

  hidden static [DocumentLink[]] ParseNested([string]$LinkText, [int]$Depth, [int]$MaxDepth) {
    [DocumentLink[]]$Links = @()
    $CommentBlocks = @()

    if ($Depth -gt $MaxDepth) {
      return $Links
    }

    # Look for new HTML comments. We need to capture fully enclosed comments and mark any unclosed
    # comments so we can ignore links in comments. We can have any number of comments on a line.
    $HtmlCommentMatches = [regex]::Matches($LinkText, [ParsingPatterns]::HtmlCommentBlock)
    if ($HtmlCommentMatches.Count) {
      $CommentBlocks = $HtmlCommentMatches.Groups
      | Where-Object { $_.Name -eq 'InComments' }
      | Select-Object -ExpandProperty Value
    }

    # Find all links in the line, ignoring them if in comment blocks or code
    if ($LinkMatches = [regex]::Matches($LinkText, [ParsingPatterns]::Link)) {
      foreach ($LinkMatch in $LinkMatches) {
        $FullMatch = $LinkMatch.Value
        $NotInsideComment = $true

        # If this line had closed comment blocks, ignore links inside them
        foreach ($Block in $CommentBlocks) {
          if ($Block -match [regex]::Escape($FullMatch)) {
            $NotInsideComment = $false
          }
        }

        $NotInsideInlineCode = [ParsingPatterns]::NotInsideInlineCode($LinkText, $FullMatch)
        if ($NotInsideComment -and $NotInsideInlineCode) {
          $Link = [DocumentLink]::New($LinkMatch, 0)
          $Links += $Link
          # Look for nested links, setting their position relative to their parent
          if (![string]::IsNullOrWhiteSpace($Link.Text)) {
            if ($NestedLinks = [DocumentLink]::ParseNested($Link.Text, ($Depth + 1), $MaxDepth)) {
              foreach ($NestedLink in $NestedLinks) {
                $NestedLink.Position.LineNumber = $Link.Position.LineNumber
                $NestedLink.Position.StartColumn += $Link.Position.StartColumn
                $Links += $NestedLink
              }
            }
          }
        }
      }
    }

    return $Links
  }

  hidden static [DocumentLink[]] FilterForInlineLinks([DocumentLink[]]$Links) {
    return $Links.Where({ -not ($_.HasReference() -or $_.IsReference()) })
  }

  hidden static [DocumentLink[]] FilterForReferenceLinks([DocumentLink[]]$Links) {
    return $Links.Where({ $_.HasReference() })
  }

  hidden static [DocumentLink[]] FilterForSelfReferentialLinks([DocumentLink[]]$Links) {
    return $Links.Where({ $_.IsSelfReferential() })
  }

  hidden static [DocumentLink[]] FilterForReferenceDefinitions([DocumentLink[]]$Links) {
    return $Links.Where({ $_.IsReference() })
  }

  hidden static [DocumentLink[]] FilterForReferenceLinksAndDefinitions([DocumentLink[]]$Links) {
    return $Links.Where({ $_.HasReference() -or $_.IsReference() })
  }

  hidden static [DocumentLink[]] FilterForUndefinedReferenceLinks([DocumentLink[]]$Links) {
    return [DocumentLink]::FilterForReferenceLinks($Links).Where({
        $ReferenceID = $_.IsSelfReferential() ? $_.Text : $_.ReferenceID
        $ReferenceID -notin [DocumentLink]::FilterForReferenceDefinitions($Links).ReferenceID
      }
    )
  }

  hidden static [DocumentLink[]] FilterForUnusedReferenceLinkDefinitions([DocumentLink[]]$Links) {
    return [DocumentLink]::FilterForReferenceDefinitions($Links).Where({
        ($_.ReferenceID -notin [DocumentLink]::FilterForReferenceLinks($Links).ReferenceID) -and
        ($_.ReferenceID -notin [DocumentLink]::FilterForSelfReferentialLinks($Links).Text)
      }
    )
  }

  hidden static [DocumentLink[]] FilterForValidReferenceLinksAndDefinitions([DocumentLink[]]$Links) {
    $InvalidReferences = (
      [DocumentLink]::FilterForUndefinedReferenceLinks($Links) +
      [DocumentLink]::FilterForUnusedReferenceLinkDefinitions($Links)
    )
    return [DocumentLink]::FilterForReferenceLinksAndDefinitions($Links).Where({ $_ -notin $InvalidReferences })
  }
}
