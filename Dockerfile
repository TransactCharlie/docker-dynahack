FROM alpine:latest AS build

RUN apk update
RUN apk add flex bison
RUN apk add gcc
RUN apk add libc-dev
RUN apk add linux-headers
RUN apk add cmake make
RUN apk add ncurses-dev
RUN apk add zlib-dev

# Hack /usr/include so that dynahack can find ncurses (sigh...)
RUN mkdir /usr/include/ncursesw
RUN ln -s /usr/include/curses.h /usr/include/ncursesw/curses.h

# Get dynahack
RUN wget https://github.com/tung/DynaHack/archive/v0.6.0.tar.gz
RUN tar -xvf v0.6.0.tar.gz
RUN mkdir /DynaHack-0.6.0/build
WORKDIR /DynaHack-0.6.0/build

# Make it
RUN cmake .. -DINSTALL_BASE=/ -DALL_STATIC:BOOL=TRUE
RUN make
RUN make install

# Final Container
FROM alpine:latest
MAINTAINER TransactCharlie
ARG VCS_REF
ARG BUILD_DATE

LABEL org.label-schema.name="DynaHack" \
      org.label-schema.description="DynaHack for Docker on Alpine Linux" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.url="https://nethackwiki.com/wiki/DynaHack" \
      org.label-schema.version=0.6.0 \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/TransactCharlie/docker-dynahack"

RUN apk --no-cache add ncurses zlib
COPY --from=build /dynahack /dynahack
ENTRYPOINT ["/dynahack/dynahack-data/dynahack"]
