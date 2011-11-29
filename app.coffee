fs = require 'fs'

fileContents = fs.readFileSync('./config.json','utf8')
config = JSON.parse fileContents

process.env.redis_host = config.redis.host
process.env.redis_port = config.redis.port

redis = require "redis"
listener = redis.createClient(process.env.redis_port, process.env.redis_host)
worker_client = redis.createClient process.env.redis_port, process.env.redis_host

manager = require("./lib/manager.coffee").create(listener, worker_client, config.new_job_channel)

for queue in config.queues
  manager.addQueue(queue.name, queue.workers)

manager.start()

enqueuer = require("./lib/enqueuer.coffee").create(config.web_server.port, config.new_job_channel)
enqueuer.start()
