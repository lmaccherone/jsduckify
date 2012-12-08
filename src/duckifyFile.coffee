{DoublyLinkedList} = require('doubly-linked-list')

_space = (level, multiplier = 1) ->
  return new Array(level * multiplier + 1).join(' ')

_contains = (s, s2) ->
  return s.indexOf(s2) >= 0

_stripLeadingBlanks = (filename, line, count) ->
  startOfLine = line.slice(0, count)
  minLength = Math.min(startOfLine.length, count)
  unless startOfLine == _space(minLength)
    console.error("Non whitespace found within the indent space for the docstring in file: #{filename}. At line:\n" +
      "#{line}"
    )
  return line.slice(count)

_convertLinesFromCSToJS = (filename, start, end, indent) ->
  current = start
  while current != end.after
    current.value = _space(indent) + ' * ' + _stripLeadingBlanks(filename, current.value, indent)
    current = current.after

_convertDocstringFromCSToJS = (filename, docstringStart, docstringEnd) ->
  # Figure out the number of indention characters
  indent = docstringStart.value.indexOf('###')
  unless indent == docstringEnd.value.indexOf('###')
    console.error("Starting and ending docstrings do not have the same indention in file #{filename}.\n" +
      "start:\n#{docstringStart.value}\n" + "end:\n#{docstringEnd.value}"
    )
  docstringStart.insertBefore('</CoffeeScript> */')  # ends the JS comment wrapping the entire file
  docstringStart.value = _space(indent) + '/**'
  _convertLinesFromCSToJS(filename, docstringStart.after, docstringEnd, indent)
  docstringEnd.value = _space(indent) + ' */'
  docstringEnd.insertAfter('/* <CoffeeScript>')  # restarts the JS comment wrapping the entire file

_processNameAndMember = (nameLine, memberLine, exportsAPI, prefix, fullNameForCurrentClass) ->
  # !TODO: (round 2) Marks it as processed in the fileDocumentation
  a = nameLine.value.match(/@(class|method|property)\s([\$|\w]+)\b/)
  type = a[1]
  name = a[2]
  fullName = null
  for e in exportsAPI
    if name in e.fullName.split('.')
      e.processed = true
      fullName = prefix + '.' + e.fullName
      break
  space = nameLine.value.indexOf('@')
  unless fullName?
    fullName = prefix + '.' + name
    nameArray = fullName.split('.')
    baseName = nameArray[nameArray.length - 1]
    if baseName.indexOf('_') == 0
      nameLine.insertAfter(_space(space) + '@private')  # !TODO: This will add it twice if it's already there but OK.

  nameLine.value = _space(space)
  switch type
    when 'class'
      nameLine.value += "@class #{fullName}"
      fullNameForCurrentClass = fullName
    when 'method', 'property'
      nameLine.value += "@#{type} #{name}"
      unless memberLine?  # !TODO: Maybe I should manipulate the existing memberLine
        if fullNameForCurrentClass?
          member = fullNameForCurrentClass
        else
          member = prefix
        memberLine = nameLine.insertAfter(_space(space) + "@member #{member}")

  return fullNameForCurrentClass

_processDocstring = (filename, docstringStart, docstringEnd, currentClass, exportsAPI, prefix) ->
  foundSomething = false

  # Look for the @class, @method, @constructor, or @property JSDuck tags.
  current = docstringStart.after
  nameLine = null
  type = null
  memberLine = null
  while current? and current != docstringEnd
    s = current.value
    if _contains(s, "@class")
      if type?
        throw new Error("Found @class when docstring already has an @#{type} in: #{filename}.")
      else
        type = 'class'
        nameLine = current
    if _contains(s, "@method")
      if type?
        throw new Error("Found @method when docstring already has an @#{type} in: #{filename}.")
      else
        type = 'method'
        nameLine = current
    if _contains(s, "@property")
      if type?
        throw new Error("Found @property when docstring already has an @#{type} in: #{filename}.")
      else
        type = 'property'
        nameLine = current
    if _contains(s, "@constructor")
      if type?
        unless type == 'class'
          throw new Error("Cannot define an @constructor inside an @#{type} docstring in: #{filename}.")
        # We can essentially do nothing because the @constructor is already part of the @class docstring
      else
        unless currentClass.end?
          throw new Error("I have no idea where to associate this constructor.")
        type = 'constructor'
        nameLine = current
    if _contains(s, "@member")
      memberLine = current
    current = current.after

  if type == 'class'
    currentClass.start = docstringStart
    currentClass.end = docstringEnd
    fullNameForCurrentClass = _processNameAndMember(nameLine, memberLine, exportsAPI, prefix, currentClass.fullName)
    currentClass.fullName = fullNameForCurrentClass
  if type == 'constructor'
    # * Append the current docstring to the end of the currentClass
    constructorBodyStart = docstringStart.after
    constructorBodyStart.before.remove()
    docstringStart = constructorBodyStart
    constructorBodyEnd = docstringEnd.before
    constructorBodyEnd.after.remove()
    docstringEnd = constructorBodyEnd

    # Move the constructor to the bottom of the class
    indent = currentClass.end.before.value.indexOf('*') - 1
    if indent < 0
      throw new Error("Expected * to be at the top of the docstring in #{filename}")
    indentConstructor = constructorBodyStart.value.indexOf('@')
    if indentConstructor < 0
      throw new Error("Expected @constructor to be at the top of the docstring in #{filename}")
    newLine = _space(indent) + ' * '
    currentClass.end.insertBefore(newLine)  # Blank line between Class and Constructor
    current = constructorBodyStart.before
    while current != constructorBodyEnd and current?
      current = current.after
      newLine = _space(indent) + ' * ' + _stripLeadingBlanks(filename, current.value, indentConstructor)
      currentClass.end.insertBefore(newLine)
      current.before.remove()

  if type in ['property', 'method']
    _processNameAndMember(nameLine, memberLine, exportsAPI, prefix, currentClass.fullName)
    # * (round 2) Mark it as @static if it is according to fileDocumentation.
    # * (round 2) Uses fileDocumentation to specify the @membership.

  # (round 2) For each element in fileDocumentation that is not marked as processed, it tries to locate it and create
  # the appropriate JSDuck header. Note, in my old code, I was able to identify parameters.

  foundSomething = type?
  if foundSomething and type != 'constructor'
    _convertDocstringFromCSToJS(filename, docstringStart, docstringEnd)
  return foundSomething

###
@method duckifyFile
Once it's used, it's marked as such in the exportsAPI

@param {String} sourceFileString CoffeeScript source
@param {Array} exportsAPI each row contains {baseName, fullName, type}
@param {String} [prefix] the root for this documentation

@return {String} duckified source file
###
exports.duckifyFile = (filename, sourceFileString, exportsAPI, prefix = '', isMain = false) ->
  # !TODO: (round 2) Runs documentFile on it creating fileDocumentation. This runs the CoffeeScript compiler extracting classes
  # and functions. It can distinguish static methods from instance methods within your classes. It can also identify
  # functions not associated with a CoffeeScript class. However, it cannot identify any properties.
#  fileDocumentation = documentFile(sourceFileString)

  # Breaks the file down into lines.
  sourceFileString = sourceFileString.replace(/\/\*/g,'/ *')  # This is a hack but good enough
  sourceFileString = sourceFileString.replace(/\*\//g,'* /')

  lineList = new DoublyLinkedList(sourceFileString.split('\n'))

  # Turn the entire file into a big JavaScript block comment
  lineList.unshift('/* <CoffeeScript>')
  lineList.push('</CoffeeScript> */')

  # Walks through the file line-by-line looking for docstrings starting with ### and ending with ###.
  foundSomething = false
  current = lineList.head
  currentClassDocstring = {}

  while current?
    if current.value.match(/(\n|\r|^)\s*###/)?
      # !TODO: If a starting markers is not on its own line, make it so.
      docstringStart = current
      current = current.after
      while current? and !current.value.match(/(\n|\r|^)\s*###/)?
        current = current.after
      unless current?
        throw new Error("Found a docstring start without a corresponding docstring end in file: #{filename}")
      docstringEnd = current
      if isMain
        _convertDocstringFromCSToJS(filename, docstringStart, docstringEnd)
        foundSomething = true
      else if _processDocstring(filename, docstringStart, docstringEnd, currentClassDocstring, exportsAPI, prefix)
        foundSomething = true
    current = current.after

  if foundSomething
    fileString = lineList.toArray().join('\n')
  else
    fileString = null
  return fileString
