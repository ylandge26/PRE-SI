

/*****************************************************************
Module name: Asyn_FIFO_seqr_drv.sv
Authours: 	Team 1
			1. Suraksha Yelawala Swamygowda
			2. Sneha Ramaiah 
			3. Ngan Ho
			4. Yogeshwar Gajanan Landge
			5. Mohamed Gnedi
Date: 		June 2nd, 2024
Descriptions: 	The sequencer is a medicator who establishes a connection between the sequence and driver
				The driver drives randomized transactions or sequence items to DUT as a pin-level activity using an interface.
				The monitor is a passive component used to capture DUT signals using a virtual interface and translate them into a sequence item format.
				Agent Class responsible for creating monitor, driver, and sequencer objects.
				The scoreboard is responsible for checking the functional of the DUT, checking the output for making sure the output send from the DUT correct or not.
******************************************************************/
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "Asyn_FIFO_seq.sv"


class Asyn_FIFO_seqr extends uvm_sequencer #(Asyn_FIFO_seq_item);

	// Register to UVM Factory
	`uvm_component_utils(Asyn_FIFO_seqr)
	
	//--------------------------------------------------------------
	// Standard UVM constructor, for the uvm_component class needs 2 arguments
	// name of our class and the uvm_component parent
	//--------------------------------------------------------------
	function new (string name = "Asyn_FIFO_seqr", uvm_component parent = null);
		super.new(name, parent);
		`uvm_info ("Asyn_FIFO_seqr", "Inside Constructor!", UVM_HIGH);
	endfunction
	
	//--------------------------------------------------------------
	// Optional to have Build and Connect Phase in Sequencer
	//--------------------------------------------------------------
	
	// Build Phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		`uvm_info ("Asyn_FIFO_seqr", "Build Phase!", UVM_HIGH);
	endfunction
	
	// Connect Phase
	function void connect_phase (uvm_phase phase);
		super.connect_phase (phase);
		`uvm_info ("Asyn_FIFO_seqr", "Connect Phase!", UVM_HIGH);
	endfunction
	
	
endclass: Asyn_FIFO_seqr


// Driver is a parameterized class and we need to 
// provide our packet (Asyn_FIFO_seq_item) as a parameter
class Asyn_FIFO_drv extends uvm_driver #(Asyn_FIFO_seq_item);

	// Register to UVM Factory
	`uvm_component_utils(Asyn_FIFO_drv)
	
	// Instantiate the Interface and Packet (Asyn_FIFO_seq_item)
	// declare virtual interface handle
	virtual ASYNFIFO1Signals intf;
	
	// packet handle
	Asyn_FIFO_seq_item seq_item;
	
	//--------------------------------------------------------------
	// Standard UVM constructor, for the uvm_component class needs 2 arguments
	// name of our class and the uvm_component parent
	//--------------------------------------------------------------
	function new (string name = "Asyn_FIFO_drv", uvm_component parent = null);
		super.new(name, parent);
		`uvm_info ("Asyn_FIFO_drv", "Inside Constructor!", UVM_HIGH);
	endfunction
	
	// Build phase
	function void build_phase (uvm_phase phase);
		super.build_phase (phase);
		`uvm_info ("Asyn_FIFO_drv", "Inside Build Phase!", UVM_HIGH);
		// use the config db get method to get the virtual interface for driver
		// the method return 1 on success and 0 otherwise
		// checking for making sure we can get the virtual interface
		if (!(uvm_config_db #(virtual ASYNFIFO1Signals)::get(this,"*", "intf", intf))) begin
			`uvm_error ("Asyn_FIFO_drv", "Failed to get intf from config db");
		end
	endfunction
	
	// Connect Phase
	function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info ("Asyn_FIFO_drv", "Inside Connect Phase!", UVM_HIGH);
	endfunction
	
	// Run phase
	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		`uvm_info ("DRIVER_CLASS", "Inside Run Phase!", UVM_HIGH);
		
		forever begin
			// create objects/instance using UVM factory method
			seq_item = Asyn_FIFO_seq_item::type_id::create("Asyn_FIFO_seq_item");
			// get next item from the sequencer
			seq_item_port.get_next_item(seq_item);
			// drive signals to the interface
			drive (seq_item);
			// seq_item.print();
			// tell the sequence that driver has finished current item
			seq_item_port.item_done();
		end
	endtask
	
		
	//--------------------------------------------------------------
	// Drive method
	//--------------------------------------------------------------
	task drive (Asyn_FIFO_seq_item seq_item);	
		// at the posedge write clock and reset is high
		// transfer all the write signals to the DUT through the virtual interface
		@ (posedge intf.wclk or posedge intf.rclk);
			if (intf.wclk && seq_item.wrst_n) begin 
				intf.winc <= seq_item.wr_request;
				intf.wrst_n <= seq_item.wrst_n;
				// Transfer data input from the sequecer to DUT through the virtual interface when we have the write request
				if (seq_item.wr_request) begin
					intf.wdata <= seq_item.data_in;
					`uvm_info ("in write_fifo1", $sformatf ("intf.wdata = %d, seq_item.data_in = %d \n", intf.wdata, seq_item.data_in), UVM_HIGH);
				//	seq_item.print();
				end
			
			end
			// at the posedge read clock and reset is high
			// transfer all the read signals to the DUT through the virtual interface
			if (intf.rclk && seq_item.rrst_n) begin
				intf.rinc <= seq_item.rd_request;
				intf.rrst_n <= seq_item.rrst_n;
			end 
			
	
	endtask: drive
	
	
endclass: Asyn_FIFO_drv

class Asyn_FIFO_mon extends uvm_monitor;
	
	// Register to UVM Factory
	`uvm_component_utils(Asyn_FIFO_mon)
	
	// Instantiate the Interface and Packet (Asyn_FIFO_seq_item)
	// declare virtual interface handle
	virtual ASYNFIFO1Signals intf;
	
	// packet handle
	Asyn_FIFO_seq_item seq_item;
	
	// define the analysis port for monitor as per TB architecture
	uvm_analysis_port #(Asyn_FIFO_seq_item) monitor_port;
	
	//--------------------------------------------------------------
	// Standard UVM constructor, for the uvm_component class needs 2 arguments
	// name of our class and the uvm_component parent
	//--------------------------------------------------------------
	function new (string name = "Asyn_FIFO_mon", uvm_component parent = null);
		super.new(name, parent);
		`uvm_info ("Asyn_FIFO_mon", "Inside Constructor!", UVM_HIGH);
	endfunction
	
	// Build Phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		`uvm_info ("Asyn_FIFO_mon", "Inside Build Phase!", UVM_HIGH);
		
		// create the monitor analysis port using new constructor
		monitor_port = new (.name("monitor_port"), .parent(this));
		
		// use the config db get method to get the virtual interface for driver
		// the method return 1 on success and 0 otherwise
		// checking for making sure we can get the virtual interface
		if (!(uvm_config_db #(virtual ASYNFIFO1Signals)::get(this,"*", "intf", intf))) begin
			`uvm_error ("Asyn_FIFO_mon", "Failed to get intf from config db");
		end
	endfunction
	
	// Connect Phase
	function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info("Asyn_FIFO_mon", "Connect Phases!", UVM_HIGH);
	endfunction
	
	// Run Phase
	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		`uvm_info ("Asyn_FIFO_mon", "Inside Run Phase!", UVM_HIGH);
		forever begin
			seq_item = Asyn_FIFO_seq_item::type_id::create("seq_item");
			// wait until all reset are done
			wait (intf.wrst_n);
			wait (intf.rrst_n);		
			@ (posedge intf.wclk or posedge intf.rclk) begin
				// oberseve the write flags through the interface
				seq_item.wfull = intf.wfull;
				seq_item.hfull = intf.hfull;
				seq_item.tfull = intf.tfull;
				seq_item.qfull = intf.qfull;
				// oberseve the read flags through the interface
				seq_item.rempty = intf.rempty;
				seq_item.hempty = intf.hempty;
				seq_item.tempty = intf.tempty;
				seq_item.qempty = intf.qempty;
				if (intf.wclk) begin
					// at the posedge write clock, when write request is high and FIFO is not full
					// observe the write signal and the write data
					if (intf.winc && !intf.wfull) begin
						seq_item.wr_request = intf.winc;
						seq_item.data_in = intf.wdata;
						// Debug: Uncomment if needed
						// `uvm_info ("intf.wdata", $sformatf ("intf.wdata = %d, seq_item.data_in = %d, winc = %d\n", intf.wdata, seq_item.data_in,intf.winc), UVM_MEDIUM);
					end
				end
				if (intf.rclk) begin
					// / at the posedge read clock, when read request is high and FIFO is not full
					// observe the read signal and the read data
					if (intf.rinc && !intf.rempty) begin
						seq_item.rd_request = intf.rinc;
						seq_item.data_out = intf.rdata;
						// Debug: Uncomment if needed
						// `uvm_info ("intf.rdata", $sformatf ("intf.rdata = %d, seq_item.data_out = %d, rinc = %d\n", intf.rdata, seq_item.data_out, intf.rinc), UVM_MEDIUM);
						// seq_item.print();
						
					end
				end
			end
			// send data_in and data_out to the scoreboard
			monitor_port.write (seq_item);
		end
	endtask
	
	
endclass: Asyn_FIFO_mon



//--------------------------------------------------------------
// Agent Class includes: Sequencer, Driver, and Monitor
//--------------------------------------------------------------
class Asyn_FIFO_agent extends uvm_agent;

	// Register to UVM Factory
	`uvm_component_utils(Asyn_FIFO_agent)
	
	// Instantiate sequencer, driver, and monitor since they belong to Agent.
	Asyn_FIFO_seqr seqr;
	Asyn_FIFO_drv drv;
	Asyn_FIFO_mon mon;

	
	//--------------------------------------------------------------
	// Standard UVM constructor, for the uvm_component class needs 2 arguments
	// name of our class and the uvm_component parent
	//--------------------------------------------------------------
	function new (string name = "Asyn_FIFO_agent", uvm_component parent = null);
		super.new(name, parent);
		`uvm_info ("Asyn_FIFO_agent", "Inside Constructor!", UVM_HIGH);
	endfunction
	
	//--------------------------------------------------------------
	// Build Phase
	// Create the driver, monitor and sequencer objects using 
	// UVM build constructor
	//--------------------------------------------------------------
	function void build_phase (uvm_phase phase);
		super.build_phase (phase);
		`uvm_info ("Asyn_FIFO_agent", "Inside Build Phase!", UVM_HIGH);
		drv = Asyn_FIFO_drv::type_id::create("drv", this);
		mon = Asyn_FIFO_mon::type_id::create("mon", this);
		seqr = Asyn_FIFO_seqr::type_id::create("seqr", this);
	endfunction: build_phase
	
	//--------------------------------------------------------------
	// Connect Phase
	// Connect driver and sequencer ports, so the can communicate
	// and transfer data
	//--------------------------------------------------------------
	function void connect_phase (uvm_phase phase);
		super.connect_phase (phase);
		`uvm_info ("Asyn_FIFO_agent", "Inside Connect Phase!", UVM_HIGH);
		drv.seq_item_port.connect(seqr.seq_item_export);
	endfunction: connect_phase
	
	// Run Phase
	task run_phase (uvm_phase phase);
		super.run_phase (phase);
	endtask: run_phase
	
	
endclass: Asyn_FIFO_agent



class Asyn_FIFO_scb extends uvm_scoreboard;

	
	// Register to UVM Factory
	`uvm_component_utils(Asyn_FIFO_scb)
	
	// instantiation for the seq item
	Asyn_FIFO_seq_item transactions [$];
	
	// define the analysis TLM interface port
	// uvm_analysis_imp i.e circule and 2 arguments trans and class where implimentation
	uvm_analysis_imp #(Asyn_FIFO_seq_item, Asyn_FIFO_scb) scoreboard_port;
	
	// tlm_analysis_fifo #(Asyn_FIFO_seq_item) scoreboard_port_fifo;

	Asyn_FIFO_seq_item scb_output; 
	
	//--------------------------------------------------------------
	// Standard UVM constructor, for the uvm_component class needs 2 arguments
	// name of our class and the uvm_component parent
	//--------------------------------------------------------------
	function new (string name = "Asyn_FIFO_scb", uvm_component parent = null);
		super.new(name, parent);
		`uvm_info ("Asyn_FIFO_scb", "Inside Constructor!", UVM_HIGH);
	endfunction
	
	// Build Phase
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		`uvm_info ("Asyn_FIFO_scb", "Inside Build Phase!", UVM_HIGH);
		
	// create the monitor analysis port using new constructor
		scoreboard_port = new ("scoreboard_port", this);
	endfunction
	
	// Connect Phase
	function void connect_phase (uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info("Asyn_FIFO_scb", "Connect Phases!", UVM_HIGH);
	endfunction
	

	virtual function void write (input Asyn_FIFO_seq_item item);
		// empty delay variables
		static int delay_qempty = 0;
		static int delay_hempty = 0;
		static int delay_tempty = 0;
		static int delay_rempty = 0;
		
		// full delay variables
		static int delay_qfull = 0;
		static int delay_hfull = 0;
		static int delay_tfull = 0;
		static int delay_wfull = 0;

		if (item.wr_request) begin
			// put the data to the back of the queue if the write request is high
			transactions.push_back(item);
			// Debug: Uncomment if needed
			// `uvm_info ("Asyn_FIFO_scb", $sformatf ("input = %d\n", item.data_in), UVM_MEDIUM);
		end
			// pop from the front of the queue if the read request is high and the queue is not empty
		if (item.rd_request && (transactions.size()!=0)) begin
			// Debug: Uncomment if needed
			// `uvm_info ("Asyn_FIFO_scb", $sformatf ("output = %d\n", item.data_out), UVM_MEDIUM);
			scb_output = transactions.pop_front();
			// Debug: Uncomment if needed
			// `uvm_info("Asyn_FIFO_scb", $sformatf ("scb_output.data_out= %d\n",scb_output.data_in), UVM_MEDIUM);
			if (item.data_out != scb_output.data_in) begin
				`uvm_error("UNMATCH!", $sformatf ("Data read from FIFO = %d, Data from scoreboard = %d\n",scb_output.data_in, item.data_out));
			end
			else begin
				`uvm_info("MATCH!", $sformatf ("Data read from FIFO = %d, Data from scoreboard = %d\n",scb_output.data_in, item.data_out), UVM_HIGH);
			end

		end

		//--------------------------------------------------------------
		// Check write flags
		//--------------------------------------------------------------
		
		// 1. Full. The full flag is assert 2 cycles after the number of data in the FIFO is 512
		// due to the non-blocking assigment in the RTL and delay from driver to monitor
		if ((transactions.size() == 512 && item.wfull && delay_wfull ==2) || transactions.size() == 514) begin
			`uvm_info("Asyn_FIFO_scb","FIFO is full\n", UVM_MEDIUM);
			delay_wfull = 0;
		end
		else if ((transactions.size() == 512 && !item.wfull && delay_wfull == 2) || transactions.size() == 514) begin
			`uvm_error("Asyn_FIFO_scb", "FIFO expected full but it does not\n");
			delay_wfull = 0;
		end
		// Using delay_wfull variable to keep track of how many cycle before we check the
		// wfull flag and compare with the number of item on the FIFO 
		if (transactions.size() == 512 && delay_wfull < 2 && !item.rd_request )begin
			delay_wfull = delay_wfull + 1;
			// Debug: Uncomment if needed
			// `uvm_info("Asyn_FIFO_scb!", $sformatf ("delay_wfull = %d\n",delay_wfull), UVM_MEDIUM);
		end
		//--------------------------------------------------------------

		// 2. 3/4 Full. The tfull flag is assert 2 cycles after the number of data in the FIFO is 384
		// due to the non-blocking assigment in the RTL and delay from driver to monitor
		if ((transactions.size() == 384 && item.tfull && delay_tfull ==2) || transactions.size() == 386) begin
			`uvm_info("Asyn_FIFO_scb","FIFO is 3/4 full\n", UVM_MEDIUM);
			delay_tfull = 0;
		end
		else if ((transactions.size() == 384 && !item.tfull && delay_tfull == 2) || transactions.size() == 386) begin
			`uvm_error("Asyn_FIFO_scb", "FIFO expected 3/4 full but it does not\n");
			delay_tfull = 0;
		end

		// Using delay_tfull variable to keep track of how many cycle before we check the
		// tfull flag and compare with the number of item on the FIFO 
		if (transactions.size() == 384 && delay_tfull < 2 && !item.rd_request && !item.qempty)begin
			delay_tfull = delay_tfull + 1;
			// Debug: Uncomment if needed
			// `uvm_info("Asyn_FIFO_scb!", $sformatf ("delay_tfull = %d\n",delay_tfull), UVM_MEDIUM);
		end
		//--------------------------------------------------------------

		// 3. 1/2 Full. The hfull flag is assert 2 cycles after the number of data in the FIFO is 256
		// due to the non-blocking assigment in the RTL and delay from driver to monitor
		if ((transactions.size() == 256 && item.hfull && delay_hfull ==2) || transactions.size() == 258) begin
			`uvm_info("Asyn_FIFO_scb","FIFO is 1/2 full\n", UVM_MEDIUM);
			delay_hfull = 0;
		end
		else if ((transactions.size() == 256 && !item.hfull && delay_hfull ==2) || transactions.size() == 258) begin
			`uvm_error("Asyn_FIFO_scb", "FIFO expected 1/2 full but it does not\n");
			delay_hfull = 0;
		end

		// Using delay_hfull variable to keep track of how many cycle before we check the
		// qfull flag and compare with the number of item on the FIFO 
		if (transactions.size() == 256 && delay_hfull < 2 && !item.rd_request && !item.hempty)begin
			delay_hfull = delay_hfull + 1;
			// Debug: Uncomment if needed
			// `uvm_info("Asyn_FIFO_scb!", $sformatf ("delay_hfull = %d\n",delay_hfull), UVM_MEDIUM);
		end
		//--------------------------------------------------------------

		// 4. 1/4 Full. The qfull flag is assert 2 cycles after the number of data in the FIFO is 128
		// due to the non-blocking assigment in the RTL and delay from driver to monitor
		if ((transactions.size() == 128 && item.qfull && delay_qfull ==2) || transactions.size() == 130) begin
			`uvm_info("Asyn_FIFO_scb","FIFO is 1/4 full\n", UVM_MEDIUM);
			delay_qfull = 0;
		end
		else if ((transactions.size() == 128 && !item.qfull && delay_qfull ==2) || transactions.size() == 130) begin
			`uvm_error("Asyn_FIFO_scb", "FIFO expected 1/4 full but it does not\n");
			delay_qfull = 0;
		end
		// Using delay_qfull variable to keep track of how many cycle before we check the
		// qfull flag and compare with the number of item on the FIFO 
		if (transactions.size() == 128 && delay_qfull < 2 && !item.rd_request && !item.tempty)begin
			delay_qfull = delay_qfull + 1;
			// Debug: Uncomment if needed
			// `uvm_info("Asyn_FIFO_scb!", $sformatf ("delay_qfull = %d\n",delay_qfull), UVM_MEDIUM);
		end

		if (item.qfull && item.wr_request) begin
			delay_qfull = 0;
		end

		//--------------------------------------------------------------
		// Check read flags
		//--------------------------------------------------------------

		// 1. Empty. The rempty flag is assert 1 cycle after the number of data in the FIFO is 0
		// due to the non-blocking assigment in the RTL and delay from driver to monitor	
		if (transactions.size()==0 && item.rempty && delay_rempty ==2) begin
			`uvm_info("Asyn_FIFO_scb","FIFO is empty\n", UVM_MEDIUM);
			delay_rempty = 0;
		end
		else if (transactions.size()==0 && !item.rempty  && delay_rempty ==2) begin
			`uvm_error("Asyn_FIFO_scb", "FIFO expected to empty but it does not\n");
			delay_rempty = 0;
		end
		if ((transactions.size() == 0) && delay_rempty < 2) begin
			delay_rempty = delay_rempty + 1;
			// Debug: Uncomment if needed
			// `uvm_info("Asyn_FIFO_scb112!", $sformatf ("delay_rempty = %d\n",delay_rempty), UVM_MEDIUM);

		end

		// reset the delay_rempty when the FIFO is empty and we have the write request
		// due to the delay_rempty is increase last time when we add the delay
		if (item.rempty && item.wr_request) begin
			delay_rempty = 0;
		end
		//--------------------------------------------------------------

		// 2. 3/4 Empty. The tempty flag is assert 2 cycles after the number of data in the FIFO is 128
		// due to the non-blocking assigment in the RTL and delay from driver to monitor
		if (transactions.size()== 128 && item.tempty && delay_tempty ==2) begin
			`uvm_info("Asyn_FIFO_scb","FIFO is 3/4 empty\n", UVM_MEDIUM);
			delay_tempty = 0;
		end
		else if (transactions.size()== 128 && !item.tempty && delay_tempty == 2) begin
			`uvm_error("Asyn_FIFO_scb", "FIFO expected to 3/4 empty but it does not\n");
			delay_tempty = 0;
		end
		if ((transactions.size() == 128) && delay_tempty < 2 && !item.qfull && !item.wr_request)begin
			delay_tempty = delay_tempty + 1;
			// Debug: Uncomment if needed
			// `uvm_info("Asyn_FIFO_scb!", $sformatf ("delay_tempty = %d\n",delay_tempty), UVM_MEDIUM);

		end
		//--------------------------------------------------------------

		// 3. 1/2 Empty.  The hempty flag is assert 2 cycles after the number of data in the FIFO is 256
		// due to the non-blocking assigment in the RTL and delay from driver to monitor
		if (transactions.size()== 256 && item.hempty && delay_hempty ==2) begin
			`uvm_info("Asyn_FIFO_scb","FIFO is 1/2 empty\n", UVM_MEDIUM);
			delay_hempty = 0;
		end
		else if (transactions.size()== 256 && !item.hempty && delay_hempty == 2) begin
			`uvm_error("Asyn_FIFO_scb", "FIFO expected to 1/2 empty but it does not\n");
			delay_hempty = 0;
		end
		if ((transactions.size() == 256) && delay_hempty < 2 && !item.hfull && !item.wr_request)begin
			delay_hempty = delay_hempty + 1;
			// Debug: Uncomment if needed
			// `uvm_info("Asyn_FIFO_scb!", $sformatf ("delay_hempty = %d\n",delay_hempty), UVM_MEDIUM);

		end
		//--------------------------------------------------------------

		// 4. 1/4 Empty.  The qempty flag is assert 2 cycles after the number of data in the FIFO is 384
		// due to the non-blocking assigment in the RTL and delay from driver to monitor
		if (transactions.size()== 384 && item.qempty && delay_qempty == 2) begin
			`uvm_info("Asyn_FIFO_scb","FIFO is 1/4 empty\n", UVM_MEDIUM);
			delay_qempty = 0;
		end
		else if (transactions.size()==384 && !item.qempty && delay_qempty == 2) begin
			`uvm_error("Asyn_FIFO_scb", "FIFO expected to 1/4 empty but it does not\n");
			delay_qempty = 0;
		end
		if ((transactions.size() == 384) && delay_qempty < 2 && !item.tfull && !item.wr_request)begin
			delay_qempty = delay_qempty + 1;
			// Debug: Uncomment if needed
			// `uvm_info("Asyn_FIFO_scb!", $sformatf ("delay_qempty = %d\n",delay_qempty), UVM_MEDIUM);

		end
		//--------------------------------------------------------------
		
	endfunction 
	
endclass


// class Asyn_FIFO_coverage extends uvm_subsriber #(Asyn_FIFO_seq_item)
// endclass

class Asyn_FIFO_coverage extends uvm_subscriber #(Asyn_FIFO_seq_item);
    `uvm_object_utils(Asyn_FIFO_coverage)
    Asyn_FIFO_seq_item seq_item;
    real cov;
    //uvm_analysis_imp #(Asyn_FIFO_seq_item, Asyn_FIFO_coverage) coverage_port;
    // Declare covergroup
    covergroup wdata_winc_rinc;
        coverpoint seq_item.data_in {
            bins zeros = {'h00};
            bins others = {['h01:'hFE]};
            bins ones = {'hFF};
        }
        coverpoint seq_item.wr_request {
            bins full = (1'b1 [*520]);
            bins toggle_wr[] = (1'b0, 1'b1 => 1'b1, 1'b0);
            bins no_wr = (1'b0 [*520]);
            bins wr_on_off = (1'b1 => 1'b0[*3:5]);
        }
        coverpoint seq_item.rd_request {
            bins empty = (1'b1 [*520]);
            bins toggle_rd[] = (1'b0, 1'b1 => 1'b1, 1'b0);
            bins no_rd = (1'b0 [*520]);
            bins rd_on_off = (1'b1 => 1'b0[*3:5]);
        }
    endgroup: wdata_winc_rinc

    function new(string name = "Asyn_FIFO_coverage", uvm_component parent = null);
        super.new(name, parent);
		
        seq_item = Asyn_FIFO_seq_item::type_id::create("Asyn_FIFO_seq_item");
        wdata_winc_rinc = new();
	//coverage_port = new ("coverage_port", this);
    endfunction

    virtual function void write(input Asyn_FIFO_seq_item t);
        `uvm_info(get_type_name(), "Reading data from monitor for coverage", UVM_NONE);
        t.print();
        seq_item = t;
        wdata_winc_rinc.sample();
        cov = wdata_winc_rinc.get_coverage();
        `uvm_info(get_full_name(),$sformatf("Coverage is %d", cov), UVM_NONE)
    endfunction: write
    // Instantiate the covergroup
    //wdata_winc_rinc wdata_winc_rinc;
endclass