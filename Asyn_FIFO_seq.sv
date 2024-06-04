
/*****************************************************************
Module name: Asyn_FIFO_seq_item.sv
Authours: Team 1
		1. Suraksha Yelawala Swamygowda
		2. Sneha Ramaiah 
		3. Ngan Ho
		4. Yogeshwar Gajanan Landge
		5. Mohamed Gnedi
Date: 	June 2nd, 2024
Descriptions: 	The sequene creates the stimus and drives them to the driver via sequener.
******************************************************************/
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "Asyn_FIFO_seq_item.sv"

class Asyn_FIFO_seq extends uvm_sequence;

	// Register to UVM Factory
	`uvm_object_utils(Asyn_FIFO_seq)
	
	// create an handle for the sequene item we created
	Asyn_FIFO_seq_item seq_item;
	int count = 0;
	
	// Standard UVM constructor
	function new (string name = "Asyn_FIFO_seq");
		super.new(name);
	endfunction
	
	task body ();
		// allocate a new object of the same type
		seq_item = Asyn_FIFO_seq_item::type_id::create("Asyn_FIFO_seq_item");
	
		//assert the write reset
		repeat (2) begin
			// starting randomize seq_item
			start_item(seq_item);
			// randomizing the seq_item with reset assert low
			// using void () for ignoring the status bit by casting the result to void
			void' (seq_item.randomize() with {wrst_n==0;});
			// finishing randomize seq_item
			finish_item(seq_item);
		end
		
		//assert the read reset
		repeat (2) begin
			// starting randomize seq_item
			start_item(seq_item);
			// randomizing the seq_item with reset assert low
			// using void () for ignoring the status bit by casting the result to void
			void' (seq_item.randomize() with {rrst_n==0;});
			// finishing randomize seq_item
			finish_item(seq_item);
		end


		//------------------------------------------------------
		// Write to FIFO - Checking 1/4 Full
		//------------------------------------------------------
		// Writing to FIFO
		repeat (128) begin
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 1;});
			finish_item(seq_item); 
		end
		
		// Stop write to FIFO	
		start_item(seq_item);
		void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		finish_item(seq_item); 
		// Delay 2 cycles waiting for the 1/4 full flag assert before continue next action
		// due to delay between driver and monitor, and non-blocking assigment at the RTL 
		#4;

		// ------------------------------------------------------
		// Write to FIFO - Checking 1/2 Full
		//------------------------------------------------------
		// Writing to FIFO
		repeat (128) begin
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 1;});
			finish_item(seq_item); 
		end
		
		// Stop write to FIFO	
		start_item(seq_item);
		void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		finish_item(seq_item); 
		// Delay 4 cycles waiting for the 1/2 full flag assert before continue next action
		// due to delay between driver and monito, and non-blocking assigment at the RTL 
		#4;

		//------------------------------------------------------
		// Write to FIFO - Checking 3/4 Full
		//------------------------------------------------------
		// Writing to FIFO
		repeat (128) begin
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 1;});
			finish_item(seq_item); 
		end
		
		// Stop write to FIFO	
		start_item(seq_item);
		void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		finish_item(seq_item); 
		// Delay 4 cycles waiting for the 3/4 full flag assert before continue next action
		// due to delay between driver and monito, and non-blocking assigment at the RTL 
		#4;


		//------------------------------------------------------
		// Write to FIFO - Checking Full
		//------------------------------------------------------
		// Writing to FIFO
		repeat (128) begin
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 1;});
			finish_item(seq_item); 
		end
		
		// Stop write to FIFO	
		start_item(seq_item);
		void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		finish_item(seq_item); 
		// Delay 4 cycles waiting for the full flag assert before continue next action
		// due to delay between driver and monito, and non-blocking assigment at the RTL 
		#4;

		//------------------------------------------------------
		// Write to FIFO when it full
		//------------------------------------------------------
		// Writing to FIFO
		repeat (2) begin
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 1;});
			finish_item(seq_item); 
		end
		
		// Stop write to FIFO	
		start_item(seq_item);
		void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		finish_item(seq_item); 
		// Delay 4 cycles waiting for the full flag assert before continue next action
		// due to delay between driver and monito, and non-blocking assigment at the RTL 
		#4;


		//------------------------------------------------------
		// Read from FIFO - Checking 3/4 Empty
		//------------------------------------------------------
		// Read from FIFO
		repeat (128) begin
			#6;
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 0;});
			// seq_item.print();
			finish_item(seq_item);

			// Stop read from FIFO
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
			// seq_item.print();
			finish_item(seq_item);
		end
		#4;

		//------------------------------------------------------
		// Read from FIFO - Checking 1/2 Empty
		//------------------------------------------------------
		// Read from FIFO
		repeat (128) begin
			#6;
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 0;});
			// seq_item.print();
			finish_item(seq_item);

			// Stop read from FIFO
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
			// seq_item.print();
			finish_item(seq_item);
		end
		#4;

		//------------------------------------------------------
		// Read from FIFO - Checking 1/4 Empty
		//------------------------------------------------------
		// Read from FIFO
		repeat (128) begin
			#6;
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 0;});
			// seq_item.print();
			finish_item(seq_item);

			// Stop read from FIFO
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
			// seq_item.print();
			finish_item(seq_item);
		end
		#4;

		//------------------------------------------------------
		// Read from FIFO - Checking Empty
		//------------------------------------------------------
		// Read from FIFO
		repeat (128) begin
			#6;
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 0;});
			// seq_item.print();
			finish_item(seq_item);

			// Stop read from FIFO
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
			// seq_item.print();
			finish_item(seq_item);
		end
		#4;
		//------------------------------------------------------
		// Read from FIFO when it empty
		//------------------------------------------------------
		repeat (2) begin
			#6;
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 0;});
			// seq_item.print();
			finish_item(seq_item);

			// Stop read from FIFO
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
			// seq_item.print();
			finish_item(seq_item);
		end


		//------------------------------------------------------
		// Write, follow by read with random data
		//------------------------------------------------------
		repeat (10) begin
			// Write to FIFO
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 1;});
			finish_item(seq_item); 

			// Stop write to FIFO	
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
			finish_item(seq_item); 

			#6;
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 0;});
			// seq_item.print();
			finish_item(seq_item);

			// Stop read from FIFO
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
			// seq_item.print();
			finish_item(seq_item);
		end

		//------------------------------------------------------
		// Write and read at the same time with random data
		//------------------------------------------------------
		// Write some data to the FIFO first
		repeat (20) begin
		// Write to FIFO
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 1;});
			finish_item(seq_item); 
		// Stop write to FIFO	
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
			finish_item(seq_item); 
		end
		// Write and read at the same time
			#6;
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 1;});
			finish_item(seq_item);

		// Stop write and read
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
			finish_item(seq_item); 

		
		//------------------------------------------------------
		// Random read and write with random data
		//----------------------------------------------------
		repeat (20) begin
			// use some delay in case we have the read, so we make sure we have wait for 4 cycles 
			// between 2 reads
			#6;
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1;});
			finish_item(seq_item); 

			// Stop write and read FIFO	for making sure if we have read or write, it only assert 1 cycle
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
			finish_item(seq_item); 
		end


		//------------------------------------------------------
		// Insert the error for all flags by writing until FIFO is full
		// and read 128 data from FIFO without 4 idle cycles
		// after that deassert read and putting some delay
		// after continue the same sequence until read all data from FIFO
		//------------------------------------------------------

		// Writing to FIFO full
		/*repeat (512) begin
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 1;});
			finish_item(seq_item); 
		end*/
		
		// Stop write to FIFO	
		start_item(seq_item);
		void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		finish_item(seq_item); 

		// Reading from FIFO until 3/4 empty without 4 idle cycles. This will generate error
		repeat (128) begin
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 0;});
			finish_item(seq_item);
		end
		// Stop reading from FIFO
		start_item(seq_item);
		void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		finish_item(seq_item); 

		// delay before next read
		#4;

		// Reading from FIFO until 1/2 empty without 4 idle cycles. This will generate error
		repeat (128) begin
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 0;});
			finish_item(seq_item);
		end
		// Stop reading from FIFO
		start_item(seq_item);
		void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		finish_item(seq_item); 

		// delay before next read
		#4;

		// Reading from FIFO until 1/4 empty without 4 idle cycles. This will generate error
		repeat (128) begin
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 0;});
			finish_item(seq_item);
		end
		// Stop reading from FIFO
		start_item(seq_item);
		void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		finish_item(seq_item); 

		// delay before next read
		#4;

		// Reading from FIFO until empty without 4 idle cycles. This will generate error
		repeat (128) begin
			start_item(seq_item);
			void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 0;});
			finish_item(seq_item);
		end
		// Stop reading from FIFO
		start_item(seq_item);
		void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		finish_item(seq_item); 

		// delay before next read
		#4;










		// // test write
		// start_item(seq_item);
		// void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 1; data_in == 100;});
		// // `uvm_info ("in Asyn_FIFO_seq", "Before write finish", UVM_MEDIUM);
		// seq_item.print();
		// finish_item(seq_item); 

		// start_item(seq_item);
		// void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 1; data_in == 200;});
		// // `uvm_info ("in Asyn_FIFO_seq", "Before write finish", UVM_MEDIUM);
		// seq_item.print();
		// finish_item(seq_item); 

		// start_item(seq_item);
		// void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 1; data_in == 10;});
		// // `uvm_info ("in Asyn_FIFO_seq", "Before write finish", UVM_MEDIUM);
		// seq_item.print();
		// finish_item(seq_item); 

		// // start_item(seq_item);
		// // void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 1; data_in == 20;});
		// // // `uvm_info ("in Asyn_FIFO_seq", "Before write finish", UVM_MEDIUM);
		// // seq_item.print();
		// // finish_item(seq_item); 

		// // start_item(seq_item);
		// // void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 1; data_in == 30;});
		// // // `uvm_info ("in Asyn_FIFO_seq", "Before write finish", UVM_MEDIUM);
		// // seq_item.print();
		// // finish_item(seq_item); 
		
		// start_item(seq_item);
		// void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		// // `uvm_info ("in Asyn_FIFO_seq", "Before write finish", UVM_MEDIUM);
		// seq_item.print();
		// finish_item(seq_item); 
		
		//------------------------------------------------------
		// Reading
		//------------------------------------------------------
		
		// #6;
		// start_item(seq_item);
		// void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 0;});
		// // `uvm_info ("in Asyn_FIFO_seq", "Before read finish", UVM_MEDIUM);
		// seq_item.print();
		// finish_item(seq_item);
		
		// start_item(seq_item);
		// void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		// // `uvm_info ("in Asyn_FIFO_seq", "Before read finish", UVM_MEDIUM);
		// seq_item.print();
		// finish_item(seq_item);

		// #6;
		// start_item(seq_item);
		// void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 0;});
		// // `uvm_info ("in Asyn_FIFO_seq", "Before read finish", UVM_MEDIUM);
		// seq_item.print();
		// finish_item(seq_item);

		// // // #2;
		// start_item(seq_item);
		// void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		// // `uvm_info ("in Asyn_FIFO_seq", "Before read finish", UVM_MEDIUM);
		// seq_item.print();
		// finish_item(seq_item);

		// #6;
		// start_item(seq_item);
		// void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 1; wr_request == 0;});
		// // `uvm_info ("in Asyn_FIFO_seq", "Before read finish", UVM_MEDIUM);
		// seq_item.print();
		// finish_item(seq_item);

		// // #2;
		// start_item(seq_item);
		// void' (seq_item.randomize() with {rrst_n==1; wrst_n==1; rd_request == 0; wr_request == 0;});
		// // `uvm_info ("in Asyn_FIFO_seq", "Before read finish", UVM_MEDIUM);
		// seq_item.print();
		// finish_item(seq_item);



		//------------------------------------------------------
		// Will be use for Milestone-5
		//------------------------------------------------------
		//deassert the reset
		// repeat (10) begin
		// 	// starting randomize seq_item
		// 	start_item(seq_item);
		// 	// randomizing the seq_item with reset assert high
		// 	// using void () for ignoring the status bit by casting the result to void
		// 	void' (seq_item.randomize() with {wrst_n==1; rrst_n == 1;});
		// 	// printing the seq_item
		// 	seq_item.print();
		// 	count++;
		// 	$display("count = %d\n", count);
		// //	#4;
		// 	// finishing randomize seq_item
		// 	finish_item(seq_item);
		// end 
	endtask: body
	
endclass: Asyn_FIFO_seq