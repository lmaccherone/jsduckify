[![build status](https://secure.travis-ci.org/lmaccherone/jsduckify.png)](http://travis-ci.org/lmaccherone/jsduckify)

# jsduckify #

Copyright (c) 2012, Lawrence S. Maccherone, Jr.

_Enables the use of Sencha's JSDuck for documenting CoffeeScript projects._

## Overview ##

You can then run jsduck on **jsduckify**'s output to generate beautiful documentation
for your CoffeeScript project.

Your CoffeeScript source is also included in the output wrapped in javascript block comments
(`/*`…`*/`) which allows users of the documentation to see your CoffeeScript when the user
of the resulting documentation clicks on "view source".

[Here](http://lmaccherone.github.com/jsduckify/docs/jsduckify-docs/index.html) is what running jsduckify looks like when run against itself.

### Features ###

* Is simply a one-to-one translation of the docstrings found in your CoffeeScript so you have almost complete control
  over the output. If you can do it in JSDuck, you can probably do it here.
* You can just type `jsduckify` in the root of your CoffeeScript module and it has reasonable
  defaults for all output. It uses the name of the name of the module (in `package.json`)for documentation output.
* Will include a README.md as the welcome page for the documentation (look at the Cakefile to see how)
* Automatically runs jsduck upon successful completion of jsduckify (unless you specify --noduck).
* Examines the public "exports" API of the module to make sure that your documentation covers the the entire API.
* May some day use the output of the CoffeeScript compiler to aide in things like @static and
  missing methods (round 2). Note, version 0.1.0 of **jsduckify** used snipits of code
  from [Omar Khan's coffedoc](https://github.com/omarkhan/coffeedoc) which took this approach
  using the CoffeeScript compiler.
    
## Credits ##

* Author: [Larry Maccherone](http://maccherone.com)

## Usage ##

```
Usage:
    jsduckify [options] [module_directory (default .)]

Options:
    --help, -h                      : Displays this help
    --prefix, -p <prefix>           : Specifies the root to prefix all documentation (default: <module_name>)
    --output, -o <output_directory> : Output directory (default: <prefix>_jsduckify)
    --docsoutput, -d <doc_directory>: JSDuck output directory (default: <module_name>_jsduckify_JSDuckDocs)
    --noduck, -n                    : Tells jsduckify not to call JSDuck when done duckifying
    --readme, -r                    : Tells jsduckify to use the README.md as the docs for the main file
```

### Programatic Usage ###

Let's require it

    {duckifyFiles, documentExportsAPI} = require('./')

Let's give it a very simple bit of CoffeeScript source code containing a properly formatted block comment header.
    
    source = """
       callSomething(anything)
    
       ###
       @class MyClass
       documentation for MyClass here
       ###
       class MyClass
    """

Let's call it and output the results.
    
    exportsAPI = documentExportsAPI('./')
    
    sourceFileMap = {'MyClass.coffee': source}
    
    duckifiedFileMap = duckifyFiles(sourceFileMap, 'myPrefix', exportsAPI)
    
    for filename, outputSource of duckifiedFileMap
      console.log("Duckified #{filename}...")
      console.log(outputSource)

    # /* <CoffeeScript>
    # callSomething(anything)
    #
    # </CoffeeScript> */
    # /**
    #  * @class myPrefix.MyClass
    #  * documentation for MyClass here
    #  */
    # /* <CoffeeScript>
    # class MyClass
    # </CoffeeScript> */

## Installation ##

`npm install jsduckify --save-dev`

The above command installs jsduckify into your current node_modules and adds it to the devDependencies section of your package.json

## Changelog ##

* 0.2.0 - 2012-12-06 - Major refactor
  * No longer uses CoffeeScript compiler
  * Reverted to simple string searching and almost one-to-one conversion from CoffeeScript 
    `###…###` docstrings to JavaScript block comments `/*…*/`
  * The advantage of this reversion is that the CoffeeScript source is now expected to be
    included in the resulting documentation
  * Also assumes that the input is a `require`-able CoffeeScript node module and uses the exports API to audit
    that you've covered all of the API
* 0.1.0 - 2012-11-03 - Original version

## MIT License ##

Copyright (c) 2012, Lawrence S. Maccherone, Jr.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.