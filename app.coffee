redis = require "redis"
worker = redis.createClient()
listener = redis.createClient()
adder = redis.createClient()
list_length = 0
worker_busy = false

express = require "express"
app = express.createServer()
port = process.env.PORT or 3000

app.get "/", (req, res) ->
  res.send "hello world"
  adder.rpush "jobs", "http://google.com"
  adder.publish "new job", "jobs"

app.listen(port)

worker.perform = (link) ->
  console.log "processed: " + link

worker.doStuff = (queue) ->
  worker.llen queue, (err, length) ->
    list_length = length
    console.log('initial list length: ' + list_length)

    if list_length > 0
      console.log('list length before processing ' + list_length)

      # do thing
      worker.lpop queue, (err, link) ->
        worker.perform( link )

        #get length again, if greater than 1, call do stuff

        worker.llen queue, (err, length) ->
          list_length = length
          console.log('secondary list length: ' + length)

          if list_length > 0
            worker.doStuff queue
          else
            #console.log('publishing')
            #worker.publish "no jobs", "a msg"
            #console.log('done publish')
            worker_busy = false
    else
      worker_busy = false
      #console.log('publishing')
      #worker.publish "no jobs", "a msg"
      #console.log('done publish')
      #console.log("subscribing to new job")
      #listener.subscribe "new job"


listener.on "message", (ch, msg) ->
  console.log ("GOT A MESSAGE")
  if ch is "new job" and !worker_busy
    #console.log('unsubscribing')
    #listener.unsubscribe()
    #console.log('subscribing to no jobs')
    #listener.subscribe "no jobs"

    worker_busy = true
    worker.doStuff( msg )

  #if ch is "no jobs"
    #listener.unsubscribe ch
    #console.log("subscribing to new job")
    #listener.subscribe "new job"




console.log( 'initial subscribe to new job' )
listener.subscribe "new job"
