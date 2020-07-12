FROM alpine:3.12

RUN apk add --no-cache --upgrade bash
COPY script.sh script.sh
RUN chmod +x script.sh

ENTRYPOINT [ "./script.sh" ]
CMD [ "-m 17" ]