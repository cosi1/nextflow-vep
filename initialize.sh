source ./env_config

# build the VEP image
docker build -t $VEP_IMAGE_NAME -f kube/Dockerfile-vep .
# create the persistent volume
kubectl apply -f kube/pvc.yaml 
