---
title: Properties
summary: Properties for the Position class
description: >-
  Defines the properties for the **Position** class.
---

### FileInfo

The **FileInfo** property contains the metadata from the file system for the file the
[**Position**][01] exists in, if any. If the [**Position**][01] is for a virtual document or a
string, this property is `$null`.

Type
: {{% xref "System.IO.FileInfo" %}}
{.pwsh-metadata}

### LineNumber

The **LineNumber** property represents the line from the text. The lines are counted from 1, unlike
zero-indexed lists. This maps both to how editor applications report line numbers and how authors
think about lines in a file.

Type
: {{% xref "System.Int32" %}}
{.pwsh-metadata}

### StartColumn

The **StartColumn** property represents how many characters into a line the **Position** is. The
columns are counted from 1, unlike zero-indexed lists. This maps both to how editor applications
report column numbers and how authors think about line lengths in a file.

Type
: {{% xref "System.Int32" %}}
{.pwsh-metadata}

<!-- Reference Link Definitions -->
[01]: ../
