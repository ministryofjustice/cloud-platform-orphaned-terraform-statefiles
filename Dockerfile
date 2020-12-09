FROM ruby:2.7-alpine

RUN apk --update add --virtual build_deps \
    build-base ruby-dev libc-dev linux-headers \
    curl

RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle config set without 'development'
RUN bundle install

COPY bin ./bin
COPY lib ./lib

RUN chown 1000:1000 /app
USER 1000

CMD ["/bin/sh", "./bin/post-data.sh"]
