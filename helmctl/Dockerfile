FROM alpine:3.17.3

RUN apk add curl

RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v1.26.3/bin/linux/amd64/kubectl -o /usr/bin/kubectl && chmod u+x /usr/bin/kubectl

RUN curl -LO https://get.helm.sh/helm-v3.11.2-linux-amd64.tar.gz && tar -zxvf helm-v3.11.2-linux-amd64.tar.gz && mv linux-amd64/helm /usr/bin/helm

