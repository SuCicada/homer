ifneq ("$(wildcard .env)","")
	include .env
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


