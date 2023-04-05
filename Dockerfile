# syntax=docker/dockerfile:1

#FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy
FROM ubuntu:xenial
# set labels
LABEL maintainer="joshbarry92"

# set env vars 
ENV PAPERCUT_MAJOR_VER "22.x"
ENV PAPERCUT_NG_VER "22.0.10.65996"
ENV PAPERCUT_FILE "pcng-setup-${PAPERCUT_NG_VER}.sh"
ENV PAPERCUT_NG_DOWNLOAD_URL "https://cdn.papercut.com/web/products/ng-mf/installers/ng/${PAPERCUT_MAJOR_VER}/${PAPERCUT_FILE}"

RUN \
# Create Papercut User
  echo "**** creating users****" && \ 
  useradd -mUd /papercut -s /bin/bash papercut && \  
# Install Dependent Pachages  
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    wget \
    cups \
    cpio && \
  echo "**** install papercut-ng ****" && \
  wget "${PAPERCUT_NG_DOWNLOAD_URL}" --no-check-certificate && \ 
  chmod +x "${PAPERCUT_FILE}" && \
  chown papercut:papercut "${PAPERCUT_FILE}" && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* 

RUN echo 'papercut ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

# Running the installer as papercut user and running root tasks as root user
RUN runuser -l papercut -c "/${PAPERCUT_FILE} --non-interactive" && \
    rm -f /"${PAPERCUT_FILE}" && \ 
    /bin/sh /papercut/MUST-RUN-AS-ROOT && \
    service papercut start

# add local files
COPY root/ /

# ports and volumes
EXPOSE 9191
VOLUME /config /papercut