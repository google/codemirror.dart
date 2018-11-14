## Updating CodeMirror with Bower

(Don't have Bower? Install it from http://www.bower.io.)

- Update `bower.json` and change the version number for the `codemirror`
  dependency.
- Update the version number in the `README_.google` file.
- Run `bower install` (or `grind install`). 
- Run `grind build`. (Don't have `grind`? Install it using `pub global activate grinder`.)
- Update the `changelog.md` file.

## publishing the package

- `git pull`
- comment out the `# Ignore the codemirror copied resources.` lines in the `.gitignore` file
- `pub publish`
- comment back in the lines
- from the github UI, create a new release with the pub package version
