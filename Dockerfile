FROM fedora:latest

# install base dependencies
RUN dnf -y group install "Development Tools" && \
    dnf install -y java-17-openjdk-devel && \
    dnf -y clean all

# set up leiningen
ENV LEIN_ROOT="true"
ADD 'https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein' \
  /usr/local/bin/lein
RUN chmod a+x /usr/local/bin/lein
RUN lein

# set default commands
ENTRYPOINT ["/usr/bin/java"]
CMD ["-jar", "/src/target/out-standalone.jar"]
# set JAVA_HOME because Fedora won't do it
ENV JAVA_HOME="/usr/lib/jvm/java"

# create working directory
RUN mkdir -p /src
WORKDIR /src

# add the project src
ADD . /src

# compile!
RUN make
