/*****************************************************************
Module name: ASYN_FIFO1_Interface.sv
Authours: Team 1
		1. Suraksha Yelawala Swamygowda
		2. Sneha Ramaiah 
		3. Ngan Ho
		4. Yogeshwar Gajanan Landge
		5. Mohamed Gnedi
Date: 	May 14th, 2024
Descriptions: 	The interface use for declare the port list of the FIFO and their direction.
******************************************************************/
interface ASYNFIFO1Signals #(parameter DSIZE =8);
       
    logic [DSIZE-1:0] rdata;
	bit   wfull,hfull,qfull,tfull;
	bit rempty,hempty,qempty,tempty;
	logic [DSIZE-1:0] wdata;
	bit winc, wrst_n,rinc, rrst_n;
	logic  rclk,wclk;
    int unique_id;



// Declare all ports derection
modport asynfifo1( 
					input wdata,                            // data input write to the FIFO from sender
					input winc, wclk, wrst_n,               // write request, write clock and write reset
					input rinc, rclk, rrst_n,               // read request, read clock and read reset
					output rdata,                           // data output read from FIFO to reciever
					output wfull,hfull,qfull,tfull,         // full, half,quarter and 3/4th full flags
					output rempty,hempty,qempty,tempty      // empty half,quarter and 3/4th  empty flags
	           ); 

endinterface
