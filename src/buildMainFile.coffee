duckifyFile = require('./duckifyFile').duckifyFile
{DoublyLinkedList} = require('doubly-linked-list')

###
@method buildMainFile

@param {String} filename
@param {String} readmeString
@param {String} mainSourceString CoffeeScript source
@param {Array} exportsAPI each row contains {baseName, fullName, type}
@param {String} prefix the root for this documentation

@return {String} duckifiedMainFile
###
exports.buildMainFile = (filename, readmeString, mainSourceString, exportsAPI, prefix) ->

  # Breaks the file down into lines.
  lineList = new DoublyLinkedList(mainSourceString.split('\n'))

  unless lineList.head.value.indexOf('###') == 0  # Starts with a DocString. Make it the Main.
    lineList.head.insertBefore('###')
    lineList.head.insertBefore('###')

  lineList.head.insertAfter(readmeString)
  lineList.head.insertAfter("@class #{prefix}")

  sourceFileString = lineList.toArray().join('\n')

#  sourceFileString = """
#    ###
#    @class #{prefix}
#    @extends
#    #{readmeString}
#    ###
#    #{mainSourceString}
#  """

  for e in exportsAPI
    unless e.processed?
      console.log("Couldn't find #{e.fullName} in source.")

  duckifiedMainFile = duckifyFile(filename, sourceFileString, exportsAPI, prefix = '', true)
  return duckifiedMainFile