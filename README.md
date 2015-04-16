OS X Package Uninstaller
========================

by Benjamin Gandon © 2015


Overview
--------

`pkg-uninstall` is a command line tool that helps in uninstalling OS X
packages.

Several safe-guards are implemented in `pkg-uninstall` to ensure that
the uninstallation process is somehow kept under control. But it will
not prevent you from doing silly things like uninstalling core
packages that are vital to your OS X system and applications.

This is inherent to OS X Packages. Thus, you are strongly advised to
make a backup copy of your system prior to using `pkg-uninstall`. Go
and setup [Time Machine](https://support.apple.com/HT201250) for that.


Usage
-----

General usage form is:

    pkg-uninstall [options] <package-id> ...

Where package identifiers are to be found in the list of installed
packages, as returned by `pkgutil --pkgs`.

So you should first make a backup copy of your system. Then, you
should dry run `pkg-uninstall` with standard user privileges and the
`--dry-run` option:

    pkg-uninstall --dry-run <package-id>

With this, you'll see what would happen, without actually changing
anything to the system.

Once you're really sure of what you're doing, you might finally run:

    sudo pkg-uninstall <package-id>


### Options

Several options can be specified.

* `--help`: display usage informationdisplay usage information.

* `--version`: display version number.

* `--dry-run` (highly recommended for a first use): Explain what would
  happen during the uninstallation, without actually modifying the
  system. When running the tool with this option, you don't need
  superuser privileges.

* `--verbose`: be verbose about directories and files that are listed
  as part of the installed package, but that cannot be actually found
  in the file system.

* `--force`: force uninstallation, even if some directories or some
  files are actually missing on the file system. This just bypasses
  safeguards that have the tool stop early in the process. It does not
  enforce any operations that are prevented by `--dry-run`.

* `--prefix-dir`: specify one single installation prefix directory for
  all packages to uninstall, instead of fetching their individual
  `InstallPrefixPath` values that are stored in the receipts
  database. Package directories and files will have this directory
  prepended before tring to remove them from the file system. Both
  `--prefix-dir=<dir>` and `--prefix-dir <dir>` syntaxes are
  supported.

* `--infer-prefix-dir`: for each package to uninstall, do not use the
  `InstallPrefixPath` value, but infer a suitable directory
  instead. This might take a long time to run. See below for more
  details.


### Safeguards

* Check that all specified packages are listed as installed before
  proceeding. Stop with failure message if one of them is not.

* Check that the directories and files (that are listed as part of the
  packages) are actually present on the file system, taking any
  installation prefix directory into account. Report any issue about
  that (with details when `--verbose`). Advise the user to `--force`
  uninstallation to proceed any further.


### Caveats

`pkg-uninstall` supports files and directories that include blanks
like spaces and tabs. But it does *not* supports new line (LF) and
double quotes (") charaters in filenames. If run into such situation,
then a rewrite in Perl or any similar language would be necessary to
obtain the required robustness.


Further Documentation
---------------------

### What is an *OS X Installer Package*?

These are `.pkg` files that are meant to be fed into the
[OS X Installer](https://en.wikipedia.org/wiki/Installer_(OS_X))
application. Apple introduced this concept to standardize the
installation of system packages and applications. Without really
thinking of any uninstallation step, though.

Identifiers of installed packages are listed by:

    pkgutil --pkgs

And the contents of a package can be inspected with:

    pkgutil --files <package-id>

But keep in mind that these files could be installed anywhere on your
system during the installation process.

Moreover, the *receipts database*, that stores information about
installed *OS X Installer Packages* dosen't implement anything like
dependency management. So, it cannot tell you: “Hey, you can't
uninstall this package because that one depends on it”. As a
consequence, uninstalling one of the installed packages could break
anything in the system or any application.

Thus, there is
[no built-in OS X tool](http://superuser.com/q/36567) to uninstall
such packages in an automated manner.

Packages are not well designed to be uninstalled, and doing it is a
pain. This tool was written as an attempt to solve this problem. Just
like
[PackageUninstaller](https://github.com/hewigovens/PackageUninstaller),
but as a command-line tool.


### Curious about the *Receipts Database*?

To browse the install history, just run:

    plutil -p /Library/Receipts/InstallHistory.plist | less

And if you need to inspect the receipts database further:

    ls /var/db/receipts
    plist -p /var/db/receipts/<package-id>.plist
    defaults read /var/db/receipts/<package-id>.plist InstallPrefixPath


### Unsure about the right *Installation Prefix Directory*?

When specifying `--infer-prefix-dir` (without specifying any
`--prefix-dir`), `pkg-uninstall` will infer a suitable installation
prefix directory for each specified package. This is an alternative to
retrieving the `InstallPrefixPath` values from the *receipts
database*, where OS X stores information about installed packages.

This alternative might be useful if the package has been moved or
installed in a directory that is not the one that has been declared.

The algorithm performs the following steps:

* List all package *directories* and `locate` them in the
  filesystem. Note that your `locate` database should be up-to-date
  for this to work reliably.
* When all the directories listed in a package can be found in one
  single prefix directory, use it as installation prefix directory.
* In case of multiple matches, advise the user to specify a
  `--prefix-dir`
* In case no prefix can help finding all the package files and
  directories, advise the user to specify a `--prefix-dir`

For this to work as expected, your `locate` database should be
up-to-date. If unsure about whether it actually is, just refresh it
prior to running `pkg-uninstall --infer-prefix-dir`:

    sudo /usr/libexec/locate.updatedb

You'll notice this takes some time for all your file system to get
indexed.


### References

* [How do I uninstall any Apple pkg Package file?](http://superuser.com/q/36567)
* [Uninstall applications installed from packages](http://hints.macworld.com/article.php?story=20100107090139622)
* [hewigovens/PackageUninstaller](https://github.com/hewigovens/PackageUninstaller)
* [Uninstalling .pkg files on OSX](http://en.newinstance.it/2010/04/21/uninstalling-pkg-files-on-osx/)
* [The “Packages” (app) resources](http://s.sudre.free.fr/Software/Packages/resources.html)


Further Improvements
--------------------

### What about moving files to the trash?

It would be nice that `pkg-uninstall` moves the uninstalled package
directories and files to the user's trash, instead of permanently
removing them right away. This could be made leveraging some `trash`
command-line tool that would be present.

Many candidates exist, with different levels of features. Ali
Rantakari's `trash` looks like the best available option, though.

Several challenges would arise, then:

* Ensure we're actually facing a supported version of the `trash`
  utility.
* When removing structures of directories and files, that are
  specified starting from the root `Library` folder, we should not
  move the `/Library` to the trash all together. In order not to flood
  the trash with individual files and folders, `pkg-uninstall` would
  have to comput a minimal set of parent directories that, once moved
  to the trash, ensure that package files are properly uninstalled.
* The final `pkgutil --forget` command would have to be emulated with
  calls to `trash`. This might break with any future OS X releases
  that would implement the receipts database differently.


#### OS X Trash candidates

* `trash` by Ali Rantakari
  - Available in Homebrew: `brew info trash`
  - Project home: http://hasseg.org/trash/
  - Blog post: http://hasseg.org/blog/post/406/trash-files-from-the-os-x-command-line/
    * Discusses osxutils’ original `trash` by Sveinbjörn Þórðarson (see below)
    * Discusses `osx-trash`h by Dave Dribin (see below)
  - Github: https://github.com/ali-rantakari/trash
    * Last update: 2014-12-09
  - Source code: https://github.com/ali-rantakari/trash/blob/master/trash.m
    * Written in C, and Objective-C
    * quite bloated code, but highly commented
    * Sends a `NSAppleEventDescriptor` (containing all the files to
      delete) with event class `'core'` and event ID `'delo'` using
      the `AESendMessage()` function (which is faster than
      AppleScript, according to the author)
    * Can alternatively call `FSMoveObjectToTrashSync()` when
      requested to use the system API, though privileged files will
      still be trashed by the Finder
  - Features:
    * Properly doesn’t follow leaf symlinks
    * Properly shows only one authentication dialog
    * Properly supports multiple volumes trashes
    * Properly supports Finder's Undo and "Put Back" features,
      updating `~/.Trash/.DS_Store` accordingly
    * Properly warns the user that when run as root, the items will go
      to the trash of the root user, which might not be what the user
      expects
  - Caveats:
    * Improperly prompts an inerrupting authentication dialog when
      trashing privileged files, which is not the spirit of any
      command-line tool

* `trash` by Morgan Aldridge
  - Project home: http://www.makkintosshu.com/development#tools-osx
  - Blog post: http://apple.stackexchange.com/questions/50844/how-to-move-files-to-trash-from-command-line
  - Github: https://github.com/morgant/tools-osx
    * Last update: 2015-01-08
  - Source code: https://github.com/morgant/tools-osx/blob/master/src/trash
    * Written in: plain Bash script
    * Uses one ApplScript command `tell application "Finder" to delete
      POSIX file "<file-path>"` per file, which is slow (because
      sending a list of files would be faster: `{(POSIX file
      "/path/one"), (POSIX file "/path/two")}`) and triggers many
      authentication prompts by the Finder, one for each individual
      privileged file.
    * Awful bloated code style. Unreadable `realpath()` function, for
      instance.
  - Features:
    * Properly doesn’t follow leaf symlinks
    * Properly doesn't clobber existing trashed files upon filename
      collision
    * Properly supports multiple volumes trashes (when not run from a
      `screen` shell)
    * Properly supports Finder's Undo and "Put Back" features,
      updating `~/.Trash/.DS_Store` accordingly (when not run from a
      `screen` shell)
  - Caveats:
    * Improperly sends individual AppleScript commands for each item
      to delete, which is slow
    * Improperly has the Finder prompt individual authentications,
      when deleting multiple privileged files.
    * Does not delegate to Finder when run from a `screen` shell
      (which breaks support for Finder's Undo and "Put Back" and
      proper multiple volumes trashes)
    * Improperly doesn't warn the user for items going to the trash of
      the root user, when run as root
    * Improperly prompts inerrupting authentication dialogs when
      trashing privileged files, which is not the spirit of any
      command-line tool

* osxutil's `trash` by Sveinbjorn Thordarson
  - Project home: http://sveinbjorn.org/osxutils
  - Sourceforge: http://sourceforge.net/projects/osxutils/
    * Last update: 2004-12-13
  - Source code (SVN): http://osxutils.cvs.sourceforge.net/viewvc/osxutils/osxutils/src/trash?revision=1.1&view=markup
    * Written in: Perl
    * Delegates to the system's `mv` (i.e. not using any Perl built-in or module)
  - Features:
    * Mere move to the Trash folder
    * Properly doesn’t follow “leaf” symbolic links
    * Properly doesn't clobber existing trashed files upon filename
      collision
    * Properly doesn't prompt any inerrupting authentication dialog
      when trashing privileged files, and properly report any errors
      on `/dev/stderr` instead
  - Caveats:
    * Improperly has a buggy renaming code, with improper renaming
      scheme: `file`, then `file copy 1`, then `file copy 1 copy 1`
    * Improperly moves all trashed files onto the same volume
    * Improperly provides no support for Finder's Undo and "Put Back"
      features

* improved `trash` of osxutil's fork by Dave Vasilevsky
  - Available in Homebrew: `brew info osxutils`
  - Github: https://github.com/vasi/osxutils
    * Last update: 2013-11-26
    * Says he rewrote 'trash' so it properly renames files
  - Source code: https://github.com/vasi/osxutils
    * Written in Perl
    * Uses standard Perl modules for path manipulations
    * Uses the `move` method of the `File::Copy` module
  - Features:
    * Properly doesn't clobber any existing trashed files upon
      filename collision
    * Properly tries trashing all files even when encountering any
      error like inability to trash a privileged file
    * Properly doesn't prompt any inerrupting authentication dialog
      when trashing privileged files, and properly report any errors
      on `/dev/stderr` instead
  - Caveats:
    * Improperly moves all trashed files onto the same volume
    * Improperly provides no support for Finder's Undo and "Put Back"
      features

* `osx-trash` by Dave Dribin
  - Project home: http://www.dribin.org/dave/osx-trash/
  - Github: https://github.com/semaperepelitsa/osx-trash
    * Last update: 2011-05-01
  - Source code: https://github.com/semaperepelitsa/osx-trash/blob/master/bin/trash
    * Written in Ruby
    * Uses AppleScript via Scripting Bridge on top of RubyCocoa
    * Uses `SBApplication.applicationWithBundleIdentifier("com.apple.Finder").items.objectAtLocation(NSURL.fileURLWithPath(Pathname.new(file).realpath.to_s)).delete`
  - Features:
    * Properly supports Finder's Undo and "Put Back" features,
      updating `~/.Trash/.DS_Store` accordingly
  - Caveats:
    * Improperly follows leaf symbolic links
    * Improperly prompts inerrupting authentication dialog when
      trashing privileged files, which is not the spirit of any
      command-line tool
    * Improperly pops up many authentication dialogs, one for each
      file (due to a limitation in Scripting Bridge)
    * Improperly doesn't warn the user for items going to the trash of
      the root user, when run as root
    * Improperly provides no feedback about any errors, like failure
      to trash a privileged file, and always return success exit code

* `osx-trash` by Sindre Sorhus
  - Used by:
    * Cross-platform https://github.com/sindresorhus/trash (same author) on OS X
    * `npm`-available `node-osx-trash`, written in JavaScript: https://github.com/sindresorhus/node-osx-trash
  - Guide to safeguarding `rm`: https://github.com/sindresorhus/guides/blob/master/how-not-to-rm-yourself.md#safeguard-rm
  - Blog post: 
  - Github: https://github.com/sindresorhus/osx-trash
    * Last update: 2015-01-26
  - Source code: https://github.com/sindresorhus/osx-trash/blob/master/trash/main.m
    * Written in Objective-C
    * Uses a plain `[[NSFileManager defaultManager] trashItemAtURL]`
      method call, that appeared in OS X v10.8
    * Doesn't do anything fancy with symbolic links
  - Features:
    * Properly supports Finder's
      ["Put Back"](http://mac-fusion.com/trash-tip-how-to-put-files-back-to-their-original-location/)
      features, updating `~/.Trash/.DS_Store` accordingly
    * ¿Properly doesn't dereference non-leaf symbolic links?
    * ¿Properly doesn't prompt any inerrupting authentication dialog
      when trashing privileged files?
  - Caveats:
    * Improperly bails out when encountering a privileged files to
      trash, leaving any remaining files (privileged or not) unchanged
    * ¿Improperly doesn't support Finder's Undo feature?
    * Improperly doesn't warn the user for items going to the trash of
      the root user, when run as root

* `rmtrash` by Night Productions
  - Available in Homebrew: `brew info rmtrash`
  - Project home: http://www.nightproductions.net/cli.htm
    * Last update: 2005-01-18 (10 years old)
  - Source code (tarball): http://www.nightproductions.net/downloads/rmtrash_source.tar.gz


Contributing
------------

[Pull requests](http://help.github.com/send-pull-requests) are
welcome. Few guidelines should be observed, though:

- Your code should not break existing tests. Check this with `bats
  ./test`
- Your code should be easy to read.
- Your variable names should describe well the data they hold, in the
  context of what your code is doing.
- Your function names should properly describe what they do, in the
  cotext of your code (so that the name doesn't get too long).
- Your functions should be short and do one thing.
- Your code should include automated tests. Here we use the
  [BATS][] technology.

You'll also observe different conventions in main code, compared to
test code.

- Main code is developped following my own habits of portable shell
  code. That's why it looks a bit old fashionned, because bashisms
  constructs are avoided. Examples:
    * Use `expr a : b >/dev/null` in favor of `[[ a =~ b ]]`
    * Use back-ticks in favor of `$( ... )` (even though it disallows
      nesting, which sometimes complicates things a little)
    * Use `expr ...` in favor of `$(( ... ))`
    * Avoid arrays and hashes (and thus use Perl instead)
    * ...
- Test code is [BATS][], so all bashisms are allowed there. Because it
  must be run in Bash anyway.


License
-------

`pkg-uninstall` is released under [the MIT License](LICENSE.txt).

[BATS]: https://github.com/sstephenson/bats

<!--
# Local Variables:
# indent-tabs-mode: nil
# End:
-->
