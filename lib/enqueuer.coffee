job = {
  actor: "TimeOut",
  params: { time: 1000 },
  queued_time: null,
  job_start_time: null,
  job_end_time: null,
  status: "waiting"
}

class Enqueuer

  constructor: (@port, @new_job_ch, @redis_client) ->
    @app = require("express").createServer()

  start: ->
    self = this

    @app.get "/", (req, res) ->
      res.send "job added to queue"
      job.queued_time = new Date().getTime()
      self.redis_client.rpush "jobs", JSON.stringify job
      self.redis_client.publish self.new_job_ch, "jobs"

    @app.listen(@port)

exports.create  = (port, new_job_ch, redis_client) ->
  new Enqueuer(port, new_job_ch, redis_client)
