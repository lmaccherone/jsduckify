coffeescript = require('coffee-script')
    
_formatDocstring = (str) ->
    ###
    Given a string, returns it with leading whitespace removed but with
    indentation preserved. Replaces `\\#` with `#` to allow for the use of
    multiple `#` characters in markup languages (e.g. Markdown headers)
    ###
    lines = str.replace(/\\#/g, '#').split('\n')

#     # Remove leading blank lines
#     while /^\s*$/.test(lines[0])
#         lines.shift()
#     if lines.length == 0
#         return null

    # Get least indented non-blank line
    indentation = for line in lines
        if /^\s*$/.test(line) then continue
        line.match(/^\s*/)[0].length
    indentation = Math.min(indentation...)

    leading_whitespace = new RegExp("^\\s{#{ indentation }}")
    return (line.replace(leading_whitespace, '') for line in lines).join('\n')

_getDependencies = (nodes) ->
  ###
  This currently works with the following `require` calls:

      local_name = require("path/to/module")

  or

      local_name = require(__dirname + "/path/to/module")
  ###
  stripQuotes = (str) ->
      return str.replace(/('|\")/g, '')

  deps = {}
  for n in nodes when n.type == 'Assign'
    if n.value.type == 'Call' and n.value.variable.base? and n.value.variable.base.value == 'require'
      arg = n.value.args[0]
      if arg.type == 'Value'
        module_path = stripQuotes(arg.base.value)
      else if arg.type == 'Op' and arg.operator == '+'
        module_path = stripQuotes(arg.second.base.value).replace(/^\//, '')
      else
        continue
      local_name = _getFullName(n.variable)
      deps[local_name] = module_path
  return deps

_getClasses = (nodes) ->
  return (n for n in nodes when n.type == 'Class' or n.type == 'Assign' and n.value.type == 'Class')

_getFunctions = (nodes) ->
  return (n for n in nodes when n.type == 'Assign' and n.value.type == 'Code')
          
_getNodes = (script) ->
  ###
  Generates the AST from coffeescript source code.  Adds a 'type' attribute
  to each node containing the name of the node's constructor, and returns
  the expressions array
  ###
  root_node = coffeescript.nodes(script)
  root_node.traverseChildren(false, (node) ->
    node.type = node.constructor.name
  )
  return [].concat(root_node.expressions, root_node)
  
_getFullName = (variable) ->
    ###
    Given a variable node, returns its full name
    ###
    name = variable.base.value
    if variable.properties.length > 0
        name += '.' + (p.name.value for p in variable.properties).join('.')
    return name
  
_documentModule = (script) ->
  ###
  Given a module's source code and an AST parser, returns module information
  in the form:

      {
          "docstring": "Module docstring",
          "classes": [class1, class1...],
          "functions": [func1, func2...]
      }
  ###
  nodes = _getNodes(script)
#   nodes = _getNodes(nodes) if _getNodes
  first_obj = nodes[0]
  if first_obj?.type == 'Comment'
    docstring = _formatDocstring(first_obj.comment)
  else
    docstring = null

  classes = (_documentClass(c) for c in _getClasses(nodes))
  functions = (_documentFunction(f) for f in _getFunctions(nodes))
  deps = _getDependencies(nodes)
  doc =
    docstring: docstring
    deps: deps
    classes: classes
    functions: functions

  return doc


_documentClass = (cls) ->
    ###
    Evaluates a class object as returned by the coffeescript parser, returning
    an object of the form:
    
        {
            "name": "MyClass",
            "docstring": "First comment following the class definition"
            "parent": "MySuperClass",
            "methods": [method1, method2...]
        }
    ###
    if cls.type == 'Assign'
        # Class assigned to variable -- ignore the variable definition
        cls = cls.value

    # Check if class is empty
    emptyclass = cls.body.expressions.length == 0

    # Get docstring
    first_obj = if emptyclass
        cls.body.expressions[0]
    else
        cls.body.expressions[0].base?.objects?[0]
    if first_obj?.type == 'Comment'
        docstring = _formatDocstring(first_obj.comment)
    else
        docstring = null

    # Get methods
    staticmethods = []
    instancemethods = []
    for expr in cls.body.expressions
        if expr.type == 'Value'
            for method in (n for n in expr.base.objects when n.type == 'Assign' and n.value.type == 'Code')
                if method.variable.this
                    # Method attached to `this`, i.e. the constructor
                    staticmethods.push(method)
                else
                    # Method attached to prototype
                    instancemethods.push(method)
        else if expr.type == 'Assign' and expr.value.type == 'Code'
            # Static method
            if expr.variable.this # Only include public methods
                staticmethods.push(expr)

    if cls.parent?
        parent = _getFullName(cls.parent)
    else
        parent = null

    name = _getFullName(cls.variable)
    doc =
        name: name
        docstring: docstring
        parent: parent
        staticmethods: (_documentFunction(m) for m in staticmethods)
        instancemethods: (_documentFunction(m) for m in instancemethods)

    for method in doc.staticmethods
        method.name = method.name.replace(/^this/, doc.name)

    return doc

_documentFunction = (func) ->
    ###
    Evaluates a function object as returned by the coffeescript parser,
    returning an object of the form:
    
        {
            "name": "myFunc",
            "docstring": "First comment following the function definition",
            "params": ["param1", "param2"...]
        }
    ###
    # Get docstring
    first_obj = func.value.body.expressions[0]
    if first_obj?.comment
        docstring = _formatDocstring(first_obj.comment)
    else
        docstring = null

    # Get params
    if func.value.params
        params = for p in func.value.params
            if p.name.base?.value == 'this'
                param = p.name.properties[0].name.value
                if param[0] == '_'
                    param.slice(1)
                else
                    param
            else
                if p.splat then p.name.value + '...' else p.name.value

    else
        params = []

    name = _getFullName(func.variable)
    doc =
        name: name
        docstring: docstring
        params: params
    
    return doc

exports.parseModule = (moduleString) ->
  module = _documentModule(moduleString)
  return module

