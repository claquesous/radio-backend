# ClaqRadio Backend

A rails application for integrating with an ices server to run your own internet radio station. See [ClaqRadio](https://github.com/claquesous/radio) for details.

## Dependencies

ClaqRadio Backend is a Rails 7.1 application. It requires a ruby version of at least 2.7, but 3.1 is recommended.

The only dependency is a database. Out of the box it uses PostgreSQL, but you should be able to use a different database adapter by specifying a different one in your `Gemfile`.

## Installation

* Clone this repo.
* Change into the new directory.
* Run `bundle install`.

### Database initialization

It is _highly_ recommended that you create both a development and production database.

* `RAILS_ENV=development ./bin/rake db:create`
* `RAILS_ENV=development ./bin/rake db:schema:load`

### Database seeding

A rake task is provided to scan a directory for mp3 files to add to the database. The task reads from an environment variable named `INGEST_DIRECTORY`. It supports two different formats for ingesting files.

1. all.m3u

This is a file with one line per song in the format `$root/$artist/$album/$track $title.mp3`. The information will be inferred based on the directory structure.

2. Promo directory

All files in this directory should have the format `$root/Promo/$title/$title.mp3`. Information will be read out of the metadata in the file.

It is again recommended that you run the script in development first so you don't insert malformed data into your production database.

```
RAILS_ENV=development rake radio:ingest
```

# Running the app

This is a rails app so you should deploy and run it however you typically do. An example command for running in production could be the following:

```
RAILS_ENV=production bundle exec rails s -p 3000 -b 0.0.0.0 -d
```

