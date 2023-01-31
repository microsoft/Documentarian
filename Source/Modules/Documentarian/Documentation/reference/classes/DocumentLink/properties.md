---
title: Properties
summary: Properties for the DocumentLink class
description: >-
  Defines the properties for the **DocumentLink** class.
---

## Destination

The **Destination** property represents the `href` value for a text link or the `src` value for an
image link.

Type
: {{% xref "System.Uri" %}}
{.pwsh-metadata}

## Kind

The **Kind** property distinguishes what sort of link the instance represents: wether it's a
reference definition or a link and, if it's a link, whether it's text or image and inline,
self-referential, or uses a reference.

Type
: [**LinkKind**][01]
{.pwsh-metadata}

## Markdown

The **Markdown** property represents the raw Markdown syntax of the link in the document it was
parsed from.

Type
: {{% xref "System.String" %}}
{.pwsh-metadata}

## Position

The **Position** property represents where in the Markdown the link was parsed from.

Type
: [**Position**][02]
{.pwsh-metadata}

## ReferenceID

A **ReferenceID** is the document-unique ID for a reference definition. For links whose
**Kind** is like `*UsingReference`, it represents the ID of the reference definition that they
are associated with.

Type
: {{% xref "System.string" %}}
{.pwsh-metadata}

## Text

The **Text** property represents the displayed text for a text link and the alt text for an image
link.

Type
: {{% xref "System.String" %}}
{.pwsh-metadata}

## Title

The **Title** property represents the `title` attribute for a link, if specified.

Type
: {{% xref "System.String" %}}
{.pwsh-metadata}

<!-- Reference Link Definitions -->

[01]: ../../../enums/linkkind
[02]: ../../position
