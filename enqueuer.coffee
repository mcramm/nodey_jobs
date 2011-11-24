redis = require "redis"
client = redis.createClient()

express = require "express"
app = express.createServer()
port = process.env.PORT or 3000

job = {
  actor: "TimeOut",
  params: { time: 1000 },
  queued_time: null,
  job_start_time: null,
  job_end_time: null
}

app.get "/", (req, res) ->
  res.send "job added to queue"
  console.log('adding job!')
  job.queued_time = new Date().getTime()
  console.log(job)
  console.log(JSON.stringify(job))
  client.rpush "jobs", JSON.stringify job
  client.publish "new job", "jobs"

app.listen(port)
