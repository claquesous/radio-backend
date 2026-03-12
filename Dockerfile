# ── Stage 1: Build ────────────────────────────────────────────
FROM ruby:3.4.1-slim AS build

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install gems before copying app code so this layer is cached
# unless Gemfile changes.
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

COPY . .

# Precompile bootsnap cache for faster boot times
RUN bundle exec bootsnap precompile --gemfile app/ lib/

# ── Stage 2: Runtime ───────────────────────────────────────────
FROM ruby:3.4.1-slim AS runtime

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      libpq5 \
      curl \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 rails

WORKDIR /app

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=rails:rails /app /app

USER rails

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
