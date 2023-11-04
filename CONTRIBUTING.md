# Team Note: Git Rebase Strategy and Warnings

## Objective

This note aims to clarify our team's approach to using `git rebase` for integrating changes from the `main` branch into feature branches. The goal is to maintain a clean, linear commit history.

### Strategy

1. **Local Feature Branches**: Always use `git rebase` to bring your local feature branches up-to-date with the latest changes from `main`.

    ```bash
    git fetch origin
    git rebase origin/main
    ```

2. **Before Pushing**: Prior to pushing your local changes to the remote repository, rebase your feature branch onto `main`.

    ```bash
    git fetch origin
    git rebase origin/main
    ```

3. **Conflict Resolution**: If conflicts arise during the rebase, resolve the conflicts for each commit.

4. **Force Push with Care**: After a successful rebase, a force push will be necessary. Use the `--force-with-lease` option to ensure you don't overwrite others' work.

    ```bash
    git push origin <your-feature-branch> --force-with-lease
    ```

#### Warnings

1. **Never Rebase Public Branches**: Rebasing rewrites history. Never use it on branches that multiple people are working on. Stick to using `git merge` for public or team branches.
  
2. **Avoid Blindly Force Pushing**: Always use `--force-with-lease` instead of `--force` to ensure you don't accidentally overwrite someone else's changes.

3. **Communicate**: Before and after you rebase, communicate with your team. Make sure no one is about to push to the same branch, and let them know when it's safe to push again.

4. **Double-Check**: Before initiating a rebase, always make sure you have the latest version of the `main` branch.

5. **Backup**: Before doing a rebase, it’s a good practice to create a backup of your current branch.

    ```bash
    git branch backup-my-feature-branch
    ```

##### Benefits

- Simplified and linear history.
- Easier to identify and understand changes.

---

Given the innovative and collaborative environment at XO, maintaining a clean and linear history can be particularly beneficial. It will facilitate a more efficient code review process and make it easier to understand the evolution of complex projects.
