source ./env_config

# launch the workflow
nextflow kuberun cosi1/nextflow-vep -v $PVC_NAME --vep_image=$VEP_IMAGE_NAME $@
