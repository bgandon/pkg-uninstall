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
double quotes (") charaters in filenames. If you run into such
situation, then a rewrite in Perl (or any similar language) will be
necessary to obtain the required robustness.


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
    plutil -p /var/db/receipts/<package-id>.plist
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
* [Uninstalling packages (.pkg files) on Mac OS X](https://wincent.com/wiki/Uninstalling_packages_%28.pkg_files%29_on_Mac_OS_X)
* [OSX Packages Uninstaller by Michal Papis](https://github.com/mpapis/pkg_uninstaller)
* [osx-pkg-uninstall.sh from radare2](https://github.com/radare/radare2/blob/master/sys/osx-pkg-uninstall.sh)

### Similar Commercial Tools

* [UninstallPKG](https://www.corecode.at/uninstallpkg/)


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
  context of your code (so that the name doesn't get too long).
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


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/bgandon/pkg-uninstall/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

