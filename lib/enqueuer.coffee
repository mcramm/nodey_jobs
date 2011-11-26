redis = require "redis"
client = redis.createClient process.env.redis_port, process.env.redis_host

express = require "express"
app = express.createServer()

job = {
  actor: "TimeOut",
  params: { time: 1000 },
  queued_time: null,
  job_start_time: null,
  job_end_time: null,
  status: "waiting"
}

class Enqueuer

  constructor: (@port, @new_job_ch) ->
    @app = express.createServer()

  start: ->
    self = @
    @app.get "/", (req, res) ->
      res.send "job added to queue"
      job.queued_time = new Date().getTime()
      console.log(JSON.stringify(job))
      client.rpush "jobs", JSON.stringify job
      console.log('pinging ' + self.new_job_ch)
      client.publish self.new_job_ch, "jobs"

    @app.listen(@port)

exports.create  = (port, new_job_ch) ->
  new Enqueuer(port, new_job_ch)
