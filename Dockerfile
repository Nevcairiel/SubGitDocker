FROM debian:12

ENV UID=1003
ENV GID=1003
ENV SUBGIT_VERSION=3.3.17
ENV TINI_VERSION=v0.19.0
ENV DEBIAN_FRONTEND=noninteractive

RUN groupadd -g $GID subgit && useradd -d /subgit -u $UID -g $GID -m subgit

# install dependencies
RUN \
    apt-get update && \
    apt-get -y --no-install-recommends install wget default-jre git subversion && \
    rm -rf /var/lib/apt/lists*

# install subgit
RUN \
    wget -O /tmp/subgit.deb -q https://subgit.com/files/subgit_${SUBGIT_VERSION}_all.deb && \
    dpkg -i /tmp/subgit.deb && rm -rf /tmp/subgit.deb

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

VOLUME /subgit
WORKDIR /subgit

USER subgit
ADD sync.sh /
ADD entrypoint.sh /
ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]
