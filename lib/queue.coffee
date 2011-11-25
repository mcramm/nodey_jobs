redis = require "redis"
worker_client = redis.createClient()
w = require './worker.coffee'

class Queue
  constructor: (@name='jobs') ->
    @idle_workers = []

  add_worker: (id) ->
    worker = w.create(id, worker_client, this)
    worker.grab()

  trigger_worker: ->
    return if @idle_workers.length is 0
    worker = @idle_workers.pop()
    worker.grab()

exports.create = (name) ->
  new Queue(name)
