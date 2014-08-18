XPCIE_HOME := $(shell pwd)

XPCIE_KVER := $(shell uname -r)

obj-m := sume.o

all:
	make -C /lib/modules/$(XPCIE_KVER)/build M=$(XPCIE_HOME) modules
	#g++ reg_test.cpp -o reg_test
clean:
	make -C /lib/modules/$(XPCIE_KVER)/build M=$(XPCIE_HOME) clean
