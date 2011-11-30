redis = require "redis"
fs = require "fs"

config_parser = require("./lib/configParser.coffee").create(fs, "./config.json")
config = config_parser.parse()

redis_connection_manager = require("./lib/redisConnectionManager.coffee").create(redis, config.redis)

listener = redis_connection_manager.create()
worker_client = redis_connection_manager.create()
enqueuer_client = redis_connection_manager.create()

manager = require("./lib/manager.coffee").create(listener, worker_client, config.new_job_channel)

for queue in config.queues
  manager.addQueue(queue.name, queue.workers)

manager.start()

enqueuer = require("./lib/enqueuer.coffee").create(config.web_server.port, config.new_job_channel, enqueuer_client)
enqueuer.start()
