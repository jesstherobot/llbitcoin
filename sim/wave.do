# Testbench signals
wave add /sha2_controller_tb/clk
wave add /sha2_controller_tb/rst
wave add -radix hex /sha2_controller_tb/led
wave add /sha2_controller_tb/line
wave add /sha2_controller_tb/TX
# UUT signals
wave add /sha2_controller_tb/UUT/data_request
wave add -radix hex /sha2_controller_tb/UUT/state
wave add -radix hex /sha2_controller_tb/UUT/buffer
wave add -radix hex /sha2_controller_tb/UUT/input_data_buffer
wave add -radix hex /sha2_controller_tb/UUT/output_data_buffer
wave add /sha2_controller_tb/UUT/input_data_count
wave add /sha2_controller_tb/UUT/output_data_count
wave add /sha2_controller_tb/UUT/cmd_o
# Input Handler signals
wave add -radix hex /sha2_controller_tb/UUT/inst_input/r_STATE
# SHA256 signals
wave add /sha2_controller_tb/UUT/inst_sha256/cmd_i
wave add /sha2_controller_tb/UUT/inst_sha256/cmd_w_i
#wave add /sha2_controller_tb/UUT/inst_sha256/cmd_o
wave add -radix hex /sha2_controller_tb/UUT/inst_sha256/text_i
wave add -radix hex /sha2_controller_tb/UUT/inst_sha256/text_o
# UART Signals
wave add /sha2_controller_tb/UUT/comm_uart/rx
wave add /sha2_controller_tb/UUT/comm_uart/tx
wave add /sha2_controller_tb/UUT/comm_uart/transmit
wave add /sha2_controller_tb/UUT/comm_uart/received
wave add -radix hex sha2_controller_tb/UUT/comm_uart/tx_byte
wave add -radix hex /sha2_controller_tb/UUT/comm_uart/rx_byte
wave add /sha2_controller_tb/UUT/comm_uart/is_receiving
wave add /sha2_controller_tb/UUT/comm_uart/is_transmitting
wave add /sha2_controller_tb/UUT/comm_uart/recv_error