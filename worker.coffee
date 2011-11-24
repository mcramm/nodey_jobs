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
  self = this

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

  grabNext: (self) ->
    self.current_job.job_end_time = self._getTime()
    console.log(self.id + ' - finished job', self.current_job)

    self.grab()

  grab: ->
    self = @

    console.log( self.id + ' - looking for work!')
    @redis_client.llen self.queue, (err, num_pending_jobs) ->
      if num_pending_jobs > 0
        self.redis_client.lpop self.queue, (err, job_json) ->
          console.log 'grabbing a job', job_json
          self.current_job = JSON.parse job_json

          self.runJob()
      else
        console.log(self.id + ' - appending self back to idle_workers')
        idle_workers.push self


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
