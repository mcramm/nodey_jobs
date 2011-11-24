redis = require "redis"
worker = redis.createClient()
listener = redis.createClient()

max_workers = 1
workers_busy = 0

class TheActor
  perform: (time, callback, queue) ->
    self = this
    setTimeout ->
      console.log self._getString()
      callback queue
    , 5000
  _getString: () ->
    "I did something"

worker.perform = (job, queue) ->
  try
    actor = eval "new " + job.actor
  catch error
    console.log "there was an error creating the actor", error

  actor.perform(job.params.time, worker.grab, queue) if actor

worker.grab = (queue) ->
  worker.llen queue, (err, length) ->
    if length > 0
      worker.lpop queue, (err, job) ->
        console.log 'got a job', job
        job = JSON.parse job
        worker.perform job, queue
    else
      if workers_busy is 0
        console.log 'subscribing to new job channel'
        listener.subscribe "new job"
      else
        workers_busy -= 1

listener.on "message", (ch, msg) ->
  if ch is "new job" and workers_busy <= max_workers
    workers_busy += 1
    worker.grab msg

worker.grab "jobs"
console.log 'ready'
