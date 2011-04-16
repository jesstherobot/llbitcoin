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

   // UART signals
   //transmit high tells UART to start transmitting
   reg 		    transmit = 0;
   //8-bit value of data
   reg [7:0] 	    tx_byte;
   //goes high when a byte is received
   wire 	    received;
   //set to the value of the byte which has just been recoved when recived is raised
   wire [7:0] 	    rx_byte;
   //status
   wire 	    is_transmitting;
   wire 	    is_receiving;
   wire 	    recv_error;

   // Input Handler signals
   wire 	    ready;
   reg 		    data_request = 0;
   
   // SHA256 ssignals
   wire [31:0] 	    text_i;
   reg 	    cmd_w_i = 0;
   reg [2:0] 	    cmd_i = 0;
   wire [3:0] 	    cmd_o;
   reg 		    sha_state = 0;
   
   
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
			     .byte_available(received),
			     .byte_in(rx_byte),
			     .data_request(data_request),
			     .command(command),
			     .data_count(data_count),
			     .buffer(text_i),
			     .ready(ready),
			     .debug(debug));
   
   
   always @(posedge clk) begin
      if (rst) begin
         transmit <= 0;
         led[7:0] <= 16'hFF;
      end 
      else begin
	 if (~cmd_o[3] && ~sha_state) begin
	    data_request <= 1;
	    sha_state <= 1;
	 end
	 if (ready) begin
	    data_request <= 0;
	    cmd_w_i <= 1;
	    cmd_i <= 3'b010;
	 end
	 if (~cmd_o[3] && sha_state) begin
	    cmd_w_i <= 1;
	    cmd_i <= 3'b110;
	    sha_state <= 0;
	          end
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