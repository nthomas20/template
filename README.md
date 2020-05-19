# template
Initial Template

This repository serves as an initial template for my favourite github repository configuration

# CHANGELOG

Changelog automation using well-formed commit messages using [git-chglog](https://github.com/git-chglog/git-chglog)

Be sure to update the repository url in `/.chglog/.config.yml`

`repository_url: #UPDATE_REPOSITORY_URL`

## Generate a new CHANGELOG.md

* `git-chglog -o CHANGELOG.md`

# RELEASE TAG

There is a script that will manage these steps [release.sh](https://github.com/nthomas20/template/blob/master/scripts/release.sh)

* `git-chglog --next-tag v0.0.1 -o CHANGELOG.md`
* `git commit -m 'changelog' CHANGELOG.md`
* `git push`
* `git tag v0.0.1`
* `git push origin v0.0.1`

# ISSUE AUTOMATION

[create-issue-branch](https://github.com/robvanderleek/create-issue-branch)

* Assign the issue to an individual and it will create a branch
  * The configuration here is for short name (e.g. `issue-1`)
* This will add a comment in the issue with a link to the branch (you may need to refresh to see the comment immediately)
  * `git pull && git checkout issue-1`