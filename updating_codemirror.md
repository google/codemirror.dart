# Updating CodeMirror.dart

There are two groups of steps to carry out when updating the version of
CodeMirror that this package uses. The first revolve around updating
the CodeMirror dependencies from Bower, and the second around publishing
the updated [pub](https://pub.dartlang.org) package.

## Updating CodeMirror with Bower

(Don't have Bower? Install it from [bower.io](http://www.bower.io.))

- Update `bower.json` and change the version number for the `codemirror`
  dependency.
- Update the version number in the `README_.google` file.
- Run `bower install` (or `grind install`).
- Run `grind build`. (Don't have `grind`? Install it using `pub global activate grinder`.)
- Update the `changelog.md` file.

## Publishing the package

- `git pull`
- comment out the `# Ignore the codemirror copied resources.` lines in the `.gitignore` file
- `pub publish`
- comment back in the lines
- from the github UI, create a new release with the pub package version
