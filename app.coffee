redis = require "redis"
worker = redis.createClient()
listener = redis.createClient()
adder = redis.createClient()
worker_busy = false

express = require "express"
app = express.createServer()
port = process.env.PORT or 3000

app.get "/", (req, res) ->
  res.send "hello world"
  adder.rpush "jobs", "http://google.com"
  adder.publish "new job", "jobs"

app.listen(port)

worker.perform = (link, queue) ->
  setTimeout ->
    console.log "processed: " + link
    worker.grab queue
  , 5000

worker.grab = (queue) ->
  worker.llen queue, (err, length) ->
    if length > 0
      worker.lpop queue, (err, link) ->
        console.log 'getting job'
        worker.perform link, queue
    else
      worker_busy = false


listener.on "message", (ch, msg) ->
  if ch is "new job" and !worker_busy
    worker_busy = true
    worker.grab( msg )

listener.subscribe "new job"
console.log 'ready'
