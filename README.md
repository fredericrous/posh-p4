posh-p4
=======

Perforce PowerShell integration. Prompt info and command line autocompletion

### Prompt for Perforce workspaces
   Show the current depot and the state of files (additions, modifications, deletions) within prompt

### Tab completion
   Provides tab completion for common commands when using perforce.
   E.g. `git a<tab>` --> `git add`


Usage
-----

See `profile.example.ps1` as to how you can integrate the tab completion and/or git prompt into your own profile.

If prompt shows a ! instead of the depot tree, it means you have too many views sync to the same folder. Script is limited to 1.
It could also mean your are not connected to perforce. try command `p4 where ...`

Note on performance: If you navigate at the root of a large repo, prompt will be slow.
posh-p4 uses `p4 status ...` to know which are files to add or to delete.. there might be other commands that are faster


Installing via OneGet
--------------------

run in powershell command:

```
Install-Module posh-p4
```


Installing manually
--------------------

Create folder C:\Users\<UserName>\Documents\WindowsPowerShell\Modules\posh-p4
Copy all files from this repo there.
run command:

```
Install-Module posh-p4
```


Inspired by
-----------
- posh-git
- posh-npm
- oh-my-zsh <3
