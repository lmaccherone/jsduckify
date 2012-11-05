parseModule = require('./parseModule').parseModule
outputModule = require('./outputModule').outputModule

exports.outputSources = (sourceFileStrings, prefix, docstring) ->
  if typeof sourceFileStrings == 'string'
    module = parseModule(sourceFileStrings)
  else
    modules = (parseModule(s) for s in sourceFileStrings)
    classes = []
    functions = []
    for m in modules
      classes = classes.concat(m.classes)
      functions = functions.concat(m.functions)
    module = {classes, functions, docstring}
    
  moduleString = outputModule(module, prefix)
  return moduleString

