path = require 'path'
fs = require 'fs'
yaml = require 'js-yaml'
glob = require 'glob'
emblem = require 'emblem'
Handlebars = require 'handlebars'
_ = require 'underscore'

Page = require './page.coffee'

class Site

  pages: {}
  blocks: {}
  layouts: {}
  pageInstances: []

  constructor: (@pagesMap, @blocksMap, @layoutsMap, options={}) ->
    #@noLoad = options.noLoad
    @loadLayouts()
    @loadBlocks()
    @loadPages()

  loadPages: ->
    for pagePaths in @pagesMap
      extension = path.extname pagePaths.resolved
      pageSource = fs.readFileSync pagePaths.resolved
      # define the context
      context = yaml.safeLoad pageSource
      context.filepath = pagePaths.resolved
      @pages[pagePaths.relative] = context
      @pageInstances.push new Page context, blocks: @blocks, layouts: @layouts

  processFiles: ->
    files = {}
    _.extend files, page.processFiles() for page in @pageInstances
    return files

  loadBlocks: ->
    for blockPath in @blocksMap
      extension = path.extname blockPath.relative
      blockKey = path.basename blockPath.relative, extension
      #console.log "Reading block #{blockKey} from #{blockPath.resolved}"
      @blocks[blockKey] = fs.readFileSync(blockPath.resolved)

  loadLayouts: ->
    for layoutPaths in @layoutsMap
      extension = path.extname layoutPaths.relative
      layoutKey = path.basename layoutPaths.relative, extension
      @layouts[layoutKey] = fs.readFileSync(layoutPaths.resolved)

module.exports = Site