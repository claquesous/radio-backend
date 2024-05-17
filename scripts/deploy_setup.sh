#!/bin/bash

. /home/ubuntu/.asdf/asdf.sh

bundle exec rake deploy:cleanup_releases
bundle exec rake deploy:create_new_release

