ifneq ("$(wildcard .env)","")
	include .env
	include $(env_secret)
	export
endif


# ========== upload ==========

define upload
	rsync -avz \
		--rsh="ssh -o StrictHostKeyChecking=no" \
		$(1) \
		${DEPLOY_HOST}:$(DEPLOY_PATH)/$(patsubst %,%,$(2))
endef
define command
	ssh -o StrictHostKeyChecking=no $(DEPLOY_HOST) $(1)
endef


upload:
	$(call command, "mkdir -p $(DEPLOY_PATH)")
	$(call upload, dist/)

run:
	yarn serve

define git_update
	if [ ! -z "$$(git status --porcelain)" ]; then \
		git add . ; \
		git commit -m "update" ; \
		git push ; \
	fi
endef


push:
	cd config && $(call git_update)
	$(call git_update)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	architecture = "linux/amd64"
else ifeq ($(UNAME_S),Darwin)
	architecture = "linux/arm64"
endif
act-debug:
	act \
	--container-architecture $(architecture) \
    -s GITHUB_TOKEN=$(API_TOKEN_GITHUB) \
    -s ACCESS_TOKEN=$(API_TOKEN_GITHUB) \
    -s github.repository=SuCicada/homer \
    --env-file .env \
    --env-file $(env_secret)
