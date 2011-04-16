
`timescale 1ns/10ps

module sha2_controller_tb;
   
   reg btn_north;
   reg clk;
   wire [7:0] led;
   reg 	      RX;
   wire       TX;

   sha2_controller DUT (
			.clk(clk),
			.btn_north(btn_north),
			.RX(RX),
			.TX(TX),
			.led(led),	 
			);

   parameter PERIOD = 2;
   initial begin
      clk = 1'b0;
      rst = 1'b0;
      
      
   end

   /*
    initial begin
    RX = 1'b0;
    btn_north = 1'b0;
    
    #2;
    btn_north = 1'b1;
    #2; 
    btn_north = 1'b0;
end
    */

   always #5 clk = ~clk;
   
endmodule