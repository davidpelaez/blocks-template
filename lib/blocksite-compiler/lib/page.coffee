path = require 'path'
fs = require 'fs'
yaml = require 'js-yaml'
glob = require 'glob'
emblem = require 'emblem'
Handlebars = require 'handlebars'
_ = require 'underscore'
mkdirp = require 'mkdirp'

Section = require './section.coffee'

class Page

  sections: []
  files: {}

  constructor: (@context, options) ->
    @layouts = options.layouts
    @blocks = options.blocks
    @commonContext = _.omit @context, ["sections"]
    @layout = @context["layout"] or "default"

    throw new Error "#{@context.filepath} has no slug property" unless @context["slug"]
    @slug = @context["slug"]

    if @slug.match /(.html)$/
      throw new Error "#{@context.filepath} slug should be dirname not a filename"

    if @slug == "/"
      @slug = "index"
      @outputFile = "/index.html"
    else
      @outputFile = path.join @slug, "index.html"

  processSections: ->
    html = ""
    for sectionData, index in @context.sections
      sectionContext = _.extend sectionData, 
        page: @commonContext
        sectionIndex: index
        #site: @site
      blockData = @blocks[sectionContext.block]
      sectionContext.namespace = "#{@slug}-#{sectionContext.block}-#{index}".replace "/", "-"
      sectionInstance = new Section sectionContext, blockData
      @sections.push sectionInstance
      html += sectionInstance.html
    @context.yield = new Handlebars.SafeString html

  processLayout: ->
    @files[@outputFile] = emblem.compile(Handlebars, @layouts[@layout], {})(@context)

  processFiles: ->
    @processSections()
    @processLayout()
    allFiles = _.extend {}, @files
    _.extend @files, section.files for section in @sections
    return @files

module.exports = Page