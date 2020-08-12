FROM ubuntu:18.04

RUN apt-get update -y && apt-get install -y software-properties-common curl
RUN apt-add-repository -y ppa:brightbox/ruby-ng

RUN apt-get update && apt-get install -y tzdata
# timezone setting
ENV TZ=Asia/Tokyo 

RUN curl -SL https://deb.nodesource.com/setup_12.x | bash
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -y && apt-get install -y \
    ruby2.7 \
    ruby2.7-dev \
    nodejs \
    postgresql-client \
    libsqlite3-dev \
    libpq-dev \
    yarn \
    libxml2-dev \
    libxslt-dev

RUN mkdir /mtg-deck-maker
WORKDIR /mtg-deck-maker

COPY Gemfile /mtg-deck-maker/Gemfile
COPY Gemfile.lock /mtg-deck-maker/Gemfile.lock

RUN gem2.7 install bundler
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install
COPY . /mtg-deck-maker

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
