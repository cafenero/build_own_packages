FROM centos:centos7

ADD make_pkg.sh /root/
WORKDIR /root/
RUN /root/make_pkg.sh ${TMUX_VERSION} ${ARCH}

ENTRYPOINT [ "/bin/sh", "-c", "while true; do /bin/sleep 1; done" ]
