path = require('path')
fs = require('fs')
{spawn, exec} = require('child_process')

{outputSources} = require('../')

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
  '--output, -o <output filename>  ': 'Output filename (default: <target1>.js if only one target; jsduckifyOutput.js otherwise)'
  '--base, -b <base class>         ': 'Specifies the "base class" for static functions and classes'
  '--docsoutput, -d <doc directory>': 'Specifies the directory where the Sencha jsduck output will go'
  '--noduck, -n                    ': 'Tells jsduckify not to call jsduck when done duckifying'

help = () ->
  ### Show help message and exit ###
  console.log('''
              Usage: 
                  jsduckify [options] [target directory (default .)]
                  jsduckify [options] [target1] [target2] (mix files and directories) ...
                  
              Note, when you use a single target directory, the README.md is treated as the docstring for any loose ("static")
              functions.
              
              Options:
              ''')
  for flag, description of OPTIONS
      console.log('    ' + flag + ': ' + description)
  process.exit()
  
opts = process.argv[2...process.argv.length]
if opts.length == 0 then help()

noduck = false

while opts[0]? and opts[0].substr(0, 1) == '-'
  o = opts.shift()
  switch o
    when '-h', '--help'
      help()
    when '-o', '--output'
      outputFileName = opts.shift()
    when '-b', '--base'
      prefix = opts.shift()
    when '-d', '--docoutput'
      docoutput = opts.shift()
    when '-n', '--noduck'
      noduck = true      
      
unless outputFileName?
  if opts.length == 1
    outputFileName = path.basename(path.resolve(opts[0]))
  else
    outputFileName = 'jsduckifyOutput'
     
unless prefix?
  prefix = outputFileName

unless path.extname(outputFileName) == '.js'
  outputFileName += '.js'
  
unless docoutput?
  resolvedOutputFileName = path.resolve(outputFileName)
  docoutput = path.join(path.dirname(resolvedOutputFileName), path.basename(resolvedOutputFileName, '.js')) + '_JSDuckDocs'

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

if opts.length == 1 and fs.statSync(opts[0]).isDirectory()
  fileNames = fs.readdirSync(opts[0])
  for f in fileNames
    if f.toLowerCase() == 'readme.md'
      readmePath = path.join(opts[0], f)
      break
  console.log(readmePath)
  if readmePath?
    readmeString = fs.readFileSync(readmePath, 'utf8')
    console.log(readmeString)

moduleString = outputSources(sourceFileStrings, prefix, readmeString)

if outputFileName?
  fs.writeFileSync(outputFileName, moduleString, 'utf8')
else
  process.stdout.write(moduleString + '\n');

unless noduck
  _rm(docoutput)
  options = []
  options.push('--no-source')
  options.push('-o')
  options.push(docoutput)
  options.push(outputFileName)
  _run('jsduck', options, (error, stdout, stderr) ->
    unless error?
      _rm(outputFileName)
  )
  


  
