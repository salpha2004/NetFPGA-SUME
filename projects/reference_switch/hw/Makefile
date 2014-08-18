all: clean
	vivado -mode batch -source reference_switch.tcl

clean: 
	rm -rf synth/ ip_repo/ vivado*.*

sim:	clean
	vivado -mode batch -source reference_udp_sim.tcl

