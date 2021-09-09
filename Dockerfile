ARG TAG="2.6.1"
ARG UBI_IMAGE
ARG GO_IMAGE

# Build the project
FROM ${GO_IMAGE} as builder
RUN set -x \
 && apk --no-cache add \
    git \
    make
ARG TAG
RUN git clone --depth=1 https://github.com/k8snetworkplumbingwg/sriov-cni
WORKDIR sriov-cni
RUN git fetch --all --tags --prune
RUN git checkout tags/${TAG} -b ${TAG} 
RUN make clean && make build 

# Create the sriov-cni image
FROM ${UBI_IMAGE}
WORKDIR /
RUN yum update -y && \
    rm -rf /var/cache/yum
COPY --from=builder /go/sriov-cni/build/sriov /usr/bin/
COPY --from=builder /go/sriov-cni/images/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
