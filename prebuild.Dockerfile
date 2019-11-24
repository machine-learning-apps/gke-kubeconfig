FROM google/cloud-sdk:alpine

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN gcloud components install kubectl
