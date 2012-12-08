{duckifyFiles, documentExportsAPI} = require('../')

trim = (val) ->
  return if String::trim? then val.trim() else val.replace(/^\s+|\s+$/g, "")

trimLines = (s) ->
  return (trim(row) for row in s.split('\n')).join('\n')

exports.jsduckifyTest =

  testMain: (test) ->
    source = '''###
      @class MyClass
      documentation for this class
      ##''' + '''#
      class MyClass

      ##''' + '''#
      @constructor
      @param {Number} _c
      ##''' + '''#
      constructor: (@_c) ->
        x = x + 1

      ##''' + '''#
      @method someMethod
      @param {String} name
      @return {String}
      @chainable
      This method says hello
      ##''' + '''#
      someMethod: (name) ->
        console.log("hello #{name}")
        return this

      ##''' + '''#
      @method staticMethod
      @static
      @param {Number} z docs for parameter z
      @param {Number} y docs for parameter y
      @return {Number}
      This method does math
      ##''' + '''#
      @staticMethod: (z, y) ->
        x = z + y
        return x

      ##''' + '''#
      @class ExtensionClass
      @extends MyClass
      documentation for this class
      ##''' + '''#
      class ExtensionClass extends MyClass

      ##''' + '''#
      @method helperFunction
      @param {Number} y docs for parameter y
      @return {Number}
      docs for helperFunction
      ##''' + '''#
      helperFunction = (y) ->
        y = y + 2
    '''

    expected = '''
      /* <CoffeeScript>
      </CoffeeScript> */
      /**
       * @class myPrefix.MyClass
       * documentation for this class
       *
       * @constructor
       * @param {Number} _c
       */
      /* <CoffeeScript>
      class MyClass
        @param {Number} _c
        constructor: (@_c) ->
          x = x + 1

      </CoffeeScript> */
        /**
         * @method someMethod
         * @member myPrefix.MyClass
         * @param {String} name
         * @return {String}
         * @chainable
         * This method says hello
         */
      /* <CoffeeScript>
        someMethod: (name) ->
          console.log("hello #{name}")
          return this

      </CoffeeScript> */
        /**
         * @method staticMethod
         * @member myPrefix.MyClass
         * @static
         * @param {Number} z docs for parameter z
         * @param {Number} y docs for parameter y
         * @return {Number}
         * This method does math
         */
      /* <CoffeeScript>
        @staticMethod: (z, y) ->
          x = z + y
          return x

      </CoffeeScript> */
      /**
       * @class myPrefix.ExtensionClass
       * @extends MyClass
       * documentation for this class
       */
      /* <CoffeeScript>
      class ExtensionClass extends MyClass

      </CoffeeScript> */
      /**
       * @method helperFunction
       * @member myPrefix.ExtensionClass
       * @param {Number} y docs for parameter y
       * @return {Number}
       * docs for helperFunction
       */
      /* <CoffeeScript>
      helperFunction = (y) ->
        y = y + 2
      </CoffeeScript> */
    '''

    exportsAPI = documentExportsAPI('../')

    sourceFileMap = {'testfile.coffee': source}

    duckifiedFileMap = duckifyFiles(sourceFileMap, 'myPrefix', exportsAPI)

    duckified = trimLines(duckifiedFileMap['testfile.coffee.js'])
    expected = trimLines(expected)

    test.equal(duckified, expected)

    test.done()