Ext.data.JsonP.jsduckify({"tagname":"class","name":"jsduckify","extends":null,"mixins":[],"alternateClassNames":[],"aliases":{},"singleton":false,"requires":[],"uses":[],"enum":null,"override":null,"inheritable":null,"inheritdoc":null,"meta":{},"private":null,"id":"class-jsduckify","members":{"cfg":[],"property":[],"method":[{"name":"buildMainFile","tagname":"method","owner":"jsduckify","meta":{},"id":"method-buildMainFile"},{"name":"documentExportsAPI","tagname":"method","owner":"jsduckify","meta":{},"id":"method-documentExportsAPI"},{"name":"duckifyFile","tagname":"method","owner":"jsduckify","meta":{},"id":"method-duckifyFile"},{"name":"duckifyFiles","tagname":"method","owner":"jsduckify","meta":{},"id":"method-duckifyFiles"}],"event":[],"css_var":[],"css_mixin":[]},"linenr":3,"files":[{"filename":"index.coffee.js","href":"index.coffee.html#jsduckify"}],"html_meta":{},"statics":{"cfg":[],"property":[],"method":[],"event":[],"css_var":[],"css_mixin":[]},"component":false,"superclasses":[],"subclasses":[],"mixedInto":[],"parentMixins":[],"html":"<div><pre class=\"hierarchy\"><h4>Files</h4><div class='dependency'><a href='source/index.coffee.html#jsduckify' target='_blank'>index.coffee.js</a></div></pre><div class='doc-contents'>\n</div><div class='members'><div class='members-section'><div class='definedBy'>Defined By</div><h3 class='members-title icon-method'>Methods</h3><div class='subsection'><div id='method-buildMainFile' class='member first-child not-inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><span class='defined-in' rel='jsduckify'>jsduckify</span><br/><a href='source/buildMainFile.coffee.html#jsduckify-method-buildMainFile' target='_blank' class='view-source'>view source</a></div><a href='#!/api/jsduckify-method-buildMainFile' class='name expandable'>buildMainFile</a>( <span class='pre'>filename, readmeString, mainSourceString, exportsAPI, prefix</span> ) : String</div><div class='description'><div class='short'> ...</div><div class='long'>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>filename</span> : String<div class='sub-desc'>\n</div></li><li><span class='pre'>readmeString</span> : String<div class='sub-desc'>\n</div></li><li><span class='pre'>mainSourceString</span> : String<div class='sub-desc'><p>CoffeeScript source</p>\n</div></li><li><span class='pre'>exportsAPI</span> : Array<div class='sub-desc'><p>each row contains {baseName, fullName, type}</p>\n</div></li><li><span class='pre'>prefix</span> : String<div class='sub-desc'><p>the root for this documentation</p>\n</div></li></ul><h3 class='pa'>Returns</h3><ul><li><span class='pre'>String</span><div class='sub-desc'><p>duckifiedMainFile</p>\n</div></li></ul></div></div></div><div id='method-documentExportsAPI' class='member  not-inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><span class='defined-in' rel='jsduckify'>jsduckify</span><br/><a href='source/documentExportsAPI.coffee.html#jsduckify-method-documentExportsAPI' target='_blank' class='view-source'>view source</a></div><a href='#!/api/jsduckify-method-documentExportsAPI' class='name expandable'>documentExportsAPI</a>( <span class='pre'>moduleDirectory</span> ) : Array</div><div class='description'><div class='short'> ...</div><div class='long'>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>moduleDirectory</span> : String<div class='sub-desc'>\n</div></li></ul><h3 class='pa'>Returns</h3><ul><li><span class='pre'>Array</span><div class='sub-desc'><p>{baseName, fullName, type}</p>\n\n<p>This function will <code>require</code> the CoffeeScript directory under the assumption that it's a package.\nThat will reveal the published API (tree) of namespaces, classes, properties, functions, etc.\nThis function crawls that tree extracting the namespace structure for the package's API. This is\nlater used to make sure the jsduck documentation indicates the same namespace tree.</p>\n</div></li></ul></div></div></div><div id='method-duckifyFile' class='member  not-inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><span class='defined-in' rel='jsduckify'>jsduckify</span><br/><a href='source/duckifyFile.coffee.html#jsduckify-method-duckifyFile' target='_blank' class='view-source'>view source</a></div><a href='#!/api/jsduckify-method-duckifyFile' class='name expandable'>duckifyFile</a>( <span class='pre'>sourceFileString, exportsAPI, [prefix]</span> ) : String</div><div class='description'><div class='short'>Once it's used, it's marked as such in the exportsAPI ...</div><div class='long'><p>Once it's used, it's marked as such in the exportsAPI</p>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>sourceFileString</span> : String<div class='sub-desc'><p>CoffeeScript source</p>\n</div></li><li><span class='pre'>exportsAPI</span> : Array<div class='sub-desc'><p>each row contains {baseName, fullName, type}</p>\n</div></li><li><span class='pre'>prefix</span> : String (optional)<div class='sub-desc'><p>the root for this documentation</p>\n</div></li></ul><h3 class='pa'>Returns</h3><ul><li><span class='pre'>String</span><div class='sub-desc'><p>duckified source file</p>\n</div></li></ul></div></div></div><div id='method-duckifyFiles' class='member  not-inherited'><a href='#' class='side expandable'><span>&nbsp;</span></a><div class='title'><div class='meta'><span class='defined-in' rel='jsduckify'>jsduckify</span><br/><a href='source/duckifyFiles.coffee.html#jsduckify-method-duckifyFiles' target='_blank' class='view-source'>view source</a></div><a href='#!/api/jsduckify-method-duckifyFiles' class='name expandable'>duckifyFiles</a>( <span class='pre'>sourceFileMap, prefix, exportsAPIMap</span> ) : Object</div><div class='description'><div class='short'> ...</div><div class='long'>\n<h3 class=\"pa\">Parameters</h3><ul><li><span class='pre'>sourceFileMap</span> : Object<div class='sub-desc'><p>key: filename, value: file as string</p>\n</div></li><li><span class='pre'>prefix</span> : String<div class='sub-desc'><p>The root for this documentation</p>\n</div></li><li><span class='pre'>exportsAPIMap</span> : Object<div class='sub-desc'><p>key: function/property identifier, value: full tree for this element</p>\n</div></li></ul><h3 class='pa'>Returns</h3><ul><li><span class='pre'>Object</span><div class='sub-desc'><p>key: filename (same as sourceFileMap), value: duckified source file as a String</p>\n</div></li></ul></div></div></div></div></div></div></div>"});