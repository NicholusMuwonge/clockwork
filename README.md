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


## Documentation

Run this in the terminal
```bash
rswag:specs:swaggerize
```

and then Visit

`http://localhost:3000/api-docs/index.html`
