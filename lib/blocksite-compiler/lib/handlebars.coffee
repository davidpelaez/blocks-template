Handlebars = require 'handlebars'

Handlebars.registerHelper "debug", (optionalValue) ->
  return JSON.stringify this

module.exports = Handlebars