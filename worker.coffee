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
    @redis_client.llen self.queue.name, (err, num_pending_jobs) ->
      if num_pending_jobs > 0
        self.redis_client.lpop self.queue.name, (err, job_json) ->
          if job_json is null
            console.log(self.id, 'idling (job is null)')
            self.idle()
          else
            console.log 'grabbing a job', job_json
            self.current_job = JSON.parse job_json

            self.runJob()
      else
        console.log(self.id, 'idling (no jobs)')
        self.idle()

  idle: ->
    console.log(this.id + ' - appending self back to idle_workers')
    @queue.idle_workers.push this

exports.create = (id, worker_client, queue) ->
  new Worker(id, worker_client, queue)
