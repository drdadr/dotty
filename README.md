# dotty: The tiny dotfile manager

dotty lets you manage your dotfiles in a separate directory that can easily be put under version
control, e.g. git repository. It also let's you bootstrap your system config and run install/setup
scripts that configure your environment. It tries to a single thing (actually two) and do it well. 

The modular structure of dotty, including how to display help text, is forked from
[pyenv](https://github.com/pyenv/pyenv) and [rbenv](https://github.com/rbenv/rbenv).

### In Short: What does dotty do for you?

* Symlink dotfiles from a multiple directories tree into a given root folder (in most cases your
  home directory).
* When symlinking renaming files that start with `dot-` or `dot_` into `.`. This allows easier
  version management since your original files are not hidden.
* Run any executable scripts under `dotty-install` folders, so you can easily install your typical
  programs or perform configuration changes.
* Define different setups, e.g. private laptop, work laptop, in a `Dottyfile` so you can re-use the
  same dotfiles on different machines easily.

See [what does dotty do?](#what-does-dotty-do) for a more detailed description.

### But there's already stow, chezmoi, yadm

Probably there are as many dotfile managers as there programming languages /s:
https://dotfiles.github.io/utilities/

So why did I end up writing this myself?

* Lightweight, no dependencies required: I did not want to first install Python or Go, just to
  bootstrap my dotfiles. `bash` is already available on all systems I work with. This also means
  that I don't need sudo rights.
* Modular dotfiles: `dotty` makes it easy to share dotfiles between multiple setups/machines. While
  some dotfile managers, i.e. chezmoi, employ templating of dotfiles, I find that I often need
  completely different sets of dotfiles for different systems, e.g. home laptop vs work laptop, but
  still have a shared overlap that I would like to re-use.
* Bootstrap environment: Whenever I setup my dotfiles I typically execute a collection of scripts to
  install the packages, which are configured by the dotfiles.

Why not `stow`? You might notice the approach here is very similar to `stow`. I actually used `stow`
but upon extending my dotfiles, I got blocked by [issue
#33](https://github.com/aspiers/stow/issues/33). The issue has been open for close to 4 years, with
no resolution in sight. Unfortunately I lack the Pearl knowledge to contribute to it upstream, so I
opted to device my own dotfile manager, with a few more features that I was missing.

----

## Table of Contents

...

----

## What does `dotty` do?

Dotty allows you to distribute your dotfiles among multiple sub-directories inside a main directory,
which most likely will be version controlled using git, svn or else. These directories are referred
as _modules_ in this documentation. It will then create symlinks into a target directory for
pointing to these files with one layer removed. The typical target directory is of course your home
directory for typical dotfiles. You can have one folder for general dotfiles, one for work related
dotfiles, one for your raspberry pi dotfiles and so on. You can then freely mix and match these
dotfile _modules_ based on the host where you're setting up your dotfiles. See also [[dotty-link]]
and [[Dottyfile]] for more details. For ease of file management it will also rename files starting
with `dot-FILENAME` or `dot_FILENAME` to `.FILENAME`. That way your files aren't hidden by default
in your repository. 

Essentially it creates a symlink for every file like this:

<table>
<tr>
<th>dotfiles directory structure</th>
<th>home directory structure</th>
</tr>
<tr>
<td>
  
```
~/dotfiles/
├── general/
│   ├── dot_bash_profile
│   └── bin/
│       └── some_script
└── private_laptop/
    ├── dot-alias
    └── some_folder/
        └── some_file
```
  
</td>
<td>

```
~/
├── .bash_profile --> ./dotfiles/general/dot_bash_profile
├── bin/
│   └── some_script --> ../dotfiles/general/bin/some_script
├── .alias --> ./dotfiles/private_laptop/dot-alias
└── some_folder/
    └── some_file --> ../dotfiles/private_laptop/some_folder/some_file
```

</td>
</tr>
</table>

Dotty will keep track of the specified modules when you first linked your dotfiles, it will also
keep track of all the links it has created. This allows you to easily remove all links and re-link
your setup in case you have added or removed files from your dotfiles repository.

Dotty does link only files not folders. This allows you to link multiple files from different
modules into the same folder in your home directory. A good example for this is a shared `~/bin`
folder where you store your commonly used scripts. If dotty would symlink the folder the whole
folder could only come from a single module. But since dotty only links files, you can have more
than multiple modules with `bin` folders and all your scripts will get symlinked into `~/bin`. 

In case you commonly perform certain other setup tasks, dotty provides convenient way to manage
these as well. Every module can have a `dotty-install` directory. These won't get symlinked but
after you have linked your dotfiles and hence defined the modules to be used on this host, you can
run `dotty install` which will execute all scripts in alphabetical order it finds in your linked
modules. That way you can taylor common setup tasks, e.g. create python virtual environments or
install dependencies, to your dotfile setup. 


----

## Your Dotfile Directory Structure

By default it expects your dotfiles to live in `~/dotfiles/` but you can change this by setting the
environment variable `DOTTY_SOURCE_DIR` to point to the directory where your dotfiles reside. Dotty
will identify each directory directly below your dotfiles directory as modules. Any top level files
will be ignored with the exception of a file called `Dottyfile` that can contain recipes (see
[[Dottyfile]]). For every file found within a module dotty will create a symlink, renaming targets from `dot-` or `dot_` to `.`. Optionally you can also add a `dotty-install` folder to a module in which executable scripts reside that can be launched via `dotty install`.

Short example:
```
~/dotfiles/
├── general/
│   ├── dotty-install/
│   │   └── install_pyenv
│   ├── dot_bash_profile
│   └── bin/
│       └── some_script
├── private_laptop/
│   ├── dotty-install/
│   │   └── install_cool_game
│   ├── dot-alias
│   └── some_folder/
│       └── some_file
├── work_laptop/
│   ├── dotty-install/
│   │   └── setup_dev_environment
│   ├── bin/
│   │   └── work_script
│   └── dot-alias
└── Dottyfile
```

See [[dotfiles-public]] for the public part of my own dotfiles that are managed via dotty. 