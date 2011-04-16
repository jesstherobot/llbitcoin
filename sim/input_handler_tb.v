module input_handler_tb;
   //make a reset that pulses once
   reg rst = 0;
   reg clk = 0;

   //input handler specific registers
   reg byte_available 	= 0;
   reg [7:0] byte			= 0;
   wire [3:0] command;
   wire [15:0] data_count;
   wire [255:0] buffer;
   wire 	ready;

   input_handler ih (
		     .clk(clk),
		     .rst(rst),
		     .byte_available(byte_available),
		     .byte(byte),
		     .command(command),
		     .data_count(data_count),
		     .buffer(buffer),
		     .ready(ready));

   initial begin
      $dumpfile("design.vcd");
      $dumpvars(0, input_handler_tb);
      $dumpvars(0, ih);

      #	1 		rst = 1;
      #	5 		rst = 0;
      #	10		
	//SEND ID as ASCII 'L'
	byte = 16'h4C;
      byte_available = 1;
      #	14		
	byte_available = 0;

      //Send command '1' as ASCII '1'
      #	20
	byte = 16'h31;
      byte_available = 1;
      #	14
	byte_available = 0;
      //Send data size 0x12 as ASCII '1', '0'
      #	30		
	byte = 16'h31;
      byte_available = 1;
      #	34		
	byte_available = 0;
      #	40	
	byte = 16'h30;
      byte_available = 1;
      #	44		
	byte_available = 0;
      //Send data 0x0123456789ABCDEF
      #	50	
	byte = 16'h30;
      byte_available = 1;
      #	54		
	byte_available = 0;
      #	60	
	byte = 16'h31;
      byte_available = 1;
      #	64		
	byte_available = 0;
      #	70	
	byte = 16'h32;
      byte_available = 1;
      #	74		
	byte_available = 0;
      #	80	
	byte = 16'h33;
      byte_available = 1;
      #	84		
	byte_available = 0;
      #	90	
	byte = 16'h34;
      byte_available = 1;
      #	94		
	byte_available = 0;
      #	100	
	byte = 16'h35;
      byte_available = 1;
      #	104		
	byte_available = 0;
      #	110	
	byte = 16'h36;
      byte_available = 1;
      #	114		
	byte_available = 0;
      #	120	
	byte = 16'h37;
      byte_available = 1;
      #	124		
	byte_available = 0;
      #	130	
	byte = 16'h38;
      byte_available = 1;
      #	134		
	byte_available = 0;
      #	140	
	byte = 16'h39;
      byte_available = 1;
      #	144		
	byte_available = 0;
      #	150	
	byte = 16'h3A;
      byte_available = 1;
      #	154		
	byte_available = 0;
      #	160	
	byte = 16'h3B;
      byte_available = 1;
      #	164		
	byte_available = 0;
      #	170	
	byte = 16'h3C;
      byte_available = 1;
      #	174		
	byte_available = 0;
      #	180	
	byte = 16'h3D;
      byte_available = 1;
      #	184		
	byte_available = 0;
      #	190	
	byte = 16'h3E;
      byte_available = 1;
      #	194		
	byte_available = 0;
      #	200	
	byte = 16'h3F;
      byte_available = 1;
      #	214		
	byte_available = 0;
      

      //finished
      #	220		
	byte = 16'h30;
      byte_available = 1;
      #	224
	byte_available = 0;

      # 	230  	$finish;

   end

   always #4 clk = ~clk;

   initial $monitor ("%t: byte = %h, count = %d, ready = %h, buffer = %h", $time, byte, data_count, ready, buffer);
endmodule

