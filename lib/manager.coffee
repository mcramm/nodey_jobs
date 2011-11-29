class Manager
  constructor: (@listener, @worker_client, @new_job_ch) ->
    @queues = {}
    @current_worker_id = 0

  addQueue: (name, num_workers) ->
    queue = require("./queue.coffee").create(name, @worker_client)

    worker_count = 0
    until worker_count is num_workers
      queue.addWorker(@current_worker_id)
      worker_count += 1
      @current_worker_id += 1

    @queues[name] = queue

  start: ->
    self = this

    @listener.on "message", (channel, queue_name) ->
      return if channel isnt self.new_job_ch
      queue = self.queues[queue_name]
      queue.triggerWorker()

    @listener.subscribe @new_job_ch

exports.create = (listener, worker_client, new_job_ch) ->
  new Manager(listener, worker_client, new_job_ch)
