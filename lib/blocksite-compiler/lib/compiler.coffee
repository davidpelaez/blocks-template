_ = require 'underscore'
glob = require 'glob'
path = require 'path'
mkdirp = require 'mkdirp'
path = require 'path'
fs = require 'fs'

Site = require './site.coffee'
CachingWriter = require('broccoli-caching-writer')

class BlocksiteCompiler extends CachingWriter

  constructor: (@inputTrees, @options={}) ->
    unless Array.isArray(@inputTrees)
      msg = 'BlocksiteCompiler expected array for first argument - did you mean [tree]?'
      throw new Error msg
    super @inputTrees, @options
    # save options
    @pages = @options.pages or 'pages'
    @blocks = @options.blocks or 'blocks'
    @layouts = @options.layouts or 'layouts'
    @site = @options.site or 'site.yml'
    #@noLoad = @options.noLoad or ['jpg', 'png'] # TODO add other binary extensions

  findFiles: (dirs, suffix, pattern)->
    _.flatten _.map dirs, (dirPath)=>
      expandedDir = path.join dirPath, suffix
      result = glob.sync pattern, { cwd: expandedDir }
      _.map result, (foundPath)=> 
        {
          relative: foundPath
          resolved: path.join(expandedDir, foundPath)
        }

  pagesFilesIn: (dirs)->
    @findFiles dirs, @pages, '**/*.page'

  layoutFilesIn: (dirs)->
    @findFiles dirs, @layouts, '**/*.emblem'

  blockFilesIn: (dirs)->
    @findFiles dirs, @blocks, '**/*.emblem'

  updateCache: (includePaths, destDir)->
    console.log "Updating blocksite compiler cache"
    pagesFiles = @pagesFilesIn includePaths
    blockFiles = @blockFilesIn includePaths
    layoutFiles = @layoutFilesIn includePaths
    site = new Site pagesFiles, blockFiles, layoutFiles#, noLoad: @noLoad
    fileMap = site.processFiles()
    for relPath, content of fileMap
      targetPath = path.join destDir, relPath
      #console.log "  -> #{targetPath}"
      mkdirp.sync path.dirname(targetPath)
      #console.log targetPath, content
      fs.writeFileSync targetPath, content #utf8.encode(content)
      

module.exports = (inputTrees, options) ->
  new BlocksiteCompiler inputTrees, options
  