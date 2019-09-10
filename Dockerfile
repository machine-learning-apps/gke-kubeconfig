FROM google/cloud-sdk:alpine

LABEL "com.github.actions.name"="Get kubeconfig file from GKE"
LABEL "com.github.actions.description"="Get kubeconfig file from Google Kubernetes Engine (GKE) for kubectl"
LABEL "com.github.actions.icon"="download"
LABEL "com.github.actions.color"="blue"
LABEL "repository"="https://github.com/machine-learning-apps/gke-kubeconfig"
LABEL "homepage"="http://github.com/actions"
LABEL "maintainer"="Hamel Husain <hamel.husain@gmail.com>"

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN gcloud components install kubectl


ENTRYPOINT ["/entrypoint.sh"]