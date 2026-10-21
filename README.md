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

If your music library is mounted via CIFS/SMB (e.g. a Windows share), set `CIFS_MUSIC_LIBRARY=1` to enable path normalization. CIFS mounts strip trailing dots from path components due to a Windows NTFS constraint, so without this, any artist/album directories ending in `.` will not be found correctly.

```
CIFS_MUSIC_LIBRARY=1 RAILS_ENV=development rake radio:ingest
```

### Song analysis for recommendations

Similar-song recommendations (`app/services/recommender.rb`) need per-song features: a sound embedding, a genre embedding, credits, release year and key/mode/BPM. These come from `radio-analyzer`, a stateless HTTP service with no database. Set `ANALYZER_URL` to point at it, and `ANALYZER_TOKEN` if it requires a bearer token. When `ANALYZER_URL` is unset, song analysis is skipped.

The backend owns all of this data. `SongAnalysis` (`app/services/song_analysis.rb`) works out which steps a song still needs (from its status columns and the model versions reported by the analyzer's `GET /versions`), sends the song's path, tags and known IDs through `AnalyzerClient`, and stores the results in `song_features`, `song_tags`, `credits` and `people`. The steps that need the whole library also run here: `CreatorEmbeddings.rebuild!` (role-weighted TF-IDF over credits) and `FacetCalibration.recalibrate!`.

The analyzer needs each song's audio. By default it gets the song's path, so it must see the library at the same path the backend stores, under its `MUSIC_ROOT`. An analyzer that can't see the library (on Lambda) gets a presigned S3 GET URL instead when `ANALYZER_AUDIO=s3`: the library is then the `AWS_S3_BUCKET` bucket mounted at `SONGS_DIRECTORY`, and each song's key is its path below that. See the `radio-analyzer` README for running it. With it running, analyze the library with:

```
rake recommendations:analyze LIMIT=50   # try a slice first
rake recommendations:analyze            # every pending song
rake recommendations:analyze RETRY=1    # also retry failures and misses
rake recommendations:analyze SONG=123   # force one song (or SONG=1,2,3)
rake recommendations:refresh            # only rebuild creator embeddings and calibrations
```

`recommendations:analyze` sends `THREADS` concurrent requests (default `ANALYZER_CONCURRENCY`, or 4) and finishes by running `recommendations:refresh`. Set `ANALYZER_CONCURRENCY=1` for an analyzer that takes one request at a time, like the Lambda deployment: it answers any more with a 429, which aborts the run.

Songs are also queued for analysis as an `AnalyzeSongJob` when they are created through `POST /api/songs` and whenever a song's MusicBrainz recording match changes. `rake radio:ingest` does not queue them, so run `recommendations:analyze` after a bulk import.

Nothing depends on the analyzer being up. If it is unreachable, times out or returns a 502/503/504, `AnalyzerClient` raises `Unavailable`, the job is discarded and the song waits for the next rake run. Until at least one song has been analyzed, the Similar tab is hidden in the playlist builder.

# Running the app

This is a rails app so you should deploy and run it however you typically do. An example command for running in production could be the following:

```
RAILS_ENV=production bundle exec rails s -p 3000 -b 0.0.0.0 -d
```

