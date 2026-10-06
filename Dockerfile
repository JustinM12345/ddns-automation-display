FROM alpine:3.14

# This dockerfile adds the cloudflare DDNS script and cronjob to periodically check and update the DNS of kobo-interns.xyz if it changes

# Put args at top here 
ARG SERVER_PORT=9000
ARG SUPERCRONIC_VERSION=0.2.47
ARG TARGETARCH
ENV CLOUDFLARE_API_TOKEN=""
ENV ZONE_ID=""
ENV PORT=${SERVER_PORT}

COPY --chown=+x update-cloudflare-dns.sh /update-cloudflare-dns.sh 
COPY crontab /etc/crontab

# Arg -> Env -> Expose
EXPOSE ${SERVER_PORT}

RUN apk add --no-cache bash curl jq && \
    wget -q "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" \
    -O /usr/local/bin/supercronic && \
    chmod +x /usr/local/bin/supercronic

ENTRYPOINT ["supercronic"] 

# Run supercronic as the main process - it properly handles signals and environment
CMD ["/etc/crontab"]

# adding a comment to test a fake push
# minor comment for fake push
# fake push

# build image

# docker build -t autodnsv2 .

# docker container run -it --env-file ./app.config alpine /bin/sh 

# docker run --rm --env-file .env.local --mount type=bind,src="$(pwd)/saved-ip.txt",dst=/saved-ip.txt --mount type=bind,src="$(pwd)/ddns-logs.txt",dst=/ddns-logs.txt --name autodnsv3 autodnsv3

# docker run --rm --env-file .env.local --mount type=bind,src="/Users/justinmui/DDNS/saved-ip.txt",dst=/saved-ip.txt --mount type=bind,src="/Users/justinmui/DDNS/ddns-logs.txt",dst=/ddns-logs.txt --name autodnsv3 autodnsv3

# */5 * * * * docker run --rm --env-file .env.local --mount type=bind,src="/saved-ip.txt",dst=/saved-ip.txt --mount type=bind,src="/ddns-logs.txt",dst=/ddns-logs.txt --name autodnsv3 autodnsv3

# These commands 

# docker run -d --env-file .env.local --mount type=bind,src="$(pwd)/saved-ip.txt",dst=/saved-ip.txt --mount type=bind,src="$(pwd)/ddns-logs.txt",dst=/ddns-logs.txt --name autodns autodns

# docker exec -it autodns /bin/bash

# docker build -t juggin123/kobo-interns-ddns-automation .
# docker push juggin123/kobo-interns-ddns-automation      