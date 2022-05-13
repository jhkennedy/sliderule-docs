---
layout: single
title: "Tweaking Ubuntu and Visual Studio Code"
date: 2020-01-01 12:00:00 -0400
toc: true
toc_sticky: true
category: developer
---

## 1. Configure Git

To access the github repository you must add the ssh public key on your computer into the github server hosting your repository. To generate a key, use `ssh-keygen` to create your local key, then copy and paste it into the key management page found at Settings > SSH and GPG Keys
```bash
ssh-keygen -t rsa -C "your.email@example.com" -b 4096
cat ~/.ssh/id_rsa.pub
```

To use your key to access a remote repository not on the github server, then copy the contents of `~/.ssh/id_rsa.pub` into the authorized key file for the git account on the remote server hosting the repository.
```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub git@{hostname or IP address}
```

To begin using git make sure you first set your name and email as follows:
```bash
git config --global user.name "Your Name"
git config --global user.email "Your Email"
```

### Additions to .bashrc 

To have the conda environment and the git branch displayed on the terminal prompt:
```bash
force_color_prompt=yes

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

if [ "$color_prompt" = yes ]; then
    PS1="\n${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]\[\033[33m\] [\$CONDA_DEFAULT_ENV]\$(parse_git_branch):\[\033[01;34m\]\w\[\033[00m\]\n\$ "
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

unset color_prompt force_color_prompt
```

Note that in order to remove the default conda change the terminal prompt, run the following:
```bash
$ conda config --set changeps1 False
```

### Contents of .gitconfig
```
[push]
    default = simple

[diff]
    tool = meld

[merge]
    tool = meld

[difftool]
    prompt = false

[mergetool]
    keepBackup = false

[difftool "meld"]
    cmd = meld "$LOCAL" "$REMOTE"

[alias]
    dd = difftool --dir-diff
```


## 2. Install Git LFS (Large File Storage)

In order to properly checkout the ICESat2-SlideRule/resources repository, you must first install Git LFS using the following commands:
```bash
$ sudo apt install git-lfs
$ git lfs install
```

After the package is installed, the initial clone of the resources repository must be done as follows:
```bash
$ git lfs clone <resources repos>
```

After the initial clone, no other steps are necessary.  All pdf, docx, and other binary-like files will have local copies of only the latest version.  All git operations and workflows remain the same.


## 3. Tweak Ubuntu Desktop

### To change caps lock
* `sudo apt install gnome-tweak-tool`
* Run `gnome-tweaks` to remap keys as desired


## 4. Configure Visual Studio Code

Install and configure the following exentions
* C/C++ (Microsoft)
* Git Lens - Git supercharged (Eric Amodio)
  - Gitlens > Code Lens: Enabled --> Disabled
* Lua (keyring)
* Python (Microsoft)
* CMake (twxs)
* Dracula (official theme)

### Contents of {project}/.vscode/tasks.json
```
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558 
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        {
            "type": "shell",
            "label": "make",
            "command": "make",
            "problemMatcher": [
                "$gcc"
            ],
            "group": "build"
        }
    ]
}
```

### Contents of ~/.config/Code/User/keybindings.json
```
[
    {
        "key": "ctrl+e",
        "command": "cursorEnd",
        "when": "textInputFocus"
    },
    {
        "key": "end",
        "command": "-cursorEnd",
        "when": "textInputFocus"
    },
    {
        "key": "ctrl+a",
        "command": "cursorHome",
        "when": "textInputFocus"
    },
    {
        "key": "home",
        "command": "-cursorHome",
        "when": "textInputFocus"
    },
    {
        "key": "ctrl+e",
        "command": "-workbench.action.quickOpen"
    },
    {
        "key": "ctrl+e",
        "command": "-workbench.action.quickOpenNavigateNextInFilePicker",
        "when": "inFilesPicker && inQuickOpen"
    },
    {
        "key": "ctrl+a",
        "command": "-editor.action.selectAll",
        "when": "textInputFocus"
    },
    {
        "key": "ctrl+a",
        "command": "-editor.action.webvieweditor.selectAll",
        "when": "!editorFocus && !inputFocus && activeEditor == 'WebviewEditor'"
    },
    {
        "key": "ctrl+a",
        "command": "-list.selectAll",
        "when": "listFocus && listSupportsMultiselect && !inputFocus"
    },
    {
        "key": "ctrl+b",
        "command": "-workbench.action.toggleSidebarVisibility"
    },
    {
        "key": "ctrl+b",
        "command": "editor.action.revealDeclaration"
    },
    {
        "key": "ctrl+d",
        "command": "editor.action.revealDefinition",
        "when": "editorHasDefinitionProvider && editorTextFocus && !isInEmbeddedEditor"
    },
    {
        "key": "f12",
        "command": "-editor.action.revealDefinition",
        "when": "editorHasDefinitionProvider && editorTextFocus && !isInEmbeddedEditor"
    },
    {
        "key": "ctrl+d",
        "command": "-editor.action.addSelectionToNextFindMatch",
        "when": "editorFocus"
    },
    {
        "key": "alt+left",
        "command": "-workbench.action.terminal.focusPreviousPane",
        "when": "terminalFocus"
    },
    {
        "key": "alt+left",
        "command": "-gitlens.key.alt+left",
        "when": "gitlens:key:alt+left"
    },
    {
        "key": "alt+left",
        "command": "workbench.action.navigateBack"
    },
    {
        "key": "ctrl+alt+-",
        "command": "-workbench.action.navigateBack"
    },
    {
        "key": "alt+right",
        "command": "workbench.action.navigateForward"
    },
    {
        "key": "ctrl+shift+-",
        "command": "-workbench.action.navigateForward"
    },
    {
        "key": "alt+right",
        "command": "-workbench.action.terminal.focusNextPane",
        "when": "terminalFocus"
    },
    {
        "key": "alt+right",
        "command": "-gitlens.key.alt+right",
        "when": "gitlens:key:alt+right"
    },
    {
        "key": "ctrl+g",
        "command": "editor.action.nextMatchFindAction",
        "when": "editorFocus"
    },
    {
        "key": "f3",
        "command": "-editor.action.nextMatchFindAction",
        "when": "editorFocus"
    },
    {
        "key": "ctrl+g",
        "command": "-workbench.action.gotoLine"
    },
    {
        "key": "ctrl+shift+g",
        "command": "editor.action.previousMatchFindAction",
        "when": "editorFocus"
    },
    {
        "key": "shift+f3",
        "command": "-editor.action.previousMatchFindAction",
        "when": "editorFocus"
    },
    {
        "key": "ctrl+shift+g",
        "command": "-workbench.view.scm"
    },
    {
        "key": "alt+.",
        "command": "workbench.action.terminal.focusNext"
    },
    {
        "key": "alt+,",
        "command": "workbench.action.terminal.focusPrevious"
    }
]
```
