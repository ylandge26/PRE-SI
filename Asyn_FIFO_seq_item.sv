
/*****************************************************************
Module name: Asyn_FIFO_seq_item.sv
Authours: Team 1
		1. Suraksha Yelawala Swamygowda
		2. Sneha Ramaiah 
		3. Ngan Ho
		4. Yogeshwar Gajanan Landge
		5. Mohamed Gnedi
Date: 	May 22th, 2024
Descriptions: 	The sequence item class contains necessary stimulus generation data members
******************************************************************/
import uvm_pkg::*;
`include "uvm_macros.svh"

class Asyn_FIFO_seq_item extends uvm_sequence_item;

	// Register to UVM Factory
	//`uvm_object_utils(Asyn_FIFO_seq_item)
	
	// Request (inputs)
	randc bit [7:0] data_in;						// Random the data input write to FIFO
	rand bit wr_request, rd_request;     			// Random read and write request
	rand bit rrst_n;
	rand bit wrst_n;
	
	// Outputs
	bit [7:0] data_out;								// Data output read from FIFO
	bit clk;										// reset and clock signal
	bit wfull, hfull; 							// full and half_full
	bit qfull, tfull;								// 1/4-full and 3/4-full
	bit rempty, hempty;      					// empty and half_empty
	bit qempty, tempty;								// 1/4-empty and 3/4-empty
	
	// Register to UVM Factory 
	// used the uvm_field_int for print all the data if needed
	`uvm_object_utils_begin(Asyn_FIFO_seq_item) 
		`uvm_field_int (data_in, UVM_DEFAULT + UVM_DEC)
		`uvm_field_int (wr_request, UVM_DEFAULT + UVM_DEC)
		`uvm_field_int (rd_request, UVM_DEFAULT + UVM_DEC)
		`uvm_field_int (rrst_n, UVM_DEFAULT + UVM_DEC)
		`uvm_field_int (wrst_n, UVM_DEFAULT + UVM_DEC)
		`uvm_field_int (data_out, UVM_DEFAULT + UVM_DEC)
		`uvm_field_int (wfull, UVM_DEFAULT + UVM_DEC)
		`uvm_field_int (hfull, UVM_DEFAULT + UVM_DEC)
		`uvm_field_int (qfull, UVM_DEFAULT + UVM_DEC)
		`uvm_field_int (tfull, UVM_DEFAULT + UVM_DEC)
		`uvm_field_int (rempty, UVM_DEFAULT + UVM_DEC)
		`uvm_field_int (hempty, UVM_DEFAULT + UVM_DEC)
		`uvm_field_int (qempty, UVM_DEFAULT + UVM_DEC)
		`uvm_field_int (tempty, UVM_DEFAULT + UVM_DEC)
	
	`uvm_object_utils_end
	
	// Standard UVM constructor
	function new (string name = "Asyn_FIFO_seq_item");
		super.new(name);
	endfunction
	
endclass: Asyn_FIFO_seq_item