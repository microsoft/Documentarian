---
title: LinkKind
summary: Distinguishes the type of link in a Markdown file.
description: >-
  The **LinkKind** enum distinguishes the type of link in a Markdown file.
---

## Definition

{{% src path="Public/Enums/LinkKind.psm1" title="Source Code" /%}}

## Fields

### `TextInline`

Value
: 0
{ .pwsh-metadata }

Indicates that the link is a text-link that includes its definition inline.

```markdown
[<Text>](<Definition>)
```

### `TextSelfReference`

Value
: 1
{ .pwsh-metadata }

Indicates that the link is a text-link that uses its own text as the reference definition.

```markdown
[<Text>]
```

### `TextUsingReference`

Value
: 2
{ .pwsh-metadata }

Indicates that the link is a text-link that references a definition in the file.

```markdown
[<Text>][<ReferenceID>]
```

### `ImageInline`

Value
: 3
{ .pwsh-metadata }

Indicates that the link is an image-link that includes its definition inline.

```markdown
![<AltText>](<Definition>)
```

### `ImageSelfReference`

Value
: 4
{ .pwsh-metadata }

Indicates that the link is an image-link that uses its own alt text as the reference definition.

```markdown
![<AltText>]
```

### `ImageUsingReference`

Value
: 5
{ .pwsh-metadata }

Indicates that the link is an image-link that references a definition in the file.

```markdown
![<AltText>][<ReferenceID>]
```

### `ReferenceDefinition`

Value
: 6
{ .pwsh-metadata }

Indicates that the link is the definition other links may reference by ID.

```markdown
[<ReferenceID>]: <Definition>
```
