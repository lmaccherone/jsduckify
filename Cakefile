fs = require('fs')
path = require('path')
{spawn, exec} = require('child_process')
execSync = require('exec-sync')
marked = require('marked')
wrench = require('wrench')

runAsync = (command, options, next) ->
  if options? and options.length > 0
    command += ' ' + options.join(' ')
  exec(command, (error, stdout, stderr) ->
    if stderr.length > 0 and error?
      console.log("Stderr exec'ing command '#{command}'...\n" + stderr)
      console.log('exec error: ' + error)
    if next?
      next(stdout)
    else
      if stdout.length > 0 and stdout?
        console.log("Stdout exec'ing command '#{command}'...\n" + stdout)
  )

runSync = (command, options, next) ->
  if options? and options.length > 0
    command += ' ' + options.join(' ')

  {stdout, stderr} = execSync(command, true)
  if stderr.length > 0
    console.error("Error running `#{command}`\n" + stderr)
    process.exit(1)
  if next?
    next(stdout)
  else
    if stdout.length > 0
      console.log("Stdout exec'ing command '#{command}'...\n" + stdout)

# coffeedoctest does not work for this module because the examples use ### which coffeedoctest can't handle
#task('doctest', 'Runs doctests found in documentation', () ->
#  process.chdir(__dirname)
#  runSync('node_modules/coffeedoctest/bin/coffeedoctest', ['--readme', 'src', 'index.coffee'])
#)


task('docs', 'Generate docs with CoffeeDoc and place in ./docs', () ->
  process.chdir(__dirname)
  # create README.html
  readmeDotCSSString = fs.readFileSync('read-me.css', 'utf8')
  readmeDotMDString = fs.readFileSync('README.md', 'utf8')
  readmeDotHTMLString = marked(readmeDotMDString)
  readmeDotHTMLString = """
    <style>
    #{readmeDotCSSString}
    </style>
    <body>
    <div class="readme">
    #{readmeDotHTMLString}
    </div>
    </body>
  """
  fs.writeFileSync(path.join(__dirname, 'docs', 'README.html'), readmeDotHTMLString)

  # jsduckify
  {name, version} = require('./package.json')
  outputDirectory = path.join(__dirname, 'docs', "#{name}-docs")
  if fs.existsSync(outputDirectory)
    wrench.rmdirSyncRecursive(outputDirectory, false)
  runSync('bin/jsduckify', ['-d', outputDirectory, __dirname])
)

task('pub-docs', 'Push master to gh-pages on github', () ->
  pubDocsRaw()
)

pubDocsRaw = () ->
  process.chdir(__dirname)
  runAsync('git push -f origin master:gh-pages')

task('publish', 'Publish to npm', () ->
  process.chdir(__dirname)
  runSync('cake test')  # Doing this exernally to make it synchrous
  invoke('docs')
  invoke('build')
  runSync('git status --porcelain', [], (stdout) ->
    if stdout.length == 0
      {stdout, stderr} = execSync('git rev-parse origin/master', true)
      stdoutOrigin = stdout
      {stdout, stderr} = execSync('git rev-parse master', true)
      stdoutMaster = stdout
      if stdoutOrigin == stdoutMaster
        console.log('running npm publish')
        {stdout, stderr} = execSync('npm publish .', true)
        if fs.existsSync('npm-debug.log')
          console.error('`npm publish` failed. See npm-debug.log for details.')
        else
          console.log('running pubDocsRaw()')
          pubDocsRaw()
          console.log('running git tag')
          runSync("git tag v#{require('./package.json').version}")
          runAsync("git push --tags")
      else
        console.error('Origin and master out of sync. Not publishing.')
    else
      console.error('`git status --porcelain` was not clean. Not publishing.')
  )
)

task('publish', 'Publish to npm', () ->
  process.chdir(__dirname)
  runSync('cake test')  # Doing this exernally to make it synchrous
  runSync('git status --porcelain', [], (stdout) ->
    if stdout.length == 0
      {stdout, stderr} = execSync('git rev-parse origin/master', true)
      stdoutOrigin = stdout
      {stdout, stderr} = execSync('git rev-parse master', true)
      stdoutMaster = stdout
      if stdoutOrigin == stdoutMaster
        console.log('running npm publish')
        {stdout, stderr} = execSync('npm publish .', true)
        if fs.existsSync('npm-debug.log')
          console.error('`npm publish` failed. See npm-debug.log for details.')
        else
          console.log('running git tag')
          runSync("git tag v#{require('./package.json').version}")
          runAsync("git push --tags")
      else
        console.error('Origin and master out of sync. Not publishing.')
    else
      console.error('`git status --porcelain` was not clean. Not publishing.')
  )
)

task('test', 'Run the CoffeeScript test suite with nodeunit', () ->
  {reporters} = require('nodeunit')
  process.chdir(__dirname)
  reporters.default.run(['test'], undefined, (failure) ->
    if failure?
      console.log(failure)
      process.exit(1)
  )
)

#fs = require('fs')
#path = require('path')
#{spawn, exec} = require('child_process')
#execSync = require('exec-sync')
#
#
#run = (command, options, next) ->
#  if options? and options.length > 0
#    command += ' ' + options.join(' ')
#  exec(command, (error, stdout, stderr) ->
#    if stderr.length > 0 and error?
#      console.log("Stderr exec'ing command '#{command}'...\n" + stderr)
#      console.log('exec error: ' + error)
#    if next?
#      next(stdout)
#    else
#      if stdout.length > 0 and stdout?
#        console.log("Stdout exec'ing command '#{command}'...\n" + stdout)
#  )
#
#task('compile', 'Compile CoffeeScript source files to JavaScript', () ->
#  process.chdir(__dirname)
#  fs.readdir('./', (err, contents) ->
#    files = ("#{file}" for file in contents when (file.indexOf('.coffee') > 0))
#    run('coffee', ['-c'].concat(files))
#  )
#)
#
#task('doctest', 'Runs doctests found in documentation', () ->
#  process.chdir(__dirname)
#  fs.readdir('./', (err, contents) ->
#    files = ("#{file}" for file in contents when (file.indexOf('.coffee') > 0))
#    run('node_modules/coffeedoctest/bin/coffeedoctest', ['--readme'].concat(files))
#  )
#)
#
#task('publish', 'Publish to npm', () ->
#  process.chdir(__dirname)
#  run('npm publish .')
#)
#
#task('test', 'Run the CoffeeScript test suite with nodeunit', () ->
#  {reporters} = require('nodeunit')
#  process.chdir(__dirname)
#  reporters.default.run(['test'], undefined, (failure) ->
#    if failure?
#      console.log(failure)
#      process.exit(1)
#  )
#)
#
#task('testall', 'Runs both tests and doctests', () ->
#  invoke('test')
#  invoke('doctest')
#)
