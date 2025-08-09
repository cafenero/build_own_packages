FROM centos:centos7

ARG EMACS_VERSION
ARG ARCH

ADD make_pkg.sh /root/
WORKDIR /root/

RUN sed -i -e '/^mirrorlist/d;/^#baseurl=/{s,^#,,;s,/mirror,/vault,;}' /etc/yum.repos.d/CentOS*.repo
RUN yum clean all
RUN yum makecache

RUN /root/make_pkg.sh ${EMACS_VERSION} ${ARCH}

ENTRYPOINT [ "/bin/sh", "-c", "while true; do /bin/sleep 1; done" ]
