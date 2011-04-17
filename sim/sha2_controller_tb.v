//Modified from Johnathan Bromley's code on comp.lang.verilog

`timescale 1ns/1ns

module sha2_controller_tb;

   reg rst = 0;
   reg clk = 0;
   wire [7:0] led;
   wire       line;
   wire       TX;

   //  UART signal generator
   behavioral_UART_tx tx_model(.line(line));

   // Unit Under Test
   sha2_controller UUT(
		       .clk(clk),
		       .btn_north(rst),
		       .RX(line),
		       .TX(TX),
		       .led(led));

   // Test stimulus generator
   initial begin: StimGen
      #10;
      // Use the Tx model to send characters to the UUT:
      tx_model.send("L");
      tx_model.send("1");
      tx_model.send("1");
      tx_model.send("2");
      tx_model.send("3");
      // Idle awhile:
      #20;
      // Send a newline character (LF = 10)
      tx_model.send(10);
   end

   always #10 clk = ~clk;
   
endmodule
