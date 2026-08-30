FROM alpine:latest

ARG VERSION_SOPS=3.13.3
ARG VERSION_VALS=0.46.0
ARG VERSION_KUBECTL=1.36.2
ARG AGE_VERSION=1.3.1
ARG HELM_SECRETS_VERSION=4.7.7

# SHELL ["/bin/sh", "-exc"]

ENV HOME=/home/user/

RUN if [ "$(uname -m)" == "x86_64" ]; then CURL_ARCH=amd64; GO_ARCH=amd64; else CURL_ARCH="aarch64" GO_ARCH="arm64"; fi \
# Prepare non root user
    && adduser -D user \
# Download all required bineries according to: https://github.com/jkroepke/helm-secrets/blob/main/docs/ArgoCD%20Integration.md#option-2-init-container
    && wget -qO /usr/local/bin/curl https://github.com/moparisthebest/static-curl/releases/latest/download/curl-${CURL_ARCH} \
    && wget -qO /usr/local/bin/kubectl https://dl.k8s.io/release/v${VERSION_KUBECTL}/bin/linux/${GO_ARCH}/kubectl \
    && wget -qO /usr/local/bin/sops https://github.com/getsops/sops/releases/download/v${VERSION_SOPS}/sops-v${VERSION_SOPS}.linux.${GO_ARCH} \
    && wget -qO- https://github.com/variantdev/vals/releases/download/v${VERSION_VALS}/vals_${VERSION_VALS}_linux_amd64.tar.gz | tar xzf - -C /usr/local/bin/ vals \
    && wget -qO- https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz | tar -xzf- --strip-components=1 -C /usr/local/bin/ age/age \
# Make binaries executable
    && chmod +x /usr/local/bin/* \
# Download helm secrets plugin and script files
    && mkdir /usr/local/bin/helm-plugins \
    && wget -qO- https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/secrets-${HELM_SECRETS_VERSION}.tgz | tar -C /usr/local/bin/helm-plugins/ -xzf- \
    && wget -qO- https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/secrets-getter-${HELM_SECRETS_VERSION}.tgz | tar -C /usr/local/bin/helm-plugins/ -xzf- \
    && wget -qO- https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/secrets-post-renderer-${HELM_SECRETS_VERSION}.tgz | tar -C /usr/local/bin/helm-plugins/ -xzf- \
    && cp /usr/local/bin/helm-plugins/secrets/scripts/wrapper/helm.sh /usr/local/bin/helm

USER user

# ENTRYPOINT ["cp",  "-r",  "/usr/local/bin/*",  "/gitops-tools/"]
ENTRYPOINT cp -r /usr/local/bin/* /gitops-tools/