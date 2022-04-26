GIT_BRANCH 		?= $(shell git symbolic-ref --short -q HEAD | sed 's/[\.\/]/-/g')
CLUSTER_NAME		?= terraform-ansible-jenkins
#TF_BACKEND_PROFILE	?= development
#TF_BACKEND_REGION	?= eu-north-1
#TF_BACKEND_BUCKET	?= terraform-development-tfstates
TF_BACKEND_PATH_PREFIX	?= devops/$(GIT_BRANCH)/$(CLUSTER_NAME)
PRIVATE_KEY_PATH        ?=~/.ssh/jenkins-ec2.pem
PUBLIC_KEY_PATH         ?=~/.ssh/jenkins-ec2.pub
export

info:
	@echo "Cluster Name: $(CLUSTER_NAME)"
	@echo "Git Branch: $(GIT_BRANCH)"

context:
	@aws sts get-caller-identity --profile $(TF_BACKEND_PROFILE)

jenkins/init:
	@rm -rf infra/.terraform
	@cd infra && terraform init \
    	-backend-config="key=$(TF_BACKEND_PATH_PREFIX)/jenkins.tfstate"

jenkins/plan:
	@cd infra && terraform plan \
		-var jenkins_private_key=$(PRIVATE_KEY_PATH) \
		-var jenkins_pub_key=$(PUBLIC_KEY_PATH)

jenkins/apply:
	@cd infra && terraform apply -auto-approve \
		-var jenkins_private_key=$(PRIVATE_KEY_PATH) \
		-var jenkins_pub_key=$(PUBLIC_KEY_PATH)

jenkins/state:
	@cd infra && terraform refresh \
		-var jenkins_private_key=$(PRIVATE_KEY_PATH) \
		-var jenkins_pub_key=$(PUBLIC_KEY_PATH)
	@cd infra && terraform state status \
		-var jenkins_private_key=$(PRIVATE_KEY_PATH) \
		-var jenkins_pub_key=$(PUBLIC_KEY_PATH)

jenkins/destroy:
	@cd infra && terraform destroy -auto-approve \
		-var jenkins_private_key=$(PRIVATE_KEY_PATH) \
		-var jenkins_pub_key=$(PUBLIC_KEY_PATH)

jenkins/clean:
	@rm -rf infra/.terraform
