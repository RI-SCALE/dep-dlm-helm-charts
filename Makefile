CHARTS := $(wildcard charts/*)
VERSION ?= 0.0.0
DIST ?= dist
# Kubernetes version the rendered manifests are validated against.
KUBE_VERSION ?= 1.34.0
CRD_SCHEMAS := https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json
KUBECONFORM := kubeconform -strict -summary -kubernetes-version $(KUBE_VERSION) \
	-schema-location default -schema-location '$(CRD_SCHEMAS)'

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z_-]+:.*## / {printf "  %-8s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: hooks
hooks: ## Install the pre-commit hook
	pre-commit install

.PHONY: check
check: ## Run pre-commit on all files
	pre-commit run --all-files

.PHONY: lint
lint: ## helm lint --strict and kubeconform per chart, with defaults and each ci/ values file
	@set -e; for chart in $(CHARTS); do \
	  for values in "" $$(find $$chart/ci -name '*.yaml' 2>/dev/null | sort); do \
	    echo "==> $$chart $${values:-(defaults)}"; \
	    helm lint --strict $$chart $${values:+-f $$values}; \
	    helm template $$(basename $$chart) $$chart $${values:+-f $$values} | $(KUBECONFORM); \
	  done; \
	done

.PHONY: package
package: ## Package every chart as VERSION into DIST
	@mkdir -p $(DIST)
	@for chart in $(CHARTS); do helm package $$chart --version $(VERSION) --destination $(DIST); done
