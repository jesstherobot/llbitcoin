module input_handler(
		     clk,
		     rst,
		     byte_available,
		     byte_in,
		     data_request,
		     command,
		     data_count,
		     buffer,
		     ready,
		     debug
		     );

   input 		 clk;
   input 		 rst;
   input 		 byte_available;
   input [7:0] 		 byte_in;
   input 		 data_request;
   

   output reg [7:0] 	 command;
   output reg [15:0] 	 data_count;
   output reg [31:0] 	 buffer;
   output reg 		 ready;
   output reg [7:0] 	 debug;



   //STATES
   parameter STATE_IDLE             = 8'h0;
   parameter STATE_READ_FIRST_BYTE  = 8'h1;
   parameter STATE_READ_ID          = 8'h2;
   parameter STATE_READ_CONTROL     = 8'h3;
   parameter STATE_READ_DATA_SIZE   = 8'h4;
   parameter STATE_READ_DATA        = 8'h5;
   parameter STATE_WRITE_DATA = 8'h6;
   
   parameter CHAR_L = 16'h4C;
   parameter CHAR_E = 16'h45;
   parameter CHAR_A = 16'h41;
   parameter CHAR_F = 16'h46;

   parameter CHAR_0 = 16'h30;

   //Registers
   reg [63:0] 		 r_LEAD_ID  = 'b0;
   reg [7:0] 		 r_STATE    = 'b0;
   reg [31:0] 		 r_ID_REG   = 'b0;

   reg 			 r_low_byte   = 0;
   reg [15:0] 		 r_count      = 0;
   reg [2:0] 		 word_count   = 0;
   reg [31:0] 		 data_buffer  = 0;
   

   reg 			 r_prev_byte_available = 0;


   //Wire
   wire 		 pos_edge_byte_available;

   //Assign
   assign pos_edge_byte_available = (byte_available & ~r_prev_byte_available);

   //Synchronous
   always @ (posedge clk) begin
      r_prev_byte_available <= byte_available;
   end

   always @ (posedge clk) begin

      if (rst) begin
         command     <= 8'h0;
         data_count  <= 16'h00;
         buffer      <= 0;
         debug       <= 'b0; 
	 ready <= 0;       
         r_LEAD_ID   <= 'b0;
         r_STATE     <= STATE_IDLE;
         r_ID_REG    <= 'b0;
         r_low_byte  <= 0;

      end // if (rst)
      else begin
         //main state machine goes here
         case (r_STATE)
           STATE_IDLE: begin
              debug[0]        <= 1;
              command         <= 8'h0;
              data_count      <= 16'h00;
              r_ID_REG[31:23] <= 'b0;
              if (pos_edge_byte_available) begin
                 r_STATE     <= STATE_READ_FIRST_BYTE;
                 debug[1]    <= 1;    
              end
           end
           STATE_READ_FIRST_BYTE: begin
              debug[0]        <= 0;
              data_count      <= 16'h00;
              r_low_byte      <= 0;
              if (byte_in == CHAR_L) begin
                 //read the first of byte
                 r_ID_REG[31:24]    <= byte_in;
                 r_STATE            <= STATE_READ_ID;
              end
              else begin
                 r_STATE    <= STATE_IDLE;
              end
           end // case: STATE_READ_FIRST_BYTE
           STATE_READ_ID: begin 
              debug[3]        <= 1;
              if (pos_edge_byte_available) begin
                 case (byte_in)
                   CHAR_E: begin
                      debug[4] <= 1;
                      //set the value
                      r_ID_REG[23:16] <= byte_in;
                      //make sure the top byte
                      if (r_ID_REG[31:24] != CHAR_L) begin
                         r_STATE <= STATE_IDLE;
                      end
                   end
                   CHAR_A: begin
                      debug[4] <= 0;
                      //set the value
                      r_ID_REG[15:7] <= byte_in;
                      if (r_ID_REG[31:24] != CHAR_L ||
                          r_ID_REG[23:16] != CHAR_E) begin
                         r_STATE <= STATE_IDLE;
                      end
                      
                   end
                   CHAR_F: begin
                      debug[4] <= 1;
                      //set the value
                      if (r_ID_REG[31:24] != CHAR_L ||
                          r_ID_REG[23:16] != CHAR_E ||
                          r_ID_REG[15:7]  != CHAR_A) begin
                         //previous values weren't correct
                         r_STATE <= STATE_IDLE;
                      end
                      else begin
                         r_STATE <= STATE_READ_CONTROL;
                      end
                   end // case: CHAR_F
                   default: begin
                      debug[4] <= 0;
                      r_ID_REG    <= 'b0;
                      //didn't find the ID
                      r_STATE <= STATE_READ_FIRST_BYTE;
                   end
                 endcase // case (byte_in)
              end // if (pos_edge_byte_available)
              //for debug only reset the system
              //r_STATE         <= STATE_IDLE;
           end // case: STATE_READ_ID
           STATE_READ_CONTROL: begin
              debug[5]   <=    1;
              if (pos_edge_byte_available) begin
                 if ((byte_in < CHAR_0) || (byte_in > CHAR_0 + 15)) begin
                    r_STATE    <=    STATE_READ_FIRST_BYTE;
                    debug[5]   <=    0;
                 end
                 else begin
                    r_STATE    <=    STATE_READ_DATA_SIZE;
                    command    <=    (byte_in - CHAR_0);
                 end
              end
           end // case: STATE_READ_CONTROL
           STATE_READ_DATA_SIZE: begin
              //read the size
              if (pos_edge_byte_available) begin
                 if ((byte_in < CHAR_0) || (byte_in > CHAR_0 + 15)) begin
                    r_STATE    <=    STATE_READ_FIRST_BYTE;
                    debug[5]   <=    0;
                 end
                 else begin
                    //r_STATE    <=    STATE_READ_DATA_SIZE;
                    command    <=    (byte_in - CHAR_0);
                    if (r_low_byte) begin
                       //low_byte
                       data_count[7:0]    <= (byte_in - CHAR_0);
                       r_low_byte <= 1;
                    end
                    else begin
                       //high byte
                       data_count    <=  data_count[7:0] + (byte_in - CHAR_0);
                       //       r_count       <=  data_count[7:0] + (byte_in - CHAR_0); 
                       r_STATE <= STATE_READ_DATA;
                    end // else: !if(r_low_byte)
                 end // else: !if((byte_in < CHAR_0) || (byte_in > CHAR_0 + 15))
              end // if (pos_edge_byte_available)
           end // case: STATE_READ_DATA_SIZE
           STATE_READ_DATA : begin
              if (pos_edge_byte_available) begin
                 if ((byte_in < CHAR_0) || (byte_in > CHAR_0 + 15)) begin
                    r_STATE    <=    STATE_READ_FIRST_BYTE;
                 end
                 else begin
                    debug[5]   <=    ~debug[5];
		    if (word_count == 4) begin
		       word_count <= 0;
		       r_count <= r_count + 1;
		       r_STATE <= STATE_WRITE_DATA;
		    end
		    else begin
		       data_buffer <= data_buffer << 4;
		       data_buffer[3:0] <= (byte_in - CHAR_0);
		       r_STATE <= STATE_READ_DATA;
		    end
                    //reading data                        
                 end // else: !if((byte_in < CHAR_0) || (byte_in > CHAR_0 + 15))
              end // if (pos_edge_byte_available)
           end // case: STATE_READ_DATA
	   STATE_WRITE_DATA : begin
	      if (data_request) begin
		 buffer <= data_buffer;
		 ready <= 1;
		 if (r_count == data_count) begin
		    ready <= 0;
		    r_STATE <= STATE_IDLE;
		 end
		 else begin
		    ready <= 0;
		    r_STATE <= STATE_READ_DATA;
		 end
	      end // if (data_request)
	   end // case: STATE_WRITE_DATA
	   default: begin
              command         <= 8'h0;
              r_STATE         <= STATE_IDLE;
	   end
         endcase // case (r_STATE)
         
      end // else: !if(rst)
   end // always @ (posedge clk)
endmodule // input_handler