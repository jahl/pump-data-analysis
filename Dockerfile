FROM ruby:3.2.2-slim as builder
RUN apt-get update && apt-get install curl gnupg build-essential libpq-dev -y
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq
RUN apt install yarn -y

RUN mkdir /app
WORKDIR /app

EXPOSE 3000

#####################################
FROM builder AS production
ENV RAILS_ENV production

COPY package.json yarn.lock /app/
RUN yarn install
COPY Gemfile* /app/
ENV BUNDLER_WITHOUT development test
RUN bundle install --jobs 20 --retry 5 --without development test
COPY . /app

# Fix missing builds assets in public/assets (Builds assets are not copied)
RUN rm -rf app/assets/builds/*
RUN RAILS_ENV=production PRECOMPILE=true SECRET_KEY_BASE=1 bundle exec rake assets:precompile
RUN rm -rf node_modules tmp/cache app/assets/builds vendor/assets spec
RUN apt-get remove yarn curl -y

#####################################
FROM builder AS development

COPY package.json yarn.lock /app/
RUN yarn install
COPY Gemfile* /app/
RUN bundle install --jobs 20 --retry 5
COPY . /app
