# autoload-cscope

### Changelog

#### 2017-11-23
 - Add command for rebuilding cscope database inside your project.

### Description
This is a fork of http://www.vim.org/scripts/script.php?script_id=157

This plugin will automatically look for cscope.out databases when you open any file.

It does a search starting at the directory that the file is in, and checking the parent directories until it find the cscope.out file.  The idea being that you can start editing a source file deep in a project dir, and it will find the correct cscope database a couple dirs up.
