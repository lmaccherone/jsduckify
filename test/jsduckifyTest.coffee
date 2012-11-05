jsduckify = require('../')

exports.jsduckifyTest =

  testMain: (test) ->
    source = '''
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
    '''
    
    expected = '''
      /**
       * Docstring inside Class
       */
      Ext.define("MyClass", {
          statics: {
              /**
               * Docstring in staticMethod
               */
              staticMethod: function(notPrivateParameter){},
      
              /**
               * Docstring in staticMethod
               */
              secondStaticMethod: function(param1, param2){}
          },
      
          /**
           * Docstring in constructor
           */
          constructor: function(c){},
      
          /**
           * Docstring in someMethod
           * Second line
           */
          someMethod: function(){}
      });
      
      
      /**
       *
       */
      Ext.define("ExtensionClass", {
          extend: "MyClass",
      
          /**
           *
           */
          constructor: function(){}
      });
      
      /**
       * Docstring at top
       * Second line
       */
      Ext.define("", {
          /**Comment in a bad spot
           * Docstring for helperFunction
           * Second line
           * 
           * line after blank line
           * 
           *     indented line
           *     another indented line
           *     
           * after indent
           */
          helperFunction: function(y){}
      });
      
      
    '''
    
    duckified = jsduckify.outputSources(source)
    test.equal(duckified, expected)
    
    test.done()