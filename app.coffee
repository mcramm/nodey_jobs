redis = require "redis"
listener = redis.createClient()

manager = require("./manager.coffee").create(listener)
manager.add_queue('jobs', 3)

manager.start()

enqueuer = require("./enqueuer.coffee").create()
enqueuer.start()
