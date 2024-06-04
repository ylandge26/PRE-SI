
/*****************************************************************
Module name: Asyn_FIFO_tb_top.sv
Authours: 	Team 1
			1. Suraksha Yelawala Swamygowda
			2. Sneha Ramaiah 
			3. Ngan Ho
			4. Yogeshwar Gajanan Landge
			5. Mohamed Gnedi
Date: 		June 2nd, 2024
Descriptions:	The tb top is static container that has an instantiation of DUT and interfaces.
******************************************************************/
import uvm_pkg::*;
`include "uvm_macros.svh"

//------------------------------------------
// Include all files needed
//------------------------------------------
`include "Asyn_FIFO_test.sv"
`include "ASYN_FIFO1.sv"
`include "Asyn_FIFO1_Interface.sv"

module Asyn_FIFO_tb_top;

	 //parameters for data size and address size
	parameter DSIZE = 8;
	parameter ASIZE = 9;
	
	//parameters for read clock cycle and read clock width
	parameter CLK_CYCLE_READ = 2;
	parameter CLK_WIDTH_READ = CLK_CYCLE_READ/2; //1ns since it is 500MHZ
	
	//parameters for write clock cycle and write clock width
	parameter CLK_CYCLE_WRITE = 2;
	parameter CLK_WIDTH_WRITE = CLK_CYCLE_WRITE/2; //1ns since it is 500MHZ

	//Interface signals Instantiate
    ASYNFIFO1Signals intf();

	// Instantiate the FIFO
	aysn_fifo1 #(DSIZE,ASIZE) dut(.*);
	
	initial begin
		forever #(CLK_WIDTH_READ)intf.rclk = ~intf.rclk;
	end 
	
	initial begin
		forever #(CLK_WIDTH_WRITE)intf.wclk = ~intf.wclk;
	end 
	
	
	// setting interface config db
	initial begin
		uvm_config_db #(virtual ASYNFIFO1Signals)::set(null, "*", "intf", intf);
	end
	
	// start testing
	initial begin
		run_test ("Asyn_FIFO_test");
	end
	
		
	initial begin
	
		// $monitor("%t, counter = %d, raddr = %d\t%d\t%d\t%d\t%d\t%d\t%d\t",$time, dut.rptr_empty.cycle_counter,dut.fifomem.raddr, intf.rdata, dut.fifomem.fifo[0],dut.fifomem.fifo[1],dut.fifomem.fifo[2], dut.fifomem.fifo[3], dut.fifomem.fifo[4]);
        intf.rclk = 0;
        intf.wclk = 0;
		repeat (5000) @ (negedge intf.wclk or negedge intf.rclk);
		$finish;
	end
	
endmodule