# the first argument is target

SCRIPTS_DIR  = tools/
LIB_HW_DIR  = lib/hw
LIB_HW_DIR_INSTANCES := $(shell cd $(LIB_HW_DIR) && find . -maxdepth 4 -type d)
LIB_HW_DIR_INSTANCES := $(basename $(patsubst ./%,%,$(LIB_HW_DIR_INSTANCES)))

TOOLS_DIR = tools
TOOLS_DIR_INSTANCES := $(shell cd $(TOOLS_DIR) && find . -maxdepth 3 -type d)
TOOLS_DIR_INSTANCES := $(basename $(patsubst ./%,%,$(TOOLS_DIR_INSTANCES)))

PROJECTS_DIR = projects
PROJECTS_DIR_INSTANCES := $(shell cd $(PROJECTS_DIR) && find . -maxdepth 1 -type d)
PROJECTS_DIR_INSTANCES := $(basename $(patsubst ./%,%,$(PROJECTS_DIR_INSTANCES)))

DEVPROJECTS_DIR = dev-projects
DEVPROJECTS_DIR_INSTANCES := $(shell cd $(DEVPROJECTS_DIR) && find . -maxdepth 1 -type d)
DEVPROJECTS_DIR_INSTANCES := $(basename $(patsubst ./%,%,$(DEVPROJECTS_DIR_INSTANCES)))



RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)
all:
	sume

clean: libclean toolsclean projectsclean devprojectsclean	

sume: 
	$(MAKE) -C $(SCRIPTS_DIR) $(RUN_ARGS)

libclean:
	for lib in $(LIB_HW_DIR_INSTANCES) ; do \
#		for lib_type in $(LIB_HW_DIR)/$$lib ; do \
#			for flow in $(LIB_HW_DIR)/$$lib/$$lib_type; do \
#				for core in $(LIB_HW_DIR)/$$lib/$$lib_type/$$flow; do \
#					if test -f $(LIB_HW_DIR)/$$lib/$$lib_type/$$flow/$$core/Makefile; \
#						then $(MAKE) -C $(LIB_HW_DIR)/$$lib/$$lib_type/$$flow/$$core clean; \
					if test -f $(LIB_HW_DIR)/$$lib/Makefile; \
						then $(MAKE) -C $(LIB_HW_DIR)/$$lib clean; \
					fi; \
#				done;\
#			done;\
#		done;\
	done;
	@echo "/////////////////////////////////////////";
	@echo "//Library cores cleaned.";
	@echo "/////////////////////////////////////////";


toolsclean:
	for lib in $(TOOLS_DIR) ; do \
#		for flow in $(TOOLS_DIR)/$$lib ; do \
#			if test "contrib" = $$flow ; then \
#				for project in $(TOOLS_DIR)/$$lib/$$flow ; do \
#					if test -f $(TOOLS_DIR)/$$lib/$$flow/$$project/Makefile; \
#						then $(MAKE) -C $(TOOLS_DIR)/$$lib/$$flow/$$project clean; \
#					fi; \
#				done;\
#			else \
				if test -f $(TOOLS_DIR)/$$lib/Makefile; \
					then $(MAKE) -C $(TOOLS_DIR)/$$lib clean; \
				fi; \
#			fi; \
#		done;\
	done;
	@echo "/////////////////////////////////////////";
	@echo "//tools cleaned.";
	@echo "/////////////////////////////////////////";


projectsclean:
	for lib in $(PROJECTS_DIR_INSTANCES) ; do \
		if test -f $(PROJECTS_DIR)/$$lib/Makefile; \
			then $(MAKE) -C $(PROJECTS_DIR)/$$lib/ clean; \
		fi; \
	done;
	@echo "/////////////////////////////////////////";
	@echo "//projects cleaned.";
	@echo "/////////////////////////////////////////";


devprojectsclean:
	for lib in $(DEVPROJECTS_DIR_INSTANCES) ; do \
		if test -f $(DEVPROJECTS_DIR)/$$lib/Makefile; \
			then $(MAKE) -C $(DEVPROJECTS_DIR)/$$lib/ clean; \
		fi; \
	done;
	@echo "/////////////////////////////////////////";
	@echo "//devprojects cleaned.";
	@echo "/////////////////////////////////////////";

