# Flutter Markdown

**Deprecated**

This version is forked from flutter_markdwon. The improvement features are as follows:

1. Add PositionableMarkdown which returned a SliverList widget, it could scroll to the specified index. (Reference to [scroll_to_index](https://github.com/quire-io/scroll-to-index)).

A markdown renderer for Flutter. It supports the
[original format](https://daringfireball.net/projects/markdown/), but no inline
HTML.

## Alternative Solutions of superscript and subscript text

```dart
unicode_map = {
  #           superscript     subscript
  '0'        : ('\u2070',   '\u2080'      ),
  '1'        : ('\u00B9',   '\u2081'      ),
  '2'        : ('\u00B2',   '\u2082'      ),
  '3'        : ('\u00B3',   '\u2083'      ),
  '4'        : ('\u2074',   '\u2084'      ),
  '5'        : ('\u2075',   '\u2085'      ),
  '6'        : ('\u2076',   '\u2086'      ),
  '7'        : ('\u2077',   '\u2087'      ),
  '8'        : ('\u2078',   '\u2088'      ),
  '9'        : ('\u2079',   '\u2089'      ),
  'a'        : ('\u1d43',   '\u2090'      ),
  'b'        : ('\u1d47',   '?'           ),
  'c'        : ('\u1d9c',   '?'           ),
  'd'        : ('\u1d48',   '?'           ),
  'e'        : ('\u1d49',   '\u2091'      ),
  'f'        : ('\u1da0',   '?'           ),
  'g'        : ('\u1d4d',   '?'           ),
  'h'        : ('\u02b0',   '\u2095'      ),
  'i'        : ('\u2071',   '\u1d62'      ),
  'j'        : ('\u02b2',   '\u2c7c'      ),
  'k'        : ('\u1d4f',   '\u2096'      ),
  'l'        : ('\u02e1',   '\u2097'      ),
  'm'        : ('\u1d50',   '\u2098'      ),
  'n'        : ('\u207f',   '\u2099'      ),
  'o'        : ('\u1d52',   '\u2092'      ),
  'p'        : ('\u1d56',   '\u209a'      ),
  'q'        : ('?',        '?'           ),
  'r'        : ('\u02b3',   '\u1d63'      ),
  's'        : ('\u02e2',   '\u209b'      ),
  't'        : ('\u1d57',   '\u209c'      ),
  'u'        : ('\u1d58',   '\u1d64'      ),
  'v'        : ('\u1d5b',   '\u1d65'      ),
  'w'        : ('\u02b7',   '?'           ),
  'x'        : ('\u02e3',   '\u2093'      ),
  'y'        : ('\u02b8',   '?'           ),
  'z'        : ('?',        '?'           ),
  'A'        : ('\u1d2c',   '?'           ),
  'B'        : ('\u1d2e',   '?'           ),
  'C'        : ('?',        '?'           ),
  'D'        : ('\u1d30',   '?'           ),
  'E'        : ('\u1d31',   '?'           ),
  'F'        : ('?',        '?'           ),
  'G'        : ('\u1d33',   '?'           ),
  'H'        : ('\u1d34',   '?'           ),
  'I'        : ('\u1d35',   '?'           ),
  'J'        : ('\u1d36',   '?'           ),
  'K'        : ('\u1d37',   '?'           ),
  'L'        : ('\u1d38',   '?'           ),
  'M'        : ('\u1d39',   '?'           ),
  'N'        : ('\u1d3a',   '?'           ),
  'O'        : ('\u1d3c',   '?'           ),
  'P'        : ('\u1d3e',   '?'           ),
  'Q'        : ('?',        '?'           ),
  'R'        : ('\u1d3f',   '?'           ),
  'S'        : ('?',        '?'           ),
  'T'        : ('\u1d40',   '?'           ),
  'U'        : ('\u1d41',   '?'           ),
  'V'        : ('\u2c7d',   '?'           ),
  'W'        : ('\u1d42',   '?'           ),
  'X'        : ('?',        '?'           ),
  'Y'        : ('?',        '?'           ),
  'Z'        : ('?',        '?'           ),
  '+'        : ('\u207A',   '\u208A'      ),
  '-'        : ('\u207B',   '\u208B'      ),
  '='        : ('\u207C',   '\u208C'      ),
  '('        : ('\u207D',   '\u208D'      ),
  ')'        : ('\u207E',   '\u208E'      ),
  ':alpha'   : ('\u1d45',   '?'           ),
  ':beta'    : ('\u1d5d',   '\u1d66'      ),
  ':gamma'   : ('\u1d5e',   '\u1d67'      ),
  ':delta'   : ('\u1d5f',   '?'           ),
  ':epsilon' : ('\u1d4b',   '?'           ),
  ':theta'   : ('\u1dbf',   '?'           ),
  ':iota'    : ('\u1da5',   '?'           ),
  ':pho'     : ('?',        '\u1d68'      ),
  ':phi'     : ('\u1db2',   '?'           ),
  ':psi'     : ('\u1d60',   '\u1d69'      ),
  ':chi'     : ('\u1d61',   '\u1d6a'      ),
  ':coffee'  : ('\u2615',   '\u2615'      )
}

```

## Overview

The [`flutter_markdown_x`](https://pub.dev/packages/flutter_markdown_x) package
renders Markdown, a lightweight markup language, into a Flutter widget
containing a rich text representation.

`flutter_markdown_x` is built on top of the Dart
[`markdown`](https://pub.dev/packages/markdown) package, which parses
the Markdown into an abstract syntax tree (AST). The nodes of the AST are an
HTML representation of the Markdown data.

## Flutter Isn't a HTML Renderer

While this approach to creating a rich text representation of Markdown source
text in Flutter works well, Flutter isn't a HTML renderer like a web browser.
Markdown was developed by John Gruber in 2004 to allow users to turn readable,
plain text content into rich text HTML. This close association with HTML allows
for the injection of HTML into the Markdown source data. Markdown parsers
generally ignore hand-tuned HTML and pass it through to be included in the
generated HTML. This _trick_ has allowed users to perform some customization
or tweaking of the HTML output. A common HTML tweak is to insert HTML line-break
elements **\<br />** in Markdown source to force additional line breaks not
supported by the Markdown syntax. This HTML _trick_ doesn't apply to Flutter. The
`flutter_markdown_x` package doesn't support inline HTML.

## Markdown Specifications and `flutter_markdown_x` Compliance

There are three seminal documents regarding Markdown syntax; the
[original Markdown syntax documentation](https://daringfireball.net/projects/markdown/syntax)
specified by John Gruber, the
[CommonMark specification](https://spec.commonmark.org/0.29/), and the
[GitHub Flavored Markdown specification](https://github.github.com/gfm/).

The CommonMark specification brings order to and clarifies the Markdown syntax
cases left ambiguous or unclear in the Gruber document. GitHub Flavored
Markdown (GFM) is a strict superset of CommonMark used by GitHub.

The `markdown` package, and in extension, the `flutter_markdown_x` package, supports
four levels of Markdown syntax; basic, CommonMark, GitHub Flavored, and GitHub
Web. Basic, CommonMark, and GitHub Flavored adhere to the three Markdown
documents, respectively. GitHub Web adds header ID and emoji support. The
`flutter_markdown_x` package defaults to GitHub Flavored Markdown.

## Getting Started

Using the Markdown widget is simple, just pass in the source markdown as a
string:

    Markdown(data: markdownSource);

If you do not want the padding or scrolling behavior, use the MarkdownBody
instead:

    MarkdownBody(data: markdownSource);

By default, Markdown uses the formatting from the current material design theme,
but it's possible to create your own custom styling. Use the MarkdownStyle class
to pass in your own style. If you don't want to use Markdown outside of material
design, use the MarkdownRaw class.

## Emoji Support

Emoji glyphs can be included in the formatted text displayed by the Markdown
widget by either inserting the emoji glyph directly or using the inline emoji
tag syntax in the source Markdown document.

Markdown documents using UTF-8 encoding can insert emojis, symbols, and other
Unicode characters directly in the source document. Emoji glyphs inserted
directly in the Markdown source data are treated as text and preserved in the
formatted output of the Markdown widget. For example, in the following Markdown
widget constructor, a text string with a smiley face emoji is passed in as the
source Markdown data.

```
Markdown(
    controller: controller,
    selectable: true,
    data: 'Insert emoji here😀 ',
)
```

The resulting Markdown widget will contain a single line of text with the
emoji preserved in the formatted text output.

The second method for including emoji glyphs is to provide the Markdown
widget with a syntax extension for inline emoji tags. The Markdown
package includes a syntax extension for emojis, EmojiSyntax. The default
extension set used by the Markdown widget is the GitHub flavored extension
set. This pre-defined extension set approximates the GitHub supported
Markdown tags, providing syntax handlers for fenced code blocks, tables,
auto-links, and strike-through. To include the inline emoji tag syntax
while maintaining the default GitHub flavored Markdown behavior, define
an extension set that combines EmojiSyntax with ExtensionSet.gitHubFlavored.

```
import 'package:markdown/markdown.dart' as md;

Markdown(
    controller: controller,
    selectable: true,
    data: 'Insert emoji :smiley: here',
    extensionSet: md.ExtensionSet(
      md.ExtensionSet.gitHubFlavored.blockSyntaxes,
      [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
    ),
)
```

## Image Support

The `Img` tag only supports the following image locations:

- From the network: Use a URL prefixed by either `http://` or `https://`.

- From local files on the device: Use an absolute path to the file, for example by
  concatenating the file name with the path returned by a known storage location,
  such as those provided by the [`path_provider`](https://pub.dartlang.org/packages/path_provider)
  plugin.

- From image locations referring to bundled assets: Use an asset name prefixed by `resource:`.
  like `resource:assets/image.png`.

## Verifying Markdown Behavior

Verifying Markdown behavior in other applications can often be useful to track
down or identify unexpected output from the `flutter_markdown_x` package. Two
valuable resources are the
[Dart Markdown Live Editor](https://dart-lang.github.io/markdown/) and the
[Markdown Live Preview](https://markdownlivepreview.com/). These two resources
are dynamic, online Markdown viewers.

## Markdown Resources

Here are some additional Markdown syntax resources:

- [Markdown Guide](https://www.markdownguide.org/)
- [CommonMark Markdown Reference](https://commonmark.org/help/)
- [GitHub Guides - Mastering Markdown](https://guides.github.com/features/mastering-markdown/#GitHub-flavored-markdown)
  - [Download PDF cheatsheet version](https://guides.github.com/pdfs/markdown-cheatsheet-online.pdf)
