_type = do ->  # from http://arcturo.github.com/library/coffeescript/07_the_bad_parts.html
  classToType = {}
  for name in "Boolean Number String Function Array Date RegExp Undefined Null".split(" ")
    classToType["[object " + name + "]"] = name.toLowerCase()

  (obj) ->
    strType = Object::toString.call(obj)
    classToType[strType] or "object"

_getExportsAPI = (root, exportsAPI, currentPrefix = '') ->
  for key, value of root
    if currentPrefix.length > 0
      fullName = currentPrefix + '.' + key
    else
      fullName = key
    nameArray = fullName.split('.')
    baseName = nameArray[nameArray.length - 1]
    type = _type(value)
    row = {fullName, baseName, type}
    exportsAPI.push(row)

    if type == 'object'
      _getExportsAPI(value, exportsAPI, fullName)

###
@method documentExportsAPI
@param {String} moduleDirectory
@return {Array} {baseName, fullName, type}

This function will `require` the CoffeeScript directory under the assumption that it's a package.
That will reveal the published API (tree) of namespaces, classes, properties, functions, etc.
This function crawls that tree extracting the namespace structure for the package's API. This is
later used to make sure the jsduck documentation indicates the same namespace tree.
###
exports.documentExportsAPI = (moduleDirectory) ->
  exportsAPI = []
  _getExportsAPI(require(moduleDirectory), exportsAPI)

  return exportsAPI