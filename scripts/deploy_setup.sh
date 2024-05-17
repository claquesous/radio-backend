#!/bin/bash

/home/ubuntu/.asdf/bin/asdf exec ./bin/rake deploy:cleanup_releases
/home/ubuntu/.asdf/bin/asdf exec ./bin/rake deploy:create_new_release

