FROM rockylinux:9

ARG EMACS_VERSION
ARG ARCH

ADD make_pkg.sh /root/
WORKDIR /root/
RUN /root/make_pkg.sh ${EMACS_VERSION} ${ARCH}

ENTRYPOINT [ "/bin/sh", "-c", "while true; do /bin/sleep 1; done" ]
