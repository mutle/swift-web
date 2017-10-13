FROM swift:4.0
MAINTAINER Mutwin Kraus <mutwin.kraus@gmail.com>

ENV APP=/web
RUN mkdir -p /$APP/bin
WORKDIR /$APP
ADD .build ./.build
ADD script ./script
ADD Fixtures ./Fixtures
ADD Sources ./Sources
ADD Tests ./Tests
ADD Package.swift .
ADD Package.resolved .
RUN cd /$APP && script/compile
CMD script/test
