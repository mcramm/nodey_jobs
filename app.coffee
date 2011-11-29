fs = require 'fs'
redis = require "redis"

fileContents = fs.readFileSync('./config.json','utf8')
config = JSON.parse fileContents

process.env.redis_host = config.redis.host
process.env.redis_port = config.redis.port

listener = redis.createClient(process.env.redis_port, process.env.redis_host)
worker_client = redis.createClient process.env.redis_port, process.env.redis_host

manager = require("./lib/manager.coffee").create(listener, worker_client, config.new_job_channel)

for queue in config.queues
  manager.addQueue(queue.name, queue.workers)

manager.start()

enqueuer_client = redis.createClient(process.env.redis_port, process.env.redis_host)
enqueuer = require("./lib/enqueuer.coffee").create(config.web_server.port, config.new_job_channel, enqueuer_client)
enqueuer.start()
