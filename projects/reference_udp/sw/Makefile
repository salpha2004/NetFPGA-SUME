all: 
	rmmod host/driver/vc709/vc709.ko
	insmod host/driver/vc709/vc709.ko
	cd host/driver/vc709/; source ./make_device
	echo 1 > /sys/bus/pci/devices/0000\:01\:00.0/remove        
	echo 1 > /sys/bus/pci/rescan





