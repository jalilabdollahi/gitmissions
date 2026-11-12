#!/usr/bin/env bash
set -e
git merge release/2.4 >/dev/null || true
cat > k8s/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop-api
spec:
  replicas: 6
  template:
    spec:
      containers:
      - name: api
        image: shop/api:2.4.0
        resources:
          limits:
            memory: 512Mi
EOF
cat > k8s/configmap.yaml <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: shop-config
data:
  LOG_LEVEL: warn
  REGION: eu-west-1
  CACHE_TTL: "300"
  FEATURE_CHECKOUT_V2: "true"
EOF
cat > k8s/hpa.yaml <<'EOF'
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: shop-api
spec:
  minReplicas: 3
  maxReplicas: 20
  targetCPUUtilizationPercentage: 70
EOF
cat > k8s/ingress.yaml <<'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: shop
spec:
  rules:
  - host: www.shop.example.com
  tls:
  - hosts:
    - www.shop.example.com
    secretName: shop-tls
EOF
git add k8s/deployment.yaml k8s/configmap.yaml k8s/hpa.yaml k8s/ingress.yaml
git rm -q k8s/legacy-svc.yaml
git commit -q --no-edit
