module input_handler_tb;
   //make a reset that pulses once
   reg rst = 0;
   reg clk = 0;

   //input handler specific registers
   reg byte_available 	= 0;
   reg [7:0] byte_in   	= 0;
   reg 	     data_request = 0;
   
   wire [7:0] command;
   wire [15:0] data_count;
   wire [255:0] buffer;
   wire 	ready;
   wire [7:0] 	debug;
   
   input_handler ih (
		     .clk(clk),
		     .rst(rst),
		     .byte_available(byte_available),
		     .byte_in(byte_in),
		     .data_request(data_request),
		     .command(command),
		     .data_count(data_count),
		     .buffer(buffer),
		     .ready(ready),
		     .debug(debug));

   initial begin
 //     $dumpfile("design.vcd");
 //     $dumpvars(0, input_handler_tb);
 //     $dumpvars(0, ih);

      #	1 		rst = 1;
      #	5 		rst = 0;
      #	10		
	//SEND ID as ASCII 'L'
	byte_in = 16'h4C;
      byte_available = 1;
      #	14		
	byte_available = 0;

      //Send command '1' as ASCII '1'
      #	20
	byte_in = 16'h31;
      byte_available = 1;
      #	14
	byte_available = 0;
      //Send data size 0x12 as ASCII '1', '0'
/* -----\/----- EXCLUDED -----\/-----
      #	30		
	byte_in = 16'h31;
      byte_available = 1;
      #	34		
	byte_available = 0;
      #	40	
	byte_in = 16'h30;
      byte_available = 1;
      #	44		
	byte_available = 0;
 -----/\----- EXCLUDED -----/\----- */
      //Send data 0x0123456789ABCDEF
      #	50	
	byte_in = 16'h30;
      byte_available = 1;
      #	54		
	byte_available = 0;
      #	60	
	byte_in = 16'h31;
      byte_available = 1;
      #	64		
	byte_available = 0;
      #	70	
	byte_in = 16'h32;
      byte_available = 1;
      #	74		
	byte_available = 0;
      #	80	
	byte_in = 16'h33;
      byte_available = 1;
      #	84		
	byte_available = 0;
      #	90	
	byte_in = 16'h34;
      byte_available = 1;
      #	94		
	byte_available = 0;
      #	100	
	byte_in = 16'h35;
      byte_available = 1;
      #	104		
	byte_available = 0;
      #	110	
	byte_in = 16'h36;
      byte_available = 1;
      #	114		
	byte_available = 0;
      #	120	
	byte_in = 16'h37;
      byte_available = 1;
      #	124		
	byte_available = 0;
      #	130	
	byte_in = 16'h38;
      byte_available = 1;
      #	134		
	byte_available = 0;
      #	140	
	byte_in = 16'h39;
      byte_available = 1;
      #	144		
	byte_available = 0;
      #	150	
	byte_in = 16'h41;
      byte_available = 1;
      #	154		
	byte_available = 0;
      #	160	
	byte_in = 16'h42;
      byte_available = 1;
      #	164		
	byte_available = 0;
      #	170	
	byte_in = 16'h43;
      byte_available = 1;
      #	174		
	byte_available = 0;
      #	180	
	byte_in = 16'h44;
      byte_available = 1;
      #	184		
	byte_available = 0;
      #	190	
	byte_in = 16'h45;
      byte_available = 1;
      #	194		
	byte_available = 0;
      #	200	
	byte_in = 16'h46;
      byte_available = 1;
      #	214		
	byte_available = 0;
      

      //finished
      #	220		
	byte_in = 16'h30;
      byte_available = 1;
      #	224
	byte_available = 0;

      # 	230  	$finish;

   end

   always #4 clk = ~clk;

   initial $monitor ("%t: byte_in = %h, count = %d, ready = %h, buffer = %h", $time, byte_in, data_count, ready, buffer);
endmodule

