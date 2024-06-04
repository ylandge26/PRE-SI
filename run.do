vlib work
vlog -lint Asyn_FIFO1_Interface.sv +acc
vlog -lint Asyn_FIFO_evn.sv +acc
vlog -lint Asyn_FIFO_seq.sv +acc
vlog -lint Asyn_FIFO_seq_item.sv +acc
vlog -lint Asyn_FIFO_seqr_drv.sv +acc
vlog -lint Asyn_FIFO_tb_top.sv +acc
vlog -lint ASYN_FIFO1.sv +acc
vlog -lint Asyn_FIFO_test.sv +acc

# Simulate
vsim work.Asyn_FIFO_tb_top

# run
run -all


#vsim -coverage work.Asyn_FIFO_tb_top -voptargs="+cover=bcesf";

#coverage report -code bcesf
#coverage report -details
## Save coverage reports in text files
#coverage report -code bcesf -file coverage_summary.txt
#coverage report -details -file detailed_coverage.txt