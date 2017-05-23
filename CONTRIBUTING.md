# How to Contribute

CSI is under [Apache 2.0](LICENSE) and accepts contributions via GitHub pull requests.
This document outlines some of the conventions on development workflow, commit message formatting, contact points and other resources to make it easier to get your contribution accepted.

## Markdown style

To keep consistency throughout the Markdown files in the CSI spec, all files should be formatted one sentence per line.
This fixes two things: it makes diffing easier with git and it resolves fights about line wrapping length.
For example, this paragraph will span three lines in the Markdown source.

## Code style

This also applies to the code snippets in the markdown files.

* Please wrap the code at 72 characters.

## Git commit

### Commit Style

Simple house-keeping for clean git history.
Read more on [How to Write a Git Commit Message](http://chris.beams.io/posts/git-commit/) or the Discussion section of [`git-commit(1)`](http://git-scm.com/docs/git-commit).

* Separate the subject from body with a blank line.
* Limit the subject line to 50 characters.
* Capitalize the subject line.
* Do not end the subject line with a period.
* Use the imperative mood in the subject line.
* Wrap the body at 72 characters.
* Use the body to explain what and why vs. how.
  * If there was important/useful/essential conversation or information, copy or include a reference.
* When possible, one keyword to scope the change in the subject (i.e. "README: ...", "tool: ...").
