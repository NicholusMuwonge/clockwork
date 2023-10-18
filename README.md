# clockwork

This simple project aims to generate an API that generates reports of pending issues.

The project is built in `Ruby On Rails`.


## Features

- Generate unassigned components issue count report.
- Simple Swagger Api documentation


## Run Locally

Clone the project

```bash
  git clone https://github.com/NicholusMuwonge/clockwork.git
```

Go to the project directory

```bash
  cd clockwork
```

Install dependencies

```bash
  bundle install
```

Add Project `Master.key` To be able to access the credentials, I use Rails credentials. I will share this whenever you'd like.

```bash
  bundle install
```

Start the server

```bash
  bundle exec rails s
```

## Running Tests

To run tests, run the following command

```bash
  bundle exec rspec
```

## Screenshots

None

## Considerations

- I assume everything is running on the same server, hence storing the files in the tmp file. In a real application, we are better off storing the file in an S3 bucket and store the links and use that for future file reference.
- Logging, is on assumption that it exists at levels that arent production and that it could best be handled by Errbit or Sentry in production.
- Sidekiq is used to process background jobs, its at its simplest mode, can be tweaked to handle more complex scenarios.
- I use redis to store and track the Sidekiq queues.
- Assumption is that there are more than one projects so reports are per project
- A cached file is served when there's one saved in cache. The cache can be invalidated by timeouts or if an invalidation callback is invoked for instace if there was a new lead assignment to a component so that fresh data can be generated.

## Documentation

Run this in the terminal
```bash
rswag:specs:swaggerize
```

and then Visit

`http://localhost:3000/api-docs/index.html`
