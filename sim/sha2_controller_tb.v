`timescale 1ns/1ns

module sha2_controller_tb;

   reg rst = 0;
   reg clk = 0;
   wire [7:0] led;
   wire       line;
   wire       TX;
   
   // And any other signals you need for your DUT
   // such as clock, reset, data-bus...

   // And any clock generators, etc...

   // Here's the UART signal generator...
   behavioral_UART_tx tx_model(.line(line));

   // and here's your device-under-test...
   sha2_controller UUT(
		       .clk(clk),
		       .btn_north(rst),
		       .RX(line),
		       .TX(TX),
		       .led(led));

   // and here's the test stimulus generator:
   initial begin: StimGen
      // Hang around for a while...
      #10;
      // Use the Tx model to send a few characters to the DUT:
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
