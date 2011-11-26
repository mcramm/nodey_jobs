###
# TimeOut is used for testing. It is the only 'actor'
###
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
  @queue = {}

  constructor: (@id, @redis_client, @queue) ->

  _getTime: ->
    new Date().getTime()

  grab: ->
    self = @

    console.log( self.id + ' - looking for work!')
    @redis_client.llen self.queue.name, (err, num_pending_jobs) ->
      if num_pending_jobs > 0
        self.redis_client.lpop self.queue.name, (err, job_json) ->
          if job_json is null
            console.log(self.id, 'idling (job is null)')
            self.idle()
          else
            console.log 'grabbing a job', job_json
            self.current_job = JSON.parse job_json

            self._runJob()
      else
        console.log(self.id, 'idling (no jobs)')
        self.idle()

  idle: ->
    console.log(this.id + ' - appending self back to idle_workers')
    @queue.idle_workers.push this

  _runJob: ->
    try
      actor = eval "new " + this.current_job.actor
      this.current_job.job_start_time = this._getTime()
      actor.perform(this.current_job.params, this._succeedJob, this) if actor
    catch error
      console.log "there was an error creating the actor", error
      this._fail_job()

  _succeedJob: (self) ->
    self.current_job.status = "success"
    self._finish_job()

  _fail_job: ->
    this.current_job.status = "failed"
    this.finish_job()

  _finish_job: ->
    this.current_job.job_end_time = this._getTime()

    console.log(this.id + ' - finished job', this.current_job)

    job_json = JSON.stringify this.current_job
    this.redis_client.rpush this.queue.name + "_finished", job_json

    this.grab()

exports.create = (id, worker_client, queue) ->
  new Worker(id, worker_client, queue)
