mergeTrees = require 'broccoli-merge-trees'
globSelector = require './glob-selector.coffee'
concat = require 'broccoli-concat'
replace = require('broccoli-replace')
filterCoffeeScript = require 'broccoli-coffee'

# space sass, concat, coffee and js concat
flattenSource = (tree, options)->
  # TODO fail is there's no as option passed
  id = options.as

  sassTree = replace tree,
    files: ['**/*.sass']
    patterns:[{ match: /\t/g, replacement: '  '}]

  sassTree = concat sassTree, 
    inputFiles: ['**/*.sass']
    outputFile: "/#{id}.sass"
    allowNone: true
  
  jsTree = filterCoffeeScript tree

  jsTree = concat jsTree,
    inputFiles: ['**/*.js']
    outputFile: "/#{id}.js"
    allowNone: true

  elseTree = globSelector.reject tree, files: ['**/*.sass', '**/*.coffee', '**/*.js']

  return mergeTrees [sassTree, jsTree, elseTree]

module.exports = flattenSource