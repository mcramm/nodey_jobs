redis = require "redis"
worker_client = redis.createClient()
listener = redis.createClient()

num_of_workers = 3 # used to control to number of created workers
idle_workers = []

class TimeOut
  perform: (params, callback, that) ->
    self = this
    setTimeout ->
      console.log self._getString()
      callback that
    , params.time

  _getString: () ->
    "I did something"

class Worker
  @current_job = null
  @queue = "jobs"

  constructor: (@id, @redis_client, @queue) ->

  _getTime: ->
    new Date().getTime()

  runJob: ->
    try
      actor = eval "new " + this.current_job.actor
    catch error
      console.log "there was an error creating the actor", error

    this.current_job.job_start_time = this._getTime()
    actor.perform(this.current_job.params, this.grabNext, this) if actor

  grabNext: (that) ->
    that.current_job.job_end_time = that._getTime()
    console.log(that.id + ' - finished job', that.current_job)

    that.grab()
  grab: ->
    that = this
    console.log( that.id + ' - looking for work!')
    @redis_client.llen that.queue, (err, num_pending_jobs) ->
      if num_pending_jobs > 0
        that.redis_client.lpop that.queue, (err, job_json) ->
          console.log 'grabbing a job', job_json
          that.current_job = JSON.parse job_json

          that.runJob()
      else
        console.log(that.id + ' - appending self back to idle_workers')
        idle_workers.push that


listener.on "message", (ch, msg) ->
  if idle_workers.length > 0
    worker = idle_workers.pop()
    worker.grab()

worker_id = 0
until worker_id is num_of_workers
  idle_workers.push new Worker(worker_id, worker_client, "jobs")
  console.log( 'worker ' + worker_id + ' added')
  worker_id += 1

idle_workers.pop().grab()

console.log 'subscribing to new job channel'
listener.subscribe "new job"

console.log 'ready'
