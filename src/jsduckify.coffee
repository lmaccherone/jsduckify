path = require('path')
fs = require('fs')
{spawn, exec} = require('child_process')

#jsduckify = require('../')
#{duckifyFiles, documentExportsAPI, buildMainFile} = jsduckify

documentExportsAPI = require('./documentExportsAPI').documentExportsAPI
duckifyFiles = require('./duckifyFiles').duckifyFiles
buildMainFile = require('./buildMainFile').buildMainFile

_run = (command, options, next) ->
  if options? and options.length > 0
    command += ' ' + options.join(' ')
  exec(command, (error, stdout, stderr) ->
    if stderr.length > 0 and error?
      console.log("Stderr exec'ing command '#{command}'...\n" + stderr)
      console.log(error)
    if next?
      next(error, stdout, stderr)
    else
      if stdout.length > 0 and stdout?
        console.log("Stdout exec'ing command '#{command}'...\n" + stdout)
  )

_emptyDirectory = (target) ->
  _rm(path.join(target, p)) for p in fs.readdirSync(target)

_rm = (target) ->
  if fs.existsSync(target)
    if fs.statSync(target).isDirectory()
      _emptyDirectory(target)
      fs.rmdirSync(target)
    else
      fs.unlinkSync(target)

# Command line options
OPTIONS =
  '--help, -h                      ': 'Displays this help'
  '--prefix, -p <prefix>           ': 'Specifies the root to prefix all documentation (default: <module_name>)'
  '--output, -o <output_directory> ': 'Output directory (default: <prefix>_jsduckify)'
  '--docsoutput, -d <doc_directory>': 'JSDuck output directory (default: <module_name>_jsduckify_JSDuckDocs)'
  '--noduck, -n                    ': 'Tells jsduckify not to call JSDuck when done duckifying'
  '--readme, -r                    ': 'Tells jsduckify to use the README.md as the docs for the main file'

help = () ->
  #Show help message and exit
  console.log('''
              Usage:
                  jsduckify [options] [module_directory (default .)]

              Options:
              ''')
  for flag, description of OPTIONS
    console.log('    ' + flag + ': ' + description)
  process.exit(1)

opts = process.argv[2...process.argv.length]
if opts.length == 0 then help()

noduck = false
searchNodeModules = false
readme = false

while opts[0]? and opts[0].substr(0, 1) == '-'
  o = opts.shift()
  switch o
    when '-h', '--help'
      help()
    when '-o', '--output'
      outputDirectory = opts.shift()
    when '-d', '--docoutput'
      docoutput = opts.shift()
    when '-p', '--prefix'
      prefix = opts.shift()
    when '-n', '--noduck'
      noduck = true
    when '-r', '--readme'
      readme = true

if opts.length == 1
  moduleDirectory = opts[0]
  unless fs.statSync(moduleDirectory).isDirectory()
    help()
else if opts.length == 0
  moduleDirectory = '.'
else
  console.error('No target directory specified.')
  help()

moduleDirectory = path.resolve(moduleDirectory)

unless prefix?
  prefix = path.basename(path.resolve(moduleDirectory))

unless outputDirectory?
  outputDirectory = prefix + '_jsduckify'

unless docoutput?
  resolvedoutputDirectory = path.resolve(outputDirectory)
  docoutput = path.join(path.dirname(resolvedoutputDirectory), path.basename(resolvedoutputDirectory, '.js')) + '_JSDuckDocs'

# Get source file paths
_getsourceFiles = (target, a) ->
  if not a?
    a = []
  if path.extname(target) == '.coffee'
    a.push(target)
  else if fs.statSync(target).isDirectory()
    if searchNodeModules or path.basename(target) != 'node_modules'
      _getsourceFiles(path.join(target, p), a) for p in fs.readdirSync(target)
  return a

sources = _getsourceFiles(moduleDirectory)

_removeBasePath = (filename, baseToRemove) ->
  unless filename.indexOf(baseToRemove) == 0 or baseToRemove in ['', './', '.']
    throw new Error("Filename #{filename} does not start with #{baseToRemove}")
  return filename.slice(baseToRemove.length)

sourceFileMap = {}
for s in sources
  key = _removeBasePath(s, moduleDirectory)
  sourceFileMap[key] = fs.readFileSync(s, 'utf8')

exportsAPI = documentExportsAPI(moduleDirectory)

# {key = fileName: value = string with .js file to be written to disk}
duckifiedFileMap = duckifyFiles(sourceFileMap, prefix, exportsAPI)

#for key, value of duckifiedFileMap
#  console.log(key, value.length)

# Get README.md
if readme
  fileNames = fs.readdirSync(moduleDirectory)
  for f in fileNames
    if f.toLowerCase() == 'readme.md'
      readmePath = path.join(moduleDirectory, f)
      break
  if readmePath?
    readmeString = fs.readFileSync(readmePath, 'utf8')
else
  readmeString = ''

mainSourceString = null
if fs.existsSync(path.join(moduleDirectory, 'package.json'))
  packageDotJSONString = fs.readFileSync(path.join(moduleDirectory, 'package.json'), 'utf8')
  packageJSON = JSON.parse(packageDotJSONString)
  if packageJSON.main?
    mainFilename = path.join(moduleDirectory, packageJSON.main)
    unless mainFilename.indexOf('.coffee') > 0
      mainFilename += '.coffee'
    if fs.existsSync(mainFilename)
      mainSourceString = fs.readFileSync(mainFilename, 'utf8')
    else
      console.error("Could not find mainfile at #{mainFilename}.")
  else
    console.log("Found package.json but no 'main' key in it.")
unless mainSourceString?
  mainFilename = path.join(moduleDirectory, 'index.coffee')
  if fs.existsSync(mainFilename)
    mainSourceString = fs.readFileSync(mainFilename, 'utf8')
  else
    console.log("Couldn't find 'index.coffee'. Creating dummy index.coffee.")
    mainFilename = path.join(moduleDirectory, 'index.coffee')
    mainSourceString = """
      # Spaceholder CoffeeScript
    """

mainFileString = buildMainFile(mainFilename, readmeString, mainSourceString, exportsAPI, prefix)

duckifiedFileMap[path.basename(mainFilename) + '.js'] = mainFileString

if outputDirectory?
  _rm(outputDirectory)

_createDirectoryTree = (directoryTreeArray, index) ->
  currentDirectoryArray = directoryTreeArray.slice(0, index + 1)
  currentDirectory = currentDirectoryArray.join(path.sep)
  unless fs.existsSync(currentDirectory)
    fs.mkdirSync(currentDirectory)
  unless index >= directoryTreeArray.length - 1 or directoryTreeArray[index + 1] == ''
    _createDirectoryTree(directoryTreeArray, index + 1)

process.chdir(moduleDirectory)

for fileName, fileContents of duckifiedFileMap
  if fileContents?
    fullFileName = path.join(outputDirectory, fileName)
    directoryTreeArray = path.join(outputDirectory, path.dirname(fileName)).split(path.sep)
    _createDirectoryTree(directoryTreeArray, 0)
    fs.writeFileSync(fullFileName, fileContents, 'utf8')

# Run jsduck

unless noduck
  _rm(docoutput)
  options = []
  options.push('-o')
  options.push("'" + docoutput + "'")
  jsduckConfigFilename = path.join(moduleDirectory, 'jsduck-config.json')
  jsduckCategoriesFilename = path.join(moduleDirectory, 'jsduck-categories.json')
  if fs.existsSync(jsduckConfigFilename)
    options.push("--config='#{jsduckConfigFilename}'")
  if fs.existsSync(jsduckCategoriesFilename)
    options.push("--categories='#{jsduckCategoriesFilename}'")

  options.push("'" + outputDirectory + "'")

  _run('jsduck', options, (error, stdout, stderr) ->
    unless error?
      _rm(outputDirectory)
    if error
      console.log('*** Error from running JSDuck...\n' + error)
    console.log('*** Stdout from running JSDuck...\n' + stdout)
    console.log('*** Stderr from running JSDuck...\n' + stderr)
  )
  