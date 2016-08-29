# htz-git-hooks

  > Git hooks for use with the [git-hooks](https://www.npmjs.com/package/git-hooks) npm module

This hooks are aimed at enforcing basic policies and keeping the development flow in check.

The different hooks take care of the following issues:

- **Syncing Dependencies:** `npm` and `jspm` dependencies will be automatically updated whenever 
  the configuration file (`package.json` and `jspm.config.js`, respectively) is changed by another 
  developer.
- **Preventing commits to `master`:** Every new feature or bugfix should be done in its own separate
  branch, and no code should be committed directly to master. The `pre-commit` hook prevents that from
  happening. If you are really sure you know what you're doing, you can pass the `-n` flag to `git commit`
  in order to bypass the hook.
- **Warns when trying to commit unresolved conflicts**
- **Guards against force pushing and branch deletion:** The `pre-push` hook prevents deleting or 
  force pushing to long-lived branches (`master`, `dev` and `release` branches). To prevent accidental
  deletion, once a release is tagged and ready for deployment, the branch can be only be deleted 
  through GitHub.
- **All branches should be derived off of `master`:** The `post-checkout` hook will warn when trying 
  to create a branch off of another branch, which isn't `master`, and will suggest to re-create it
  as a child of master.

