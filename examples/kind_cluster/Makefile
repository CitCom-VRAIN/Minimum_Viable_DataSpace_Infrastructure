include ../config/common.mk

.PHONY: init_apply, destroy

## Init & apply ALL Terraform resources (cluster + services).
init_apply:
	terraform init
	terraform apply -auto-approve \
		-target=module.local_k8s_cluster
	terraform apply -auto-approve \
		-target=module.cluster_config
	terraform apply -auto-approve \
		-target=module.portainer
	terraform apply -auto-approve \
		-target=module.cert_trust_manager

## Destroy ALL Terraform resources (cluster + services).
destroy:
	terraform destroy -auto-approve \
		-target=module.cert_trust_manager
	terraform destroy -auto-approve \
		-target=module.portainer
	terraform destroy -auto-approve \
		-target=module.cluster_config
	terraform destroy -auto-approve \
		-target=module.local_k8s_cluster
	$(remove_tmp_tf)