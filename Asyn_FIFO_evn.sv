
/*****************************************************************
Module name: Asyn_FIFO_evn.sv
Authours: 	Team 1
			1. Suraksha Yelawala Swamygowda
			2. Sneha Ramaiah 
			3. Ngan Ho
			4. Yogeshwar Gajanan Landge
			5. Mohamed Gnedi
Date: 		May 24th, 2024
Descriptions:	The enviroment class provides a container for agents, and scoreboard.
******************************************************************/
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "Asyn_FIFO_seqr_drv.sv"
//`include "Asyn_FIFO_scb.sv"

class Asyn_FIFO_evn extends uvm_env;

	// Register to UVM Factory
	`uvm_component_utils(Asyn_FIFO_evn)
	
	// Instantiate agents and scoreboard
	Asyn_FIFO_agent agent;
	Asyn_FIFO_scb scb;
	Asyn_FIFO_coverage cov_m;
	
	//--------------------------------------------------------------
	// Standard UVM constructor, for the uvm_component class needs 2 arguments
	// name of our class and the uvm_component parent
	//--------------------------------------------------------------
	function new (string name = "Asyn_FIFO_evn", uvm_component parent = null);
		super.new(name, parent);
		`uvm_info ("Asyn_FIFO_evn", "Inside Constructor!", UVM_HIGH);
	endfunction
	
	//--------------------------------------------------------------
	// Build Phase
	// Create the sub-components using UVM method
	//--------------------------------------------------------------
	function void build_phase (uvm_phase phase) ;
		super.build_phase (phase);
		`uvm_info ("Asyn_FIFO_evn", "Inside Build Phase!", UVM_HIGH);
		
		// create the sub-components using the UVM method
		agent = Asyn_FIFO_agent::type_id::create("agent", this);
		scb = Asyn_FIFO_scb::type_id::create("scb", this);
		cov_m = Asyn_FIFO_coverage::type_id::create("cov_m", this);
	endfunction
	
	// Connect Phase
	function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info ("Asyn_FIFO_evn", "Inside Connect Phase!", UVM_HIGH);
		
		// connect the scoreboard import port to the monitor analysis port
		agent.mon.monitor_port.connect(scb.scoreboard_port);
		agent.mon.monitor_port.connect(cov_m.analysis_export);
	endfunction
	
	// Run Phase
	/*task run_phase (uvm_phase phase);
		super.run_phase(phase);
	endtask*/
	
endclass
