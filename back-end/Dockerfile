FROM ruby:3.0.0

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]

RUN apt-get update && apt-get install -y nodejs

WORKDIR /app
COPY Gemfile* .
RUN bundle install

COPY . .
