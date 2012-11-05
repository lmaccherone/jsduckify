{jsduckify} = require('../')

exports.jsduckifyTest =

  testMain: (test) ->
    source = """
    ###
    Docstring at top
    Second line
    ###
    class MyClass
      ###
      Docstring inside Class
      ###
      
      constructor: (@_c) ->
        ###
        Docstring in constructor
        ###
        x = x + 1
      
      someMethod: () ->
        ###
        Docstring in someMethod
        Second line
        ###
      
      @staticMethod: (@notPrivateParameter) ->
        ###
        Docstring in staticMethod
        ###
        x = z + y
        
      @secondStaticMethod: (param1, param2) ->
        ###
        Docstring in staticMethod
        ###
        x = z + yes

    class ExtensionClass extends MyClass
      # No Docstring but plain comment
      
      constructor: () ->
        x = x
      

    helperFunction = (y) ->
      ###Comment in a bad spot
      Docstring for helperFunction
      Second line
      
      line after blank line
      
          indented line
          another indented line
          
      after indent
      ###
      y = y + 2
    """
    
    jsduckify(source)
    
    test.done()