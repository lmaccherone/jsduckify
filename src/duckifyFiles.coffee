duckifyFile = require('./duckifyFile').duckifyFile

###
@method duckifyFiles
@param {Object} sourceFileMap key: filename, value: file as string
@param {String} prefix The root for this documentation
@param {Object} exportsAPIMap key: function/property identifier, value: full tree for this element

@return {Object} key: filename (same as sourceFileMap), value: duckified source file as a String
###
exports.duckifyFiles = (sourceFileMap, prefix, exportsAPIMap) ->
  duckifiedFileMap = {}

  # outputFiles
  for filename, sourceFileString of sourceFileMap
    duckifiedFile = duckifyFile(filename, sourceFileString, exportsAPIMap, prefix)
    if duckifiedFile?
      duckifiedFileMap[filename + '.js'] = duckifiedFile

  return duckifiedFileMap