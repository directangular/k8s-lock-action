FROM directangular/k8s-lock-action

COPY main.sh /main.sh
COPY post.sh /post.sh
COPY util.sh /util.sh
ENTRYPOINT ["/main.sh"]
