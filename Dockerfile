FROM jangrewe/gitlab-ci-android

ENV TOOL_VER_RUBY="2.5.1"
# install Ruby from source
#  from source: mainly because of GEM native extensions,
#  this is the most reliable way to use Ruby on Ubuntu if GEM native extensions are required
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && apt-get -y install \
    build-essential \
    wget \
    zlib1g-dev \
    libssl-dev \
    libreadline6-dev \
    libyaml-dev \
    libsqlite3-dev \
    && mkdir -p /tmp/ruby-inst \
    && cd /tmp/ruby-inst \
    && wget -q http://cache.ruby-lang.org/pub/ruby/ruby-${TOOL_VER_RUBY}.tar.gz \
    && tar -xvzf ruby-${TOOL_VER_RUBY}.tar.gz \
    && cd ruby-${TOOL_VER_RUBY} \
    && ./configure --prefix=/usr/local && make && make install \
    # cleanup
    && cd / \
    && rm -rf /tmp/ruby-inst \
    && gem update --system --no-document
RUN [ -x "$(command -v bundle)" ] || gem install bundler --no-document

RUN gem install fastlane --no-document \
 && fastlane --version
