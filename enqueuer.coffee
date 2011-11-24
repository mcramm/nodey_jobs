redis = require "redis"
client = redis.createClient()

express = require "express"
app = express.createServer()
port = process.env.PORT or 3000

job = {
  actor: "TheActor",
  params: { time: null }
}

app.get "/", (req, res) ->
  res.send "job added to queue"
  console.log('adding job!')
  job.params.time = new Date().getTime()
  console.log(job)
  console.log(JSON.stringify(job))
  client.rpush "jobs", JSON.stringify job
  client.publish "new job", "jobs"

app.listen(port)
