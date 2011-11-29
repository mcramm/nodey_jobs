class Queue
  constructor: (@name, @worker_client) ->
    @idle_workers = []

  add_worker: (id) ->
    worker = require("./worker.coffee").create(id, @worker_client, this)
    worker.grab()

  trigger_worker: ->
    return if @idle_workers.length is 0
    worker = @idle_workers.pop()
    worker.grab()

exports.create = (name, worker_client) ->
  new Queue(name, worker_client)
