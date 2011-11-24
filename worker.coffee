redis = require "redis"
worker = redis.createClient()
listener = redis.createClient()

max_workers = 1
workers_busy = 0

class TimeOut
  perform: (params, callback, queue, job, that) ->
    self = this
    setTimeout ->
      console.log self._getString()
      callback queue, job, that
    , params.time

  _getString: () ->
    "I did something"

class Worker
  @current_job = null
  @queue = "jobs"

  constructor: (@redis_client) ->

  _getTime: ->
    new Date().getTime()

  runJob: (job, queue) ->
    try
      actor = eval "new " + job.actor
    catch error
      console.log "there was an error creating the actor", error

    job.job_start_time = @_getTime()
    actor.perform(job.params, this.grabNext, queue, job, this) if actor

  grabNext: (queue, job, that) ->
    job.job_end_time = that._getTime()
    console.log('finished job', job)

    that.grab queue
  grab: (queue) ->
    that = this
    @redis_client.llen queue, (err, length) ->
      if length > 0
        that.redis_client.lpop queue, (err, job_json) ->
          console.log 'got a job', job_json
          job = JSON.parse job_json
          that.runJob job, queue
      else
        if workers_busy is 0
          console.log 'subscribing to new job channel'
          listener.subscribe "new job"
        else
          workers_busy -= 1

w = new Worker(worker)

listener.on "message", (ch, msg) ->
  if ch is "new job" and workers_busy <= max_workers
    workers_busy += 1
    w.grab "jobs"

w.grab "jobs"
console.log 'ready'
