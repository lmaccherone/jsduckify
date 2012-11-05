path = require('path')
fs = require('fs')
parseModule = require('./src/parseModule').parseModule
outputModule = require('./src/outputModule').outputModule
outputSources = require('./src/outputSources').outputSources

_emptyDirectory = (target) ->
  _rm(path.join(target, p)) for p in fs.readdirSync(target)

_rm = (target) ->
  if fs.statSync(target).isDirectory()
    _emptyDirectory(target)
    fs.rmdirSync(target)
  else
    fs.unlinkSync(target)
    
# Command line options
OPTIONS =
  '--help, -h                      ': 'Displays this help'
  '--output, -o <output filename>  ': 'Allows you to specify output filename (default: stdout)'
  '--base, -b <base class>         ': 'Specifies the "base class" for static functions and classes'

help = () ->
  ### Show help message and exit ###
  console.log('''
              Usage: 
                  jsduckify [options] [directory for CoffeeScript project (default .)]
                  jsduckify [options] [target1] [target2] ...
              
              Options:
              ''')
  for flag, description of OPTIONS
      console.log('    ' + flag + ': ' + description)
  process.exit()
  
opts = process.argv[2...process.argv.length]
if opts.length == 0 then help()

prefix = 'base'

while opts[0]? and opts[0].substr(0, 1) == '-'
  o = opts.shift()
  switch o
    when '-h', '--help'
      help()
    when '-o', '--output'
      outputFileName = opts.shift()
    when '-b', '--base'
      prefix = opts.shift()

# Get source file paths
_getSourceFiles = (target, a) ->
  if not a?
    a = []
  if path.extname(target) == '.coffee'
    a.push(target)
  else if fs.statSync(target).isDirectory()
    _getSourceFiles(path.join(target, p), a) for p in fs.readdirSync(target)

if opts.length < 1
  opts = ['.']
sources = []    
_getSourceFiles(o, sources) for o in opts

sourceFileStrings = (fs.readFileSync(s, 'utf8') for s in sources)

moduleString = outputSources(sourceFileStrings, prefix)

if outputFileName?
  fs.writeFileSync(outputFileName, moduleString, 'utf8')
else
  process.stdout.write(moduleString + '\n');

exports.parseModule = parseModule
exports.outputModule = outputModule
exports.outputSources = outputSources
  
###
ToDos
  Tests
  create a script to test Lumenize output with
  add README.md as docstring for module
  supress source in output (there is a JSDuck option for this)
  remove Deps
  remove unused code
  refactor names to cleanup "output" "module" "file" etc
  cleanup docs
  see if I can remove the file reference
  what happens if you have two files with the same define? for instance lumenize with readme and lumenize for static functions. Hopefully they are merged.
  exclude private methods that start with _
  coffeeLint
  indention reformat
  add parens for function calls
  see if I can key off of exports. Would call for parsing package.json and looking at main and following requires. browserify follows requires so maybe I can look at how they do it.
  Travis CI
  usage in README.md
###