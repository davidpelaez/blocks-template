# for template compilation:
# https://github.com/thomasboyt/broccoli-baked-handlebars
# tocheck: https://github.com/sindresorhus/broccoli-uncss
# for file revisions for cache busting
# https://github.com/mjackson/broccoli-rev
#stripDebug = require('broccoli-strip-debug')
pickFiles = require 'broccoli-static-compiler'

compileSass = require 'broccoli-sass'
mergeTrees = require 'broccoli-merge-trees'
mergeTrees = require 'broccoli-merge-trees'
filterCoffeeScript = require 'broccoli-coffee'
imageMin = require 'broccoli-imagemin'
uncss = require('broccoli-uncss')
_ = require('underscore')
concat = require 'broccoli-concat'
flattenSource = require './lib/flatten-source.coffee'
compileBlockSite = require './lib/blocksite-compiler'
globSelector = require './lib/glob-selector.coffee'

replace = require 'broccoli-replace'


#csso = require('broccoli-csso')
#appCSS = csso appCSS

#uglifyJavaScript = require('broccoli-uglify-js')
#appJS = uglifyJavaScript appJS if false

## --------------------------------- ACTUAL COMPILATION

pagesFiles = compileBlockSite ['source']

sassIncludePaths = ['source/global', 'source/bower', 'source/vendor']

appCSS = compileSass sassIncludePaths, 'app.sass', '/app.css', sourceMap: true

jsSources = mergeTrees ['source/global', 'source/vendor'], overwrite: true

appJS = concat filterCoffeeScript(jsSources),
  inputFiles: ['**/*.js']
  outputFile: '/app.js'

nonAssetsExtensions = ['**/*.sass', '**/*.scss', '**/*.js', '**/*.coffee']

robots = pickFiles 'source/assets', srcDir: '/', destDir: '/', files: ["robots.txt"]

assets = pickFiles 'source/assets', srcDir: '/', destDir: '/assets', files: ["**/*.*"]
assets = globSelector.reject assets, files: nonAssetsExtensions

vendor = pickFiles 'source/vendor', srcDir: '/', destDir: '/vendor', files: ["**/*.*"]
vendor = globSelector.reject vendor, files: nonAssetsExtensions

## --------------------------------- ENV SPECIFIC CONFIG
#Change Robots.txt to disallow in staging
targetEnv = process.env.BROCCOLI_ENV || "production"

config = {
  production:
    robots: ''
  staging:
    robots: 'User-agent: * \n Disallow: /'
  development:
    robots: 'dev'
}

envPatterns = _.map config[targetEnv], (value,key)->
  { match: key, replacement: value }

finalTree = mergeTrees [appCSS, appJS, pagesFiles, assets, vendor, robots]

module.exports = replace finalTree, files: ['**/*.js', '**/*.html', '**/*.txt'], patterns: envPatterns
