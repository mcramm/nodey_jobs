class RedisConnection
  constructor: (@redis, @config) ->

  create: ->
    @redis.createClient(@config.port, @config.host)


exports.create = (redis, config) ->
  new RedisConnection(redis, config)
