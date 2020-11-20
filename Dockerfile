FROM alpine:3.12

RUN apk add \
        bash \
        curl \
        jq \
        py-pip
RUN pip install awscli
RUN if ! curl -fL -o /usr/local/bin/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.12/2020-11-02/bin/linux/amd64/kubectl; then \
        echo >&2 "error: failed to download kubectl binary"; \
        exit 1; \
    fi; \
    chmod +x /usr/local/bin/kubectl

COPY main.sh /main.sh
COPY post.sh /post.sh
COPY util.sh /util.sh
ENTRYPOINT ["/main.sh"]
