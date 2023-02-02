FROM ubuntu:20.04
MAINTAINER Jan Grewe <jan@faked.org>

ENV VERSION_TOOLS "8512546"

ENV ANDROID_SDK_ROOT "/sdk"
# Keep alias for compatibility
ENV ANDROID_HOME "${ANDROID_SDK_ROOT}"
ENV PATH "$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update \
 && apt-get install -qqy --no-install-recommends \
      bzip2 \
      curl \
      git-core \
      html2text \
      openjdk-17-jdk \
      unzip \
      locales \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl -s https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_TOOLS}_latest.zip > /cmdline-tools.zip \
 && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
 && unzip /cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
 && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
 && rm -v /cmdline-tools.zip

RUN mkdir -p $ANDROID_SDK_ROOT/licenses/ \
 && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_SDK_ROOT/licenses/android-sdk-license \
 && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_SDK_ROOT/licenses/android-sdk-preview-license \
 && yes | sdkmanager --licenses >/dev/null

RUN mkdir -p /root/.android \
 && touch /root/.android/repositories.cfg \
 && sdkmanager --update

ADD packages.txt /sdk
RUN sdkmanager --package_file=/sdk/packages.txt

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
