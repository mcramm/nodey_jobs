redis = require "redis"
worker = redis.createClient()
listener = redis.createClient()

max_workers = 1
workers_busy = 0

class TimeOut
  perform: (params, callback, queue, job) ->
    self = this
    setTimeout ->
      console.log self._getString()
      callback queue, job
    , params.time

  _getString: () ->
    "I did something"

worker.getTime = ->
  new Date().getTime()

worker.perform = (job, queue) ->
  try
    actor = eval "new " + job.actor
  catch error
    console.log "there was an error creating the actor", error

  job.job_start_time = worker.getTime()
  actor.perform(job.params, worker.grabNext, queue, job) if actor

worker.grabNext = (queue, job) ->
  job.job_end_time = worker.getTime()
  console.log('finished job', job)

  worker.grab queue

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
