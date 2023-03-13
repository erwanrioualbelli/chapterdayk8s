OS=$(uname -s)

function remove() {
  # PARAMS
  HOSTNAME=$1
  # INTERNAL HELPERS
  function yell() { printf "$0: $*" >&2; }
  function try() { "$@" || die "cannot $*"; }
  function die() {
    yell "$*"
    exit 111
  }
  # LOGIC
  if
    [ -n "$(grep $HOSTNAME /etc/hosts)" ]
  then
    printf "$HOSTNAME found in /etc/hosts. Removing now...\n"
    try sudo sed -ie "/[[:space:]]$HOSTNAME/d" "/etc/hosts"
  else
    yell "$HOSTNAME was not found in /etc/hosts"
  fi
}

git submodule update --init --recursive -j 8
git submodule foreach 'git checkout chapter-day'
git submodule foreach 'git fetch'
git submodule foreach 'git pull --ff-only'

if
  [ "$OS" = "Darwin" ]
then
  echo "127.0.0.1  www.chapterday.dev" | sudo tee -a /etc/hosts
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.6.4/deploy/static/provider/aws/deploy.yaml
else
  MINIKUBE_IP=$(minikube ip)
  remove "wwww.chapterday.dev"
  echo "${MINIKUBE_IP}  www.chapterday.dev" | sudo tee -a /etc/hosts
fi

remove "wwww.chapterday.dev"
