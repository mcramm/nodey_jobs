redis = require "redis"
listener = redis.createClient()

manager = require("./lib/manager.coffee").create(listener)
manager.add_queue('jobs', 3)

manager.start()

enqueuer = require("./lib/enqueuer.coffee").create()
enqueuer.start()
