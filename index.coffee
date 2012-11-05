exports.parseModule = require('./src/parseModule').parseModule
exports.outputModule = require('./src/outputModule').outputModule
exports.outputSources = require('./src/outputSources').outputSources

  
###
ToDos
  create a script to test Lumenize output with
    Delete the temporary .js file and put the results in a scratch directory
  add README.md as docstring for module
  supress source in output (there is a JSDuck option for this)
  remove unused code
  default output to the directoryname_duckified.js
  refactor names to cleanup "output" "module" "file" etc
  indention reformat
  cleanup docs
  see if I can remove the file reference
  what happens if you have two files with the same define? for instance lumenize with readme and lumenize for static functions. Hopefully they are merged.
  exclude private methods that start with _
  coffeeLint
  add parens for function calls in my coffeescript
  update my Cakefile to be oriented toward npm. Support test, publish, and rebuild (maybe). Put rebuild build stuff in the pretest and prepublish steps. Make sure coffeedoctests run as part of the build. Means I'll have to update coffeedoctest probably to support running from node_modules.
  more tests
  understand a config object... and mixins
  add support for Deps
  see if I can key off of exports. Would call for parsing package.json and looking at main and following requires. browserify follows requires so maybe I can look at how they do it.
  Travis CI
  usage in README.md
###