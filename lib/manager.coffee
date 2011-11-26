q = require "./queue.coffee"

class Manager
  constructor: (@listener, @new_job_ch) ->
    @queues = {}
    @current_worker_id = 0

  add_queue: (name, num_workers) ->
    queue = q.create(name)

    worker_count = 0
    until worker_count is num_workers
      queue.add_worker(@current_worker_id)
      worker_count += 1
      @current_worker_id += 1

    @queues[name] = queue
    console.log(@queues)

  start: ->
    self = @
    @listener.on "message", (channel, queue_name) ->
      return if channel isnt self.new_job_ch
      queue = self.queues[queue_name]
      queue.trigger_worker()

    @listener.subscribe self.new_job_ch

exports.create = (listener, new_job_ch) ->
  new Manager(listener, new_job_ch)
