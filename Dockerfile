# Using ubi7 base image for mongod can update to stacks-node-rhel8 when mongod available
FROM registry.redhat.io/codeready-workspaces/stacks-node

ARG MAVEN_VERSION=3.6.1
ARG MAVEN_URL=https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz

USER root

# Extra repos not part of ubi
COPY mongodb-org-3.6.repo /etc/yum.repos.d/
COPY google-chrome.repo /etc/yum.repos.d/

# Copy entitlements
COPY ./etc-pki-entitlement /etc/pki/entitlement
# Copy subscription manager configurations
COPY ./rhsm-conf /etc/rhsm
COPY ./rhsm-ca /etc/rhsm/ca
# Delete /etc/rhsm-host to use entitlements from the build container
# Initialize /etc/yum.repos.d/redhat.repo
# See https://access.redhat.com/solutions/1443553
RUN rm -f /etc/rhsm-host && \
    yum repolist --disablerepo=* && \
    subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-optional-rpms  && \
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y cowsay zsh libXScrnSaver redhat-lsb xdg-utils google-chrome-stable rh-python36.x86_64 libXScrnSaver redhat-lsb xdg-utils google-chrome-stable mongodb-org-server mongodb-org-tools mongodb-org-shell git curl gcc-c++ automake python2 wget psmisc && \
    /opt/rh/rh-python36/root/usr/bin/pip3 install ansible && \
    git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh && \
    cp $HOME/.oh-my-zsh/templates/zshrc.zsh-template $HOME/.zshrc && \    
    mkdir -p /usr/share/maven && \
    curl -fsSL ${MAVEN_URL} | tar -xzC /usr/share/maven --strip-components=1 && \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn && \
    rm -rf /var/cache/yum && \
    rm -rf /etc/pki/entitlement && \
    rm -rf /etc/rhsm

# Common shell things
RUN echo "sed -e \"s|jboss:x:1000:1000::/home/jboss:/bin/bash|jboss:x:\$UID:1000::/home/jboss:/bin/bash|g\" /etc/passwd > /tmp/passwd && cp /tmp/passwd /etc/passwd && rm -f /tmp/passwd" >> /etc/profile
RUN echo "source scl_source enable rh-python36" >> /etc/bashrc
RUN echo "git config --global http.sslVerify false" >> /etc/bashrc
RUN echo "git config --global http.sslVerify false" >> /etc/zshrc
RUN echo "git config --global user.name 'Derek Dinosaur'" >> /etc/bashrc
RUN echo "git config --global user.name 'Derek Dinosaur'" >> /etc/zshrc
RUN echo "git config --global user.email 'derek@dinosaur.com'" >> /etc/bashrc
RUN echo "git config --global user.email 'derek@dinosaur.com'" >> /etc/zshrc
RUN echo "git config --global credential.helper 'store --file ~/.my-credentials'" >> /etc/bashrc
RUN echo "git config --global credential.helper 'store --file ~/.my-credentials'" >> /etc/zshrc
RUN echo "git config --global push.default matching" >> /etc/bashrc
RUN echo "git config --global push.default matching" >> /etc/bashrc

# Fixup helpers
COPY fix-api-url.sh /usr/local/bin
RUN echo "source /usr/local/bin/fix-api-url.sh" >> /etc/bashrc
RUN echo "source /usr/local/bin/fix-api-url.sh" >> /etc/zshrc

# ENV vars for stuff
ENV MAVEN_HOME=/projects \
    MAVEN_CONFIG=${MAVEN_HOME}/.m2 \
    MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1" \
    CHROME_BIN=/bin/google-chrome

# Install jq
# http://stedolan.github.io/jq/
RUN curl -o /usr/local/bin/jq -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
  chmod +x /usr/local/bin/jq

# Add Let's Encrypt CA to OS trusted store
RUN curl -o /etc/pki/ca-trust/source/anchors/lets-encrypt-x3-cross-signed.crt https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem.txt && \
    update-ca-trust extract

# Update to latest oc client
RUN yum -y erase atomic-openshift-clients-3.11.154-1.git.0.7a097ad.el7.x86_64 && \
    curl -fsSL https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.3/linux/oc.tar.gz | tar -xzC /usr/bin/

# Default User
USER 1001
