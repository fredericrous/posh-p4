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
