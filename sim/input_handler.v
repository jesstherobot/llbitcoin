module input_handler(
    clk,
    rst,
    byte_available,
    byte,
    command,
    data_count,
    buffer,
    ready,
);

input clk;
input rst;
input byte_available;
input [7:0]byte;


output reg [3:0] command;
output reg [15:0] data_count;
output reg [BUFFER_SIZE:0] buffer;
output reg ready;



//STATES
parameter BUFFER_SIZE			 = 255;
parameter STATE_IDLE             = 8'h0;
parameter STATE_READ_ID  		 = 8'h1;
parameter STATE_READ_CONTROL     = 8'h2;
parameter STATE_READ_DATA_SIZE   = 8'h3;
parameter STATE_READ_DATA        = 8'h4;

parameter CHAR_L = 16'h4C;

parameter CHAR_0 = 16'h30;

//Registers
reg [7:0]  r_STATE    = 'b0;

reg r_low_byte          = 0;
reg [15:0] r_count      = 0;

reg r_prev_byte_available = 0;


//Wire
wire pos_edge_byte_available;

//Assign
assign pos_edge_byte_available = (byte_available & ~r_prev_byte_available);

//Synchronous
always @ (posedge clk) begin
    r_prev_byte_available <= byte_available;
end

always @ (posedge clk) begin

    if (rst) begin
        command     <= 'h0;
        data_count  <= 16'h00;
        buffer      <= 0;
        r_STATE     <= STATE_IDLE;
        r_low_byte  <= 0;
		ready		<= 0;

    end
    else begin
        //main state machine goes here
        case (r_STATE)
            STATE_IDLE: begin
                command         <= 8'h0;
                data_count      <= 16'h00;
				ready			<= 0;
                if (pos_edge_byte_available) begin
                    r_STATE     <= STATE_READ_ID;
                end
            end
            STATE_READ_ID: begin
                data_count      <= 16'h00;
                r_low_byte      <= 0;
                if (byte == CHAR_L) begin
                    //read the first of byte
                    r_STATE     <= STATE_READ_CONTROL;
                end
                else begin
                    r_STATE 	<= STATE_IDLE;
                end
			end
            STATE_READ_CONTROL: begin
                
                if (pos_edge_byte_available) begin
                    if ((byte < CHAR_0) || (byte > CHAR_0 + 15)) begin
                        r_STATE    <=    STATE_READ_ID;
                    end
                    else begin
                        r_STATE    <=    STATE_READ_DATA_SIZE;
                        command    <=    (byte - CHAR_0);
                    end
                end
            end
            STATE_READ_DATA_SIZE: begin
                //read the size
                if (pos_edge_byte_available) begin
                    if ((byte < CHAR_0) || (byte > CHAR_0 + 15)) begin
                        r_STATE    <=    STATE_READ_ID;
                    end
                    else begin
                        if (!r_low_byte) begin
                            //low_byte
                            data_count[7:0]    <= (byte - CHAR_0);
                            r_low_byte 			<= 1;
                        end
                        else begin
                            //high byte
                            data_count    <=  (data_count[7:0] << 4) + (byte - CHAR_0);
                            r_count       <=  (data_count[7:0] << 4)+ (byte - CHAR_0); 
                            r_STATE <= STATE_READ_DATA;
                        end
                    end                
                end
            end
            STATE_READ_DATA : begin
                if (pos_edge_byte_available) begin
                    if ((byte < CHAR_0) || (byte > CHAR_0 + 15)) begin
                        r_STATE    <=    STATE_READ_ID;
                    end
                    else begin
                        //reading data
//NEED TO READ DATA INTO THE BUFFER                          
						buffer <= {buffer[251 : 0], byte[3:0]};
						if (r_count == 1) begin
							//reached the end of the data
							r_STATE <= STATE_IDLE;
							ready <= 1;
						end

						r_count <= (r_count - 1);
                    end
                end
            end
            default: begin
                command         <= 8'h0;
                r_STATE         <= STATE_IDLE;
            end
        endcase
        
    end
end
endmodule
