source ./env_config

# remove the persistent volume
kubectl delete -f kube/pvc.yaml
# delete the VEP image
docker rmi $VEP_IMAGE_NAME
