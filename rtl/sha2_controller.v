//`include "uart.v"

module sha2_controller(
		       clk,
		       btn_north,
		       //btn_south,
		       //btn_east,
		       //btn_west,
		       //led,
		       RX,
		       TX,
		       led
		       );
   
   
   input clk; // The master clock for this module
   //input rst, // Synchronous reset.
   input btn_north;
   //input btn_south;
   //input btn_east;
   //input btn_west;
   
   output reg [7:0] led;
   
   input 	    RX; // Incoming serial line
   output 	    TX; // Outgoing serial line
   wire 	    uart_rx;
   assign uart_rx = RX;
   
   wire 	    rst;
   assign rst = btn_north;

   
   //transmit high tells UART to start transmitting
   reg 		    transmit = 0;
   //8-bit value of data
   reg [7:0] 	    tx_byte;
   
   //goes high when a byte is received
   wire 	    received;
   
   //setto the value of the byte which has just been recoved when recived is raised
   wire [7:0] 	    rx_byte;
   
   //status
   wire 	    is_transmitting;
   wire 	    is_receiving;
   wire 	    recv_error;
   reg [31:0] 	    data_block;

   //text buffers for sha256
   

   
   uart comm_uart (
		   .clk(clk), 
		   .rst(rst), 
		   .rx(uart_rx), 
		   .tx(TX), 
		   .transmit(transmit), 
		   .tx_byte(tx_byte), 
		   .received(received), 
		   .rx_byte(rx_byte), 
		   .is_receiving(is_receiving), 
		   .is_transmitting(is_transmitting), 
		   .recv_error(recv_error));
   
   sha256 inst_sha256 (
		       .clk_i(clk),
		       .rst_i(rst),
		       .text_i(text_i),
		       .text_o(text_o),
		       .cmd_i(cmd_i),
		       .cmd_w_i(cmd_w_i),
		       .cmd_o(cmd_o));

   input_handler inst_input (
			     .clk(clk),
			     .rst(rst),
			     .byte_available(byte_available),
			     .command(command),
			     .data_count(data_count),
			     .buffer(buffer),
			     .ready(ready),
			     .debug(debug));
   
   
   always @(posedge clk) begin
      if (rst) begin
         transmit <= 0;
         led[7:0] <= 16'hFF;
      end 
      else begin
         //do something
         if (received) begin
	    transmit <= 1;
	    tx_byte <= 16'h4A;
	 end
	 else
	   transmit <= 0;
         //<signal> <= <clocked_value>;
      end
   end
   

   
endmodule