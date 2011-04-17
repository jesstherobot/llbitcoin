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
   
   output reg [7:0] led = 8'hFF;
   
   input 	    RX; // Incoming serial line
   output 	    TX; // Outgoing serial line
   wire 	    uart_rx;
   assign uart_rx = RX;
   
   wire 	    rst;
   assign rst = btn_north;

   // STATES
   parameter STATE_IDLE = 8'h0;
   parameter STATE_INPUT_DATA = 8'h1;
   parameter STATE_WAIT_0 = 8'h2;
   parameter STATE_WAIT_1 = 8'h3;
   parameter STATE_READ_0 = 8'h4;
   parameter STATE_READ_1 = 8'h5;
   
   
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
   wire [7:0] 	    command;
   wire [15:0] 	    data_count;
   wire [255:0]     buffer;
   
   wire [7:0] 	    debug;
   
   // SHA256 ssignals
   reg [31:0] 	    text_i = 0;
   wire [31:0] 	    text_o;
   reg 		    cmd_w_i = 0;
   reg [2:0] 	    cmd_i = 0;
   wire [3:0] 	    cmd_o;
   reg 		    sha_state = 0;
   
   // Top level signals
   reg [255:0] 	    input_data_buffer = 0;
   reg [3:0] 	    input_data_count = 8;
   reg [255:0] 	    output_data_buffer = 0;
   reg [3:0] 	    output_data_count = 10;
   reg [7:0] 	    state = 0;
   reg [2:0] 	    sha_count = 7;
   
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
			     .buffer(buffer),
			     .ready(ready),
			     .debug(debug));
   
   
   always @(posedge clk) begin
      if (rst) begin
         transmit <= 0;
         led[7:0] <= 16'hFF;
      end
      else begin
	 case (state)
	   STATE_IDLE: begin //0
	      input_data_count <= 8;
	      data_request <= 1;
	      sha_count <= 7;
	      if (ready) begin
		 input_data_buffer <= buffer;
		 data_request <= 0;
		 cmd_w_i <= 1;
		 cmd_i <= 3'b010;
		 state <= STATE_INPUT_DATA;
	      end
	      else state <= STATE_IDLE;
	   end // case: STATE_IDLE
	   STATE_INPUT_DATA: begin //1
	      cmd_w_i <= 0;
	      if (input_data_count == 0) state <= STATE_WAIT_0;
	      else begin
		 text_i <= input_data_buffer[255:224];
	       	 input_data_buffer <= input_data_buffer << 32;
		 input_data_count <= input_data_count - 1;
		 cmd_w_i <= 0;
		 state <= STATE_INPUT_DATA;
	      end
	   end
	   STATE_WAIT_0: begin //2
	      if (~cmd_o[3]) begin
		 cmd_w_i <= 1;
		 cmd_i <= 3'b110;
		 state <= STATE_WAIT_1;
	      end
	      else begin
		 state <= STATE_WAIT_0;
	      end
	   end // case: STATE_WAIT_0
	   STATE_WAIT_1: begin //3
	      cmd_w_i <= 0;
	      sha_count <= sha_count - 1;
	      if (sha_count == 0) begin
		 if (~cmd_o[3]) begin
		    cmd_w_i <= 1;
		    cmd_i <= 3'b001;
		    state <= STATE_READ_0;
		 end
		 else begin
		    sha_count <= 7;
		    state <= STATE_WAIT_1;
		 end
	      end
	      else state <= STATE_WAIT_1;
	   end
	   STATE_READ_0: begin //4
	      cmd_w_i <= 0;
	      state <= STATE_READ_1;
	      // clock tick; core doesn't react quickly enough
	   end
	   STATE_READ_1: begin //5
	      if (output_data_count == 0) state <= STATE_IDLE;
	      else begin
		 output_data_buffer[31:0] <= text_o;
		 output_data_buffer[255:32] <= output_data_buffer[223:0];
		 output_data_count <= output_data_count - 1;
		 state <= STATE_READ_1;
	      end
	   end
	 endcase // case (state)
	 if (received) begin
	    transmit <= 1;
	    tx_byte <= rx_byte;
	 end
	 else
	   transmit <= 0;
	 //<signal> <= <clocked_value>;
      end // else: !if(rst)
   end // always @ (posedge clk)



endmodule // sha2_controller