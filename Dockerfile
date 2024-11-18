FROM rabbitmq:3.13.7-management-alpine
LABEL maintainer="Tecsafe GmbH <support@madco.de>"

RUN apk add --no-cache curl jq

COPY entrypoint.sh /usr/local/bin/entrypoint-overwrite.sh
RUN chmod +x /usr/local/bin/entrypoint-overwrite.sh

ARG TECSAFE_VERSION
ENV TECSAFE_VERSION=${TECSAFE_VERSION}
RUN if [ -n "${TECSAFE_VERSION}" ]; then echo "${TECSAFE_VERSION}" > /etc/tecsafe_version; fi

COPY definitions.json /etc/rabbitmq/definitions.json

ENTRYPOINT [ "entrypoint-overwrite.sh" ]
CMD ["rabbitmq-server"]
