class ConfigParser
  constructor: (@file_name, @fs) ->
    @config = null

  parse: (force) ->
    return @config unless @config is null or force is true

    fileContents = @fs.readFileSync(@file_name, 'utf8')
    @config = JSON.parse fileContents

exports.create = (file_name, fs) ->
  new ConfigParser(file_name, fs)

exports.parse = (file_name) ->
  fs = require "fs"
  config_parser = new ConfigParser(file_name, fs)
  config_parser.parse()
