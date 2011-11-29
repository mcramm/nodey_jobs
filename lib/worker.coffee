###
# TimeOut is used for testing. It is the only 'actor'
###
class TimeOut
  perform: (params, callback, that) ->
    self = this
    setTimeout ->
      callback that
    , params.time

  _getString: () ->
    "I did something"

class Worker
  @current_job = null
  @queue = {}

  constructor: (@id, @redis_client, @queue) ->

  _getTime: ->
    new Date().getTime()

  grab: ->
    self = this

    @redis_client.llen self.queue.name, (err, num_pending_jobs) ->
      if num_pending_jobs > 0
        self._popJob()
      else
        self.idle()

  idle: ->
    @queue.idle_workers.push this

  _popJob: ->
    self = this

    this.redis_client.lpop this.queue.name, (err, job_json) ->
      if job_json is null
        self.idle()
      else
        self.current_job = JSON.parse job_json

        self._runJob()

  _runJob: ->
    try
      actor = eval "new " + this.current_job.actor
      this.current_job.job_start_time = this._getTime()
      actor.perform(this.current_job.params, this._succeedJob, this) if actor
    catch error
      console.log "there was an error creating the actor", error
      this._failJob()

  _succeedJob: (self) ->
    self.current_job.status = "success"
    self._finishJob()

  _failJob: ->
    this.current_job.status = "failed"
    this._finishJob()

  _finishJob: ->
    this.current_job.job_end_time = this._getTime()
    this.redis_client.rpush this.queue.name + "_finished", this._getCurrentJobJson()
    this.grab()

  _getCurrentJobJson: ->
    JSON.stringify this.current_job

exports.create = (id, redis_client, queue) ->
  new Worker(id, redis_client, queue)
