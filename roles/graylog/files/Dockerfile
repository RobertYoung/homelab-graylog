FROM debian:12

RUN apt-get update && \
  apt-get install -y curl zip unzip less vim tar mosquitto-clients ca-certificates

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install && \
  rm -rf awscliv2.zip aws

RUN curl "https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian12-x86_64-100.12.2.tgz" -o "mongodb-database-tools.tgz" && \
  tar -xzf mongodb-database-tools.tgz && \
  cp mongodb-database-tools-debian12-x86_64-100.12.2/bin/* /usr/local/bin/ && \
  rm -rf mongodb-database-tools.tgz mongodb-database-tools-debian12-x86_64-100.12.2

COPY backup.sh .

RUN chmod +x backup.sh
