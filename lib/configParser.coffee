class ConfigParser
  constructor: (@fs, @file_name) ->
    @config = null

  parse: (force) ->
    return @config unless @config is null or force is true

    fileContents = @fs.readFileSync(@file_name, 'utf8')
    @config = JSON.parse fileContents

exports.create = (fs, file_name) ->
  new ConfigParser(fs, file_name)
