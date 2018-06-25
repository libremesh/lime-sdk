FROM debian:latest

RUN apt-get update && apt-get install subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc wget unzip python time -y

RUN git clone https://github.com/aparcar/lime-sdk.git /app \
  && cd /app \
  && git checkout develop

WORKDIR /app

ENTRYPOINT ["/app/cooker"]
CMD ["--help"]
