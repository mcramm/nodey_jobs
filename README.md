Simple node queing/worker app

* Make sure redis is running
* cd into app and do `npm install`
* Start the app with `coffee app.coffee`

Hit `http://localhost:3000` in your browser and watch the output


# Todo: Usage

1. Build your configuration file as in config.json:

```json
    {
        web_server: {
            port: 3000
        },
        queues: [
          {name: "queue_one", workers: 3},
          {name: "queue_two", workers: 2},
          {name: "queue_three", workers: 1}
        ],
        new_job_channel: "new jobs",
        redis: {
            host: "localhost",
            port: 6379
        }
    }
```
# Todo: Web interface
* Show queues
* Show workers on queues
* Show jobs (finished,successful)
* Show completion time of jobs


# Queues

* Every queue has a number of workers associated with it.

# Jobs

* When is a job is finished it gets pushed onto a redis list named
  *queue_name*_finished
