HW = hw
SW = sw/embedded/
HW_INSTANCES := $(shell cd $(HW) && find . -maxdepth 1 -type d)
HW_INSTANCES := $(basename $(patsubst ./%,%,$(HW_INSTANCES)))
SW_INSTANCES := $(shell cd $(SW) && find . -maxdepth 1 -type d)
SW_INSTANCES := $(basename $(patsubst ./%,%,$(SW_INSTANCES)))

RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)
all:
	sume


sume:
	$(MAKE) -C $(HW)/
#	$(MAKE) -C $(SW)/

clean:
	for flow in $(HW_INSTANCES) ; do \
		echo $$flow; \
		if test -f $(HW)/$$flow/Makefile; \
			then $(MAKE) -C $(HW)/$$flow/ clean; \
		fi; \
	done;
	for flow in $(SW_INSTANCES) ; do \
		if test -f $(SW)/$$flow/Makefile; \
			then $(MAKE) -C $(SW)/$$flow/ clean; \
		fi; \
	done;
	@echo "/////////////////////////////////////////";
	@echo "//project cleaned.";
	@echo "/////////////////////////////////////////";




