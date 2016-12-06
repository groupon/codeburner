FROM ruby:2.2.3
RUN apt-get clean && apt-get update -qq && apt-get install -y --fix-missing build-essential nodejs nodejs-legacy npm default-jdk maven unzip mysql-client

RUN npm install -g retire
RUN npm install -g nsp

RUN wget -q https://github.com/find-sec-bugs/find-sec-bugs/releases/download/version-1.4.5/findsecbugs-cli-1.4.5.zip -O findsecbugs.zip
RUN unzip findsecbugs.zip -d /findsecbugs

RUN wget -q https://github.com/pmd/pmd/releases/download/pmd_releases%2F5.4.1/pmd-bin-5.4.1.zip -O pmd.zip
RUN unzip pmd.zip

WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

RUN mkdir /codeburner

ADD . /codeburner

WORKDIR /codeburner

CMD bundle exec rails s -b 0.0.0.0
