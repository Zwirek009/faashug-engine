FROM openfaas/classic-watchdog:0.18.1 as watchdog

FROM alpine:3.11

RUN apk add --no-cache --upgrade bash

RUN mkdir -p /home/app

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# Add non root user
RUN addgroup -S app && adduser app -S -G app
RUN chown app /home/app

WORKDIR /home/app

COPY script.sh .
RUN chmod +x script.sh

USER app

ENV EXECUTION_MINUTES=31

# Populate example here - i.e. "cat", "sha512sum" or "node index.js"
ENV fprocess="./script.sh"
# Set to true to see request in function logs
ENV write_debug="true"

EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
