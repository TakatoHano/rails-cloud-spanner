FROM ruby:3.1

RUN mkdir /web_app
WORKDIR /web_app
COPY Gemfile /web_app/Gemfile
COPY Gemfile.lock /web_app/Gemfile.lock
RUN bundle install
COPY . /web_app

ARG ENVIRON="development"
ARG MASTER_KEY=""
ENV RAILS_ENV=${ENVIRON}
ENV RAILS_MASTER_KEY=${MASTER_KEY}

ENV RAILS_SERVE_STATIC_FILES=true
RUN bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
