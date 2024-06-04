
/*****************************************************************
Module name: Asyn_FIFO_test.sv
Authours: 	Team 1
			1. Suraksha Yelawala Swamygowda
			2. Sneha Ramaiah 
			3. Ngan Ho
			4. Yogeshwar Gajanan Landge
			5. Mohamed Gnedi
Date: 		June 2nd, 2024
Descriptions:	The test class in the place where we connect the environment and the sequence item together 
******************************************************************/
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "Asyn_FIFO_evn.sv"
//`include "Asyn_FIFO_seq.sv"


class Asyn_FIFO_test extends uvm_test;
	// Register to UVM Factory
	`uvm_component_utils(Asyn_FIFO_test)
	
	// Instantiate environment and sequence item
	Asyn_FIFO_evn evn;
	Asyn_FIFO_seq test_seq;
	
	//NEW VARIABLES ADDED TODAY
	//protected int default_fd;
  	//protected int warning_fd;

	//--------------------------------------------------------------
	// Standard UVM constructor, for the uvm_component class needs 2 arguments
	// name of our class and the uvm_component parent
	//--------------------------------------------------------------
	function new (string name = "Asyn_FIFO_test", uvm_component parent = null);
		super.new(name, parent);
		`uvm_info ("Asyn_FIFO_test", "Inside Constructor!", UVM_HIGH);
	endfunction
	
	//--------------------------------------------------------------
	// Build Phase
	// Create the sub-components using UVM method
	//--------------------------------------------------------------
	function void build_phase (uvm_phase phase) ;
		super.build_phase (phase);
		`uvm_info ("Asyn_FIFO_test", "Inside Build Phase!", UVM_HIGH);	
		// create the sub-components using the UVM method
		evn = Asyn_FIFO_evn::type_id::create("evn", this);
	endfunction
	
  //NEW LINE ADDED TODAY	
  //----------------------------------------------------------------------------
  // Function: start_of_simulation_phase
  //----------------------------------------------------------------------------

  function void start_of_simulation_phase( uvm_phase phase );
    int default_fd;
    int warning_fd;
    int error_fd;
    int fatal_fd;

    default_fd     = $fopen( "default_file.log", "w" );
    warning_fd     = $fopen( "warning_file.log", "w" );
    error_fd         = $fopen( "error_file.log",         "w" );
    fatal_fd = $fopen( "fatal_file.log", "w" );
    //assert( default_fd     );
    //assert( warning_fd     );
    //assert( id1_fd         );
    //assert( warning_id1_fd );
    
    /*evn.agent.set_report_severity_action( UVM_INFO,    UVM_DISPLAY | UVM_LOG );
    evn.agent.set_report_severity_action( UVM_WARNING, UVM_DISPLAY | UVM_LOG );
    evn.agent.set_report_severity_action( UVM_ERROR,   UVM_DISPLAY | UVM_LOG );
    evn.agent.set_report_severity_action( UVM_FATAL,   UVM_DISPLAY | UVM_LOG );*/
	
    set_report_severity_action_hier( UVM_INFO,    UVM_DISPLAY | UVM_LOG );
    set_report_severity_action_hier( UVM_WARNING,    UVM_DISPLAY | UVM_LOG );
    set_report_severity_action_hier( UVM_ERROR,    UVM_DISPLAY | UVM_LOG );
    set_report_severity_action_hier( UVM_FATAL,    UVM_DISPLAY | UVM_LOG );


    set_report_severity_file_hier (UVM_INFO, default_fd);
    set_report_severity_file_hier (UVM_WARNING, warning_fd);
    set_report_severity_file_hier (UVM_ERROR, error_fd);
    set_report_severity_file_hier (UVM_FATAL, fatal_fd);
    /*evn.scb.set_report_severity_action( UVM_WARNING, UVM_DISPLAY | UVM_LOG );
    evn.scb.set_report_severity_action( UVM_ERROR,   UVM_DISPLAY | UVM_LOG );
    evn.scb.set_report_severity_action( UVM_FATAL,   UVM_DISPLAY | UVM_LOG );

    /*evn.agent.set_report_default_file    (                     default_fd     );
    evn.agent.set_report_severity_file   ( UVM_WARNING,        warning_fd     );
	
    evn.scb.set_report_default_file    (                     default_fd     );
    evn.scb.set_report_severity_file   ( UVM_WARNING,        warning_fd     );
    //env.set_report_id_file         (              "id1", id1_fd         );
    //env.set_report_severity_id_file( UVM_WARNING, "id1", warning_id1_fd );*/
  endfunction: start_of_simulation_phase
	
	// End of Elab phase for topolpgy
	virtual function void end_of_elaboration_phase (uvm_phase phase);
		super.end_of_elaboration_phase (phase);
		uvm_top.print_topology ();
	endfunction
	
	// NEW LINES ADDED TODAY
	
	virtual function void report_phase(uvm_phase phase);
	
	uvm_report_server svr;
	super.report_phase(phase);
	svr = uvm_report_server::get_server();
	
	`uvm_info(get_type_name(), "=========== TEST REPORTING======", UVM_HIGH);	
	/*svr.set_verbosity_level(UVM_HIGH); // Set verbosity level
    svr.set_severity_id_action(UVM_INFO, UVM_LOG); // Log info messages
    svr.set_file_name("uvm_report.log"); // Direct output to a log file*/
endfunction
	
	// Connect Phase
	function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info ("Asyn_FIFO_test", "Inside Connect Phase", UVM_HIGH);
	endfunction
	
  // NEW LINES ADDED TODAY	
  //----------------------------------------------------------------------------
  // Function: final_phase
  //----------------------------------------------------------------------------

  //function void final_phase( uvm_phase phase );
    //$fclose( default_fd );
    //$fclose( warning_fd     );
    //$fclose( id1_fd         );
    //$fclose( warning_id1_fd );
  //endfunction: final_phase
	
	// Run Phase
	task run_phase (uvm_phase phase);
		super.run_phase (phase);
		`uvm_info("Asyn_FIFO_test", "Inside Run Phase", UVM_HIGH);
		phase.raise_objection(this);
		repeat (1) begin
			test_seq = Asyn_FIFO_seq::type_id::create("test_seq");
			test_seq.start(evn.agent.seqr);
		end
		#3;
		phase.drop_objection(this);
	endtask
endclass