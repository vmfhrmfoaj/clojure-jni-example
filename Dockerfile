FROM ubuntu:22.04

ENV LEIN_ROOT="true"

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN apt -y update && apt -y upgrade && \
    apt -y install build-essential sudo vim bash-completion wget && \
    apt -y install openjdk-17-jdk-headless && \
    apt -y install gcc-arm-linux-gnueabi binutils-arm-linux-gnueabi && \
    apt -y install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu && \
    apt -y autoremove && \
    apt -y clean
RUN groupadd -g ${GROUP_ID} user && \
    useradd -m -u ${USER_ID} -g ${GROUP_ID} user && \
    echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user && \
    chmod 440 /etc/sudoers.d/user && \
    chsh -s /bin/bash user

ADD 'https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein' /usr/local/bin/lein
RUN chmod a+rx /usr/local/bin/lein && \
    su - user /usr/local/bin/lein

USER user
WORKDIR /workspace
CMD [ "bash" ]
