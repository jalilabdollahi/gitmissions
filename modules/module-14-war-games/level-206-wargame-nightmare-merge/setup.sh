#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

git config merge.conflictStyle diff3
mkdir k8s
cat > k8s/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop-api
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: api
        image: shop/api:2.2.0
        resources:
          limits:
            memory: 256Mi
EOF
cat > k8s/configmap.yaml <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: shop-config
data:
  LOG_LEVEL: info
  REGION: eu-west-1
EOF
cat > k8s/hpa.yaml <<'EOF'
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: shop-api
spec:
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
EOF
cat > k8s/ingress.yaml <<'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: shop
spec:
  rules:
  - host: shop.example.com
EOF
printf 'apiVersion: v1\nkind: Service\nmetadata:\n  name: legacy\nspec:\n  ports:\n  - port: 8080\n' > k8s/legacy-svc.yaml
printf 'resources:\n- deployment.yaml\n- configmap.yaml\n- hpa.yaml\n- ingress.yaml\n- legacy-svc.yaml\n' > k8s/kustomization.yaml
git add -A; ci Mara mara@shop.dev "2025-09-01T09:00:00" "Manifests for shop 2.2"
git branch release/2.4
sed -i.bak -e 's/replicas: 3/replicas: 4/' -e 's/2.2.0/2.3.1/' -e 's/256Mi/512Mi/' k8s/deployment.yaml
sed -i.bak 's/LOG_LEVEL: info/LOG_LEVEL: warn/' k8s/configmap.yaml
printf '  CACHE_TTL: "300"\n' >> k8s/configmap.yaml
sed -i.bak 's/maxReplicas: 10/maxReplicas: 12/' k8s/hpa.yaml
sed -i.bak 's/shop.example.com/www.shop.example.com/' k8s/ingress.yaml
rm -f k8s/*.bak
git rm -q k8s/legacy-svc.yaml
printf 'resources:\n- deployment.yaml\n- configmap.yaml\n- hpa.yaml\n- ingress.yaml\n' > k8s/kustomization.yaml
git add -A; ci Mara mara@shop.dev "2025-09-15T09:00:00" "Main: scale up, quieter logs, www host, retire legacy service"
git switch -q release/2.4
sed -i.bak -e 's/replicas: 3/replicas: 6/' -e 's/2.2.0/2.4.0/' k8s/deployment.yaml
sed -i.bak 's/LOG_LEVEL: info/LOG_LEVEL: debug/' k8s/configmap.yaml
printf '  FEATURE_CHECKOUT_V2: "true"\n' >> k8s/configmap.yaml
sed -i.bak -e 's/maxReplicas: 10/maxReplicas: 20/' -e 's/Utilization.*: 80/Utilization: 70/' k8s/hpa.yaml
sed -i.bak 's/host: shop.example.com/host: shop.eu.example.com/' k8s/ingress.yaml
printf '  tls:\n  - hosts:\n    - shop.eu.example.com\n    secretName: shop-tls\n' >> k8s/ingress.yaml
sed -i.bak 's/8080/9090/' k8s/legacy-svc.yaml
rm -f k8s/*.bak
git add -A; ci Joel joel@shop.dev "2025-09-20T09:00:00" "Release 2.4: autoscale, tls and new checkout flag"
git switch -q main
