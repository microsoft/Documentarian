# Header

This is a [markdown](/concepts/markdown.md) file.

You can add links like:

> ```md
> [<text>](url 'title')
> ```

[another](one), with [a third](too 'even a caption').

Links can be [self-referencing]. Sometimes, [self-reference] and [reference][a]
links don't have defined references.

- [nested lists](are-fine.md)
- No link here.

  1. But there is here! [haha](hehee.md)

- No worries.
- > Even blockquotes can have [links][01].
  >
  > ````md
  > But not in [fences](nope.md)
  > ````
  >
  > ![Images work too!](image.png)
  >
  > Can you use a [link reference][02] with the def in a block?
  >
  > [02]: maybe.md

- The real danger is `[inline](links.md "in code")`.
- We'll work on `` those, [too](invalid.md) `` of course.

Also <!-- [links](inside.md "comments") --> are a problem [sometimes](anyway.md).

![Between](comments.md)

Especially since <!-- Comments can [begin][03]
and end anywhere --> [but then](its.md "okay").

[01]: links-from-reference.md
[self-referencing]: self.md
[never-used]: not-for.md "any link"
