SHELL := /bin/bash

.DEFAULT_GOAL := help

define remove_tmp_tf
	rm -rf .terraform && \
	rm -rf .terraform.lock.hcl && \
	rm -rf terraform.tfstate && \
	rm -rf terraform.tfstate.backup
endef

define deploy_cluster
	@export module=$(1) && \
		cd ../kind_cluster && \
		terraform init -upgrade && \
		terraform apply -auto-approve \
			-target=module.local_k8s_cluster \
			-var-file="../$$module/config/kind_cluster.tfvars" && \
		terraform apply -auto-approve \
			-target=module.cluster_config \
			-var-file="../$$module/config/kind_cluster.tfvars" && \
		terraform apply -auto-approve \
			-target=module.portainer \
			-var-file="../$$module/config/kind_cluster.tfvars" && \
		terraform apply -auto-approve \
			-target=module.cert_trust_manager \
			-var-file="../$$module/config/kind_cluster.tfvars"
endef

define destroy_cluster
	@export module=$(1) && \
		cd ../kind_cluster && \
		terraform destroy -auto-approve \
			-target=module.cert_trust_manager \
			-var-file="../$$module/config/kind_cluster.tfvars" && \
		terraform destroy -auto-approve \
			-target=module.portainer \
			-var-file="../$$module/config/kind_cluster.tfvars" && \
		terraform destroy -auto-approve \
			-target=module.cluster_config \
			-var-file="../$$module/config/kind_cluster.tfvars" && \
		terraform destroy -auto-approve \
			-target=module.local_k8s_cluster \
			-var-file="../$$module/config/kind_cluster.tfvars" && \
		$(remove_tmp_tf) && \
		rm -rf terraform.tfvars
endef

define deploy_services
	terraform init -upgrade
	terraform apply -auto-approve 
endef

define destroy_services
	terraform destroy -auto-approve
	$(remove_tmp_tf)
	rm -rf terraform.tfvars
endef

################################################################################
# Self Documenting Commands                                                    #
################################################################################
# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')