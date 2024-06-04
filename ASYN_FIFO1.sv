       
/*****************************************************************
Module name: ASYN_FIFIO1.sv
Authours: Team 1
		1. Suraksha Yelawala Swamygowda
		2. Sneha Ramaiah 
		3. Ngan Ho
		4. Yogeshwar Gajanan Landge
		5. Mohamed Gnedi
Date: April 29th, 2024
Descriptions: 	ASYN_FIFO1 include both FIFO Memory and Controller.
				Controller is the FIFO controller which is the most importance module in the Asynchoronous FIFO design.
				The controller will do all the convertions between binary and gray code, synchronize all the pointers between read and write clock,
				generate all FIFO flags: Empty, Full, Half Full, Half Empty, etc.
				Memory acts like the storage for the senders to write the data to the FIFO when FIFO is not full
				and reciever read data from FIFO when FIFO is not empty.
******************************************************************/


`include "Asyn_FIFO1_Interface.sv"


/**************************Module for synchronizing read pointer to wclk clock***********************************************/
module sync_r2w #(parameter ADDRSIZE = 9)
	(output logic [ADDRSIZE:0] wq2_rptr,
	input [ADDRSIZE:0] rptr,
	input wclk, wrst_n);

	logic [ADDRSIZE:0] wq1_rptr;

	always_ff @(posedge wclk or negedge wrst_n)
		if (!wrst_n) {wq2_rptr,wq1_rptr} <= 0;
		else {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};
endmodule




/**************************Module for synchronizing write pointer to rclk clock***********************************************/
module sync_w2r #(parameter ADDRSIZE = 9)
	(output logic [ADDRSIZE:0] rq2_wptr,
	input [ADDRSIZE:0] wptr,
	input rclk, rrst_n);

	logic [ADDRSIZE:0] rq1_wptr;

	always_ff @(posedge rclk or negedge rrst_n)
		if (!rrst_n) {rq2_wptr,rq1_wptr} <= 0;
		else {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};
endmodule





/**************************Module for FIFO Memory***********************************************/
module fifomem #(parameter DATA_WIDTH = 8, ADDRSIZE = 9) (
  input wire wclk, rclk,
  input wire wr_en, wfull, rempty,
  input wire [DATA_WIDTH-1:0] wdata,
  input wire [ADDRSIZE-1:0] waddr, raddr,
  output reg [DATA_WIDTH-1:0] rdata
);
  // Parameters
  parameter READ_IDLE_CYCLES = 4;
  parameter DEPTH = 1 << ADDRSIZE;

  // Internal Signals
  reg [DATA_WIDTH-1:0] fifo[0:DEPTH-1];   // FIFO memory array
  int cycle_counter1 = READ_IDLE_CYCLES; // Cycle counter for read idle cycles
  reg first_read = 1;      
  logic [2:0] counter = 0;               // Flag for the first read

  always_comb begin
   rdata = fifo[raddr];
//    $display ("%t, In memory read , raddr = %d\n", $time, raddr);
  end
	

  always_ff @(posedge wclk)
    if (wr_en && !wfull)
      fifo[waddr] <= wdata;

endmodule




/**************************Module to covert gray to binary***********************************************/
module Gray_to_Binary #(parameter ADDRSIZE = 9);

	function automatic  logic [ADDRSIZE:0] gray_to_binary;

		input  logic [ADDRSIZE:0] gray_value;
			   logic [ADDRSIZE:0] binary_value;

		binary_value[ADDRSIZE] = gray_value[ADDRSIZE];

		for (int i = ADDRSIZE-1; i >= 0; i--)
			binary_value[i] = binary_value[i+1] ^ gray_value[i];

		return binary_value;

	endfunction

endmodule




/**************************Module for rempty and raddr and rptr***********************************************/
module rptr_empty #(parameter ADDRSIZE = 9)
	(output logic rempty, hempty, qempty, tempty,
	output [ADDRSIZE-1:0] raddr,
	output logic [ADDRSIZE :0] rptr,
	input [ADDRSIZE :0] rq2_wptr,
	input rinc, rclk, rrst_n);

	logic [ADDRSIZE:0] rbin;
	logic [ADDRSIZE:0] rgraynext, rbinnext;
	logic [ADDRSIZE:0] rgraynext_bin, rq2_wptr_bin;
	logic rempty_val, hempty_val, qempty_val, tempty_val;
	logic [ADDRSIZE:0] difference;
	int signed diff_decimal;
        logic [2:0] cycle_counter; // Counter for the 4-clock cycle delay
	//Calculating Depth Value
	localparam DEPTH1 = 1 << ADDRSIZE;

	//Instantiating gray to binary converter module
	Gray_to_Binary #(ADDRSIZE) gb();

	//-------------------
	// GRAYSTYLE2 pointer
	//-------------------
	always_ff @(posedge rclk or negedge rrst_n) begin
          if (!rrst_n) begin
            {rbin, rptr} <= '0;
            //cycle_counter <= 3'd0;
          end else begin
            {rbin, rptr} <= {rbinnext, rgraynext};
        end
      end

       always_ff @(posedge rclk or negedge rrst_n) begin
            if (!rrst_n) begin
             cycle_counter <= 3'd0;
          end else begin
          if (cycle_counter == 3'd4 && rinc && !rempty) begin
            cycle_counter <= 3'd0; // Reset counter after 4 cycles
          end else if (cycle_counter != 3'd4) begin
            cycle_counter <= cycle_counter + 3'd1;
		  end 
        end
      end

       

	// Memory read-address pointer (okay to use binary to address memory)
	assign raddr = rbin[ADDRSIZE-1:0]; 
	assign rbinnext = rbin + (rinc & ~rempty & (cycle_counter == 3'd4)); // increment the read pointer next only when rinc is asserted and it is not empty
	assign rgraynext = (rbinnext >> 1) ^ rbinnext; // conversion of read pointer next to gray code

	//----------------------------------------------------------
	// Logic for Half Empty Signal
	//----------------------------------------------------------

	// Convert Gray code pointers to binary for rgraynext and rq2_wptr
	assign rgraynext_bin = gb.gray_to_binary(rgraynext);
	assign rq2_wptr_bin = gb.gray_to_binary(rq2_wptr);

	always_comb begin
		//Calculate the difference between rgraynext and rq2_wptr
		difference = rq2_wptr_bin - rgraynext_bin; 

		// Convert the difference to decimal
		diff_decimal = difference;

		//Check the difference between rgraynext and rq2_wptr is equal to Depth/2, Depth/4 and Depth*3/4 and MSB is not equal
		if ((diff_decimal == ((DEPTH1)/2)) && (rgraynext_bin[ADDRSIZE] != rq2_wptr_bin[ADDRSIZE])) 
			hempty_val = 1'b1;
		else if ((diff_decimal == ((DEPTH1*3)/4)) && (rgraynext_bin[ADDRSIZE] != rq2_wptr_bin[ADDRSIZE])) 
			qempty_val = 1'b1;
		else if ((diff_decimal == ((DEPTH1)/4)) && (rgraynext_bin[ADDRSIZE] != rq2_wptr_bin[ADDRSIZE])) 
			tempty_val = 1'b1;
		else begin
			hempty_val = 1'b0;
			qempty_val = 1'b0;
			tempty_val = 1'b0;
		end
	end

	//---------------------------------------------------------------
	// FIFO empty when the next rptr == synchronized wptr or on reset
	//---------------------------------------------------------------
	assign rempty_val = (rgraynext == rq2_wptr);

	always_ff @(posedge rclk or negedge rrst_n) begin 
		if (!rrst_n) begin
			rempty <= 1'b1;
			hempty <= 1'b0;
			qempty <= 1'b0;
			tempty <= 1'b0;
		end else begin
			rempty <= rempty_val;
			hempty <= hempty_val;
			qempty <= qempty_val;
			tempty <= tempty_val;
		end
	end 


endmodule


/**************************Module for wfull and waddr and wptr***********************************************/
module wptr_full #(parameter ADDRSIZE = 9)
	(output logic wfull,hfull,qfull,tfull,
	output logic [ADDRSIZE-1:0] waddr,
	output logic [ADDRSIZE :0] wptr,
	input [ADDRSIZE :0] wq2_rptr,
	input winc, wclk, wrst_n);

	logic [ADDRSIZE:0] wbin;
	logic [ADDRSIZE:0] wgraynext, wbinnext;
        logic [ADDRSIZE:0] wgraynext_bin, wq2_rptr_bin;
	logic wfull_val,hfull_val,qfull_val,tfull_val;
        logic [ADDRSIZE:0] difference;
        int signed diff_decimal;

        //Caluclating the Depth Value
        localparam DEPTH2 = 1<<ADDRSIZE;
       
        //Instantiating gray to binary converter module
        Gray_to_Binary #(ADDRSIZE) gb();

	// GRAYSTYLE2 pointer
	always_ff @(posedge wclk or negedge wrst_n)
		if (!wrst_n) {wbin, wptr} <= 0;
		else {wbin, wptr} <= {wbinnext, wgraynext};
	// Memory write-address pointer (okay to use binary to address memory)
       
	assign waddr = wbin[ADDRSIZE-1:0];
	assign wbinnext = wbin + (winc & ~wfull); // increment the write pointer next only when rinc is asserterd and it is not full
	assign wgraynext = (wbinnext>>1) ^ wbinnext; //coveration of read pointer next to gray code

        //----------------------------------------------------------
	// Logic for Half Full Signal
	//----------------------------------------------------------

         // Convert Gray code pointers to binary
        assign wgraynext_bin = gb.gray_to_binary(wptr);
        assign wq2_rptr_bin  = gb.gray_to_binary(wq2_rptr);


         always_comb begin

       // Calculate the difference between wgraynext and wq2_rptr
           difference = wgraynext_bin - wq2_rptr_bin;   

       // Convert the difference to decimal
            diff_decimal = difference;
       // end 

       //Check the diffrence between wgraynext and wq2_rptr is equal to Depth/2,Depth/4 and Depth*3/4 and MSB is equal
              if ((diff_decimal == ((DEPTH2)/2)) && (wgraynext_bin[ADDRSIZE] == wq2_rptr_bin[ADDRSIZE])) 
                hfull_val = 1'b1;
              else if ((diff_decimal == ((DEPTH2)/4)) && (wgraynext_bin[ADDRSIZE] == wq2_rptr_bin[ADDRSIZE])) 
                qfull_val = 1'b1;
              else if ((diff_decimal == ((DEPTH2*3)/4)) && (wgraynext_bin[ADDRSIZE] == wq2_rptr_bin[ADDRSIZE])) 
                tfull_val = 1'b1;
            else begin hfull_val = 1'b0;qfull_val = 1'b0;tfull_val = 1'b0;end
         end

	//------------------------------------------------------------------
	// Simplified version of the three necessary full-tests:
	// assign wfull_val=((wgnext[ADDRSIZE] !=wq2_rptr[ADDRSIZE] ) &&
	// (wgnext[ADDRSIZE-1] !=wq2_rptr[ADDRSIZE-1]) &&
	// (wgnext[ADDRSIZE-2:0]==wq2_rptr[ADDRSIZE-2:0]));
	//------------------------------------------------------------------
	assign wfull_val = (wgraynext=={~wq2_rptr[ADDRSIZE:ADDRSIZE-1],wq2_rptr[ADDRSIZE-2:0]});

       
	always_ff @(posedge wclk or negedge wrst_n)
		if (!wrst_n) begin wfull <= 1'b0;hfull <=1'b0;qfull <=1'b0;tfull <=1'b0; end
		else begin wfull <= wfull_val; hfull <= hfull_val; qfull <= qfull_val;tfull <= tfull_val;end
endmodule






/**************************TOP MODULE***********************************************/
module aysn_fifo1 #(parameter DSIZE = 8, parameter ASIZE = 9)             
	(ASYNFIFO1Signals.asynfifo1 intf);
        
	logic [ASIZE-1:0] waddr, raddr;
	logic [ASIZE:0] wptr, rptr, wq2_rptr, rq2_wptr;

//Instantiating synchronize read pomiter to wclk module
sync_r2w #(ASIZE)sync_r2w (.wq2_rptr(wq2_rptr), .rptr(rptr),
	.wclk(intf.wclk), .wrst_n(intf.wrst_n));

//Instantiating synchronize write pomiter to rclk module
sync_w2r #(ASIZE)sync_w2r (.rq2_wptr(rq2_wptr), .wptr(wptr),
	.rclk(intf.rclk), .rrst_n(intf.rrst_n));

//Instantiating FIFO Memory module
fifomem #(DSIZE, ASIZE) fifomem (
    .wclk(intf.wclk),.rclk(intf.rclk), 
    .wr_en(intf.winc),.wfull(intf.wfull), .rempty(intf.rempty),
    .wdata(intf.wdata), .rdata(intf.rdata),
    .waddr(waddr), .raddr(raddr));
  
//Instantiating rptr_empty module
rptr_empty #(ASIZE) rptr_empty
	(.rempty(intf.rempty),.hempty(intf.hempty),.qempty(intf.qempty),.tempty(intf.tempty),
	.raddr(raddr),
	.rptr(rptr), .rq2_wptr(rq2_wptr),
	.rinc(intf.rinc), .rclk(intf.rclk),
	.rrst_n(intf.rrst_n));

//Instantiating wptr_full module
wptr_full #(ASIZE) wptr_full
	(.wfull(intf.wfull), .waddr(waddr),.hfull(intf.hfull),.qfull(intf.qfull),.tfull(intf.tfull),
	.wptr(wptr), .wq2_rptr(wq2_rptr),
	.winc(intf.winc), .wclk(intf.wclk),
	.wrst_n(intf.wrst_n));

endmodule








