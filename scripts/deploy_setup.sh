#!/bin/bash

/home/ubuntu/.asdf/bin/asdf exec bundle exec rake deploy:cleanup_releases
/home/ubuntu/.asdf/bin/asdf exec bundle exec rake deploy:create_new_release

