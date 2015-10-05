Possible Further Improvements
-----------------------------

## What about moving files to the trash?

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



### OS X Trash candidates

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
