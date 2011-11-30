redis = require "redis"
fs = require "fs"

config_parser = require("./lib/configParser.coffee").create(fs, "./config.json")
config = config_parser.parse()

process.env.redis_host = config.redis.host
process.env.redis_port = config.redis.port

new_redis_connection = ->
  redis.createClient(process.env.redis_port, process.env.redis_host)

listener = new_redis_connection()
worker_client = new_redis_connection()
enqueuer_client = new_redis_connection()

manager = require("./lib/manager.coffee").create(listener, worker_client, config.new_job_channel)

for queue in config.queues
  manager.addQueue(queue.name, queue.workers)

manager.start()

enqueuer = require("./lib/enqueuer.coffee").create(config.web_server.port, config.new_job_channel, enqueuer_client)
enqueuer.start()
