Construct #27 - Exploring Mozilla JetPack
========================================

* [Mozilla JetPack Homepage](http://mozillalabs.com/jetpack)
* [JetPack Docs](https://jetpack.mozillalabs.com/sdk/0.4/docs/#guide/getting-started)

JetPack Basics
--------------
1. Re-write of JetPack Prototype extension
    - Re-written as an SDK
    - Not fully re-written yet, more to come.
* Command-line driven toolkit.
    - `source bin/activate` - Enter devel environment
    - `deactivate` - Leave devel environment
    - `cfx` tool
        - `cfx --help`
    - `local.json` config
* Packages
    - create new *package* under `packages` directory
    - Directory layout
        - `data/` - contains data (images, xml, json, etc...) to be packaged
                    with your extension
        - `docs/` - Module docs in *markdown* format.
        - `lib/` - Source code arranged in modules.
        - `tests/` - Unit test files.
        - package.json - Metadata about your extension
        - README.md (this file)
* Source Code (`packages/<package_name>`)
    - lives in `lib` directory
    - arranged as JS modules.
    - e.g., `lib/utils.js`
    - *main* code lives in `lib/main.js`
* Includes Unit Test framework
    - `tests/test-<module>.js`
    - e.g., `tests/test-utils.js`
    - `cfx test` - from package root to run all package tests.
* Documentation
    - README.md (this file) - lives in package root.
    - lives in `docs` directory
    - Written in *markdown*
    - one file per module
* Very limited UI functionality at the moment.
    - Context Menus
    - Widgets, i.e. buttons
        - Show up on *widget* bar just above status bar.
* Running your code while developing
    - `cfx --use-config=ff run` - from package root, will start ff with extension enabled.
* Creating an XPI package
    - `cfx xpi` - Will create <package_name>.xpi in directory run from
    - Creates an installable extension

Demo
----
1. Start WM devel
2. ...
