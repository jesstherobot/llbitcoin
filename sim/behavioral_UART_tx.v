//Modifed from Johnathan Bromley's code on comp.lang.verilog

`timescale 1ns/1ns

module behavioral_UART_tx //UART spoofer
  #(parameter bit_time = 104000) // nanoseconds
   (output reg line);

   initial
     line = 1'b1; // line idles true

   task send(input [7:0] data);
      reg [9:0] uart_frame;
      begin
	 // construct the whole frame with start and stop bit
	 // STOP data START
	 uart_frame = {1'b1, data, 1'b0};
	 repeat (10) // number of bit-symbols to send
	   begin
	      line = uart_frame[0]; // drive line to correct level
	      uart_frame = uart_frame >> 1; // prepare next bit
	      #(bit_time); // hold output for one bit time
	   end
      end
   endtask

endmodule