.DEFAULT_GOAL := all
CHART := sscs-tribunals
CI_VALUES := ci-values.yaml
RELEASE := chart-${CHART}-release
NAMESPACE := chart-tests
TEST := ${RELEASE}-test-service
ACR := hmcts
AKS_RESOURCE_GROUP :=  cnp-aks-rg
AKS_CLUSTER := cnp-aks-cluster
SUBSCRIPTION := 1c4f0704-a29e-403d-b719-b90c34ef14c9

setup:
	az configure --defaults acr=${ACR}
	az acr helm repo add
	az aks get-credentials --resource-group ${AKS_RESOURCE_GROUP} --name ${AKS_CLUSTER} --overwrite-existing --subscription ${SUBSCRIPTION}
	helm dependency update ${CHART}

delete:
	-helm delete --purge ${RELEASE}

clean:
	-helm delete --purge ${RELEASE}
	-kubectl delete pod ${TEST} -n ${NAMESPACE}

lint:
	helm lint ${CHART} --namespace ${NAMESPACE} -f ci-values.yaml

inspect:
	helm inspect chart ${CHART}

deploy:
	helm install ${CHART} --name ${RELEASE} --namespace ${NAMESPACE} -f ${CI_VALUES}  --wait  --timeout 420

test:
	helm test ${RELEASE}

all: setup clean lint deploy test

.PHONY: setup clean lint deploy test all
