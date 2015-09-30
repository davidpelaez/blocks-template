emblem = require 'emblem'
Handlebars = require './handlebars.coffee'

class Section

  files: {}

  constructor: (@context, @blockSource) ->
    throw new Error "Section namespace if missing" unless @context.namespace
    @compileHTML() # compilation only to the html attr
    #@processSpecificFiles() # compiles & registers
    #@registerCommonFiles() # only registers

  compileHTML: ->
    try
      emblemSource = @blockSource
    catch error
      throw new Error "the block for namespace #{@context.namespace} wasn't found"
    @html = emblem.compile(Handlebars, emblemSource, {}) @context

  #processSpecificFiles: ->
  #  for file, source of @block.specific
  #    filename = "#{@context.namespace}-#{file}" # e.g. header-2-specific.sass
  #    console.log "specific:", filename
  #    try
  #      output = Handlebars.compile(source) @context
  #    catch error
  #      console.error "ERROR: Compilation of #{file} failed in the context of #{@context.namespace}"
  #      throw error
  #    #console.log "---", output
  #    @files[filename] = output
  #
  #registerCommonFiles: ->
  #  for file,source of @block.common
  #    filename = "#{@context.namespace}-#{file}"
  #    @files[filename] = source

module.exports = Section