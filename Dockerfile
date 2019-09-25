ARG PACKER_VERSION

FROM hashicorp/packer:${PACKER_VERSION}

ARG ANSIBLE_VERSION
ARG AWSCLI_VERSION
ARG INSPEC_VERSION

RUN apk update && \
    apk upgrade && \
    apk --no-cache add python3 ca-certificates ruby ruby-rdoc ruby-irb openssh-client && \
    apk --no-cache add --virtual .sd-build-dependencies gcc libffi-dev openssl-dev build-base ruby-dev python3-dev linux-headers musl-dev

# Configure python3
RUN pip3 install --upgrade pip setuptools && \
    ln -s /usr/bin/python3 /usr/bin/python

RUN pip install awscli==${AWSCLI_VERSION} ansible==${ANSIBLE_VERSION}
RUN gem install inspec -v ${INSPEC_VERSION} \
    && gem install ed25519 rbnacl rbnacl-libsodium bcrypt_pbkdf

# Cleanup
RUN apk --no-cache del .sd-build-dependencies \
    && rm -rf /tmp/*

ADD scripts/* /bin/
RUN chmod +x /bin/*
RUN sync && \
    /bin/keyscan.sh github.com nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8 && \
    /bin/keyscan.sh bitbucket.org zzXQOXSRBEiUtuE8AikJYKwbHaxvSc0ojez9YXaGp1A && \
    /bin/keyscan.sh gitlab.com ROQFvPThGrW4RuWLoL9tq9I9zJ42fK4XywyRtbOz/EQ

ENTRYPOINT ["/bin/bash", "-l", "-c"]
