# patched version of broccoli-select
# https://raw.githubusercontent.com/mjackson/broccoli-select/master/index.js

fs = require("fs")
path = require("path")
mkdirp = require("mkdirp")
Writer = require("broccoli-writer")
_ = require 'underscore'
helpers = require("broccoli-kitchen-sink-helpers")
glob = require("glob")

class GlobFilter extends Writer

  constructor: (@inputTree, @options={}) ->
    #super inputTree, options
    @files = @options.files
    @verbose = @options.verbose

  writeFiles: (filesToWrite, srcDir, destDir)->
    for file in filesToWrite
      console.log "WRITING #{file}" if @verbose
      srcFile = path.join srcDir, file
      destFile = path.join destDir, file
      #stat = fs.lstatSync srcFile
      #if stat.isFile() or stat.isSymbolicLink()
      directory = path.dirname(destFile)
      #console.log "mkdir on dir #{directory}"
      mkdirp.sync directory
      helpers.copyPreserveSync srcFile, destFile

  multiGlob: (patterns, cwd)->
    matches = _.map patterns, (pattern)=> 
      result = glob.sync pattern, {cwd: cwd}
      console.log "#{pattern} matches", result if @verbose
      result
    matches = _.flatten matches
    #matches = _.map matches, ((file)=> path.join cwd, file)
    _.reject matches, ((file)=> fs.statSync(path.join(cwd,file)).isDirectory())

class Accept extends GlobFilter

  write: (readTree, destDir) ->
    readTree(@inputTree).then (srcDir) =>
      matchingFiles = @multiGlob @files, srcDir
      allFiles = @multiGlob ["**/*"], srcDir
      acceptedFiles = _.intersection allFiles, matchingFiles
      @writeFiles acceptedFiles, srcDir, destDir

class Reject extends GlobFilter

  write: (readTree, destDir) ->
    readTree(@inputTree).then (srcDir) =>
      rejectedFiles = @multiGlob @files, srcDir
      allFiles = @multiGlob ["**/*"], srcDir
      #console.log "all:", allFiles
      #console.log "reject:", rejectedFiles
      acceptedFiles = _.difference allFiles, rejectedFiles
      #console.log "accept:",acceptedFiles 
      @writeFiles acceptedFiles, srcDir, destDir

module.exports = {
  accept: (inputTree, options) ->
    new Accept inputTree, options
  reject: (inputTree, options) ->
    new Reject inputTree, options
}
