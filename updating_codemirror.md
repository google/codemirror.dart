# Updating CodeMirror.dart

There are two groups of steps to carry out when updating the version of
CodeMirror that this package uses. The first revolve around updating
the CodeMirror dependencies from Bower, and the second around publishing
the updated [pub](https://pub.dartlang.org) package.

## Updating CodeMirror 

- Download the latest zip ball from [codemirror.net/codemirror.zip](https://codemirror.net/codemirror.zip)
- Replace the contents of `third_party/codemirror` with the content of the above download
- Update the version number in the `README_.google` file.
- Run `grind build`. (Don't have `grind`? Install it using `pub global activate grinder`.)
- Update the `changelog.md` file.

## Publishing the package

- `git pull`
- comment out the `# Ignore the codemirror copied resources.` lines in the `.gitignore` file
- Verify the build with `pub publish --dry-run`
  - Confirm the `lib` directory contains
    `addon`, `codemirror.js`, `css`, `keymap`, `mode`, and `theme`
- Publish for real with `pub publish`
- comment back in the lines
- from the github UI, create a new release with the pub package version
