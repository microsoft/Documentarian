# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum LinkKind {
  TextInline          # [<Text>](<Definition>)
  TextSelfReference   # [<Text>]
  TextUsingReference  # [<Text>][<Reference>]
  ImageInline         # ![<AltText>](<Definition>)
  ImageSelfReference  # ![<AltText>]
  ImageUsingReference # ![<AltText>][<Reference>]
  ReferenceDefinition # [<Name>]: <Definition>
}
