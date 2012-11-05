   
_space = (level, multiplier = 4) ->
  return new Array(level * multiplier + 1).join(' ')
  
_blankDocstring = (level) ->
  s =  _space(level) + '/**\n'
  s += _space(level) + ' *\n'
  s += _space(level) + ' */\n'
 
_outputDocstring = (docstring, level = 0) ->
  a = docstring.split('\n')
  # Remove trailing blank lines
  while /^\s*$/.test(a[a.length - 1])
    a.pop()
  s = _space(level) + '/**' + a.join('\n' + _space(level) + ' * ') + '\n' + _space(level) + ' */\n'
  return s

_outputFunction = (func, level = 0, equalOrColon = ': ', prefix = '') ->
  if func.docstring? 
    s = _outputDocstring(func.docstring, level)
  else
    s = _blankDocstring(level)
  nameSplit = func.name.split('.')
  name = nameSplit[nameSplit.length - 1]
  unless prefix == ''
    name = prefix + '.' + name
  s +=  _space(level) + name + equalOrColon + 'function(' + func.params.join(', ') + '){}'
  return s
  
_outputFunctions = (functions, level = 0, equalOrColon = ': ', between = ',', after = '', prefix = '') ->
  funcs = []
  for f in functions
    funcs.push(_outputFunction(f, level, equalOrColon, prefix))
  return funcs.join(between + '\n\n') + after

_outputClassHeader = (name, docstring, level, prefix = '') ->
  a = []
  if docstring? 
    a.push(_outputDocstring(docstring, level))
  else
    a.push(_blankDocstring(level))
  a.push(_space(level) + 'Ext.define("')
  unless prefix == ''
    a.push(prefix + '.')
  a.push(name)
  a.push('", {\n')
  return a.join('')
  
_outputClassEnd = (level) ->
  return _space(level) + '});\n\n'

_outputClass = (cls, level = 0, prefix = '') ->
  a = []
  
  # Class Header
  a.push(_outputClassHeader(cls.name, cls.docstring, level, prefix))
  
  clsElements = []
  
  # extend
  if cls.parent?
    extendElements = []
    extendElements.push('extend: "')
    unless prefix == ''
      extendElements.push(prefix + '.')
    extendElements.push(cls.parent)
    extendElements.push('"')
    clsElements.push(_space(level + 1) + extendElements.join(''))
  
  # statics
  unless cls.staticmethods.length == 0
    staticsString = _space(level + 1) + 'statics: {\n' +
        _outputFunctions(cls.staticmethods, level + 2) + '\n' +
      _space(level + 1) + '}'
    clsElements.push(staticsString)
    
  # methods
  unless cls.instancemethods.length == 0
    clsElements.push(_outputFunctions(cls.instancemethods, level + 1))
        
  a.push(clsElements.join(',\n\n'))
  
  a.push('\n')
  
  # close Class
  a.push(_outputClassEnd(level))
  return a.join('')
  
exports.outputModule = (module, prefix = '') ->
  a = []
    
  # Classes
  classes = []
  if module.classes.length > 0
    for c in module.classes
      classes.push(_outputClass(c, 0, prefix))
    a.push(classes.join('\n'))
    
  # Functions
  a.push(_outputClassHeader(prefix, module.docstring, 0, ''))
  if module.functions.length > 0
    a.push(_outputFunctions(module.functions, 1))
  a.push('\n' + _outputClassEnd(0))
  
  return a.join('')