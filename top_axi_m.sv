`include "uvm_macros.svh"
import uvm_pkg::*;


`include "axi_interface.sv"

typedef class axi_m_sequencer;
typedef class axi_m_sequence;
typedef class axi_m_txn;
typedef class axi_m_monitor;
typedef class axi_m_agent;
typedef class axi_m_driver;
typedef class axi_m_env;
typedef class base_test;
typedef class axi_s_sequencer; 
typedef class axi_s_agent;
typedef class axi4lite_slave_mem;
typedef class axi_scoreboard;




`include "axi_m_sequencer.sv"
`include "axi_m_sequence.sv"
`include "axi_s_sequencer.sv"
`include "axi_m_txn.sv"
`include "axi_m_monitor.sv"
`include "axi_m_agent.sv"
`include "axi_s_agent.sv"
`include "axi_m_driver.sv"
`include "axi_s_driver_1.sv"
`include "axi_m_env.sv"
`include "axi_scoreboard.sv"
`include "base_test.sv"




module top;

 axi_interface vif();

    always #5 vif.clk = ~vif.clk;
     
	initial begin
		run_test("base_test");
	end


	initial
	begin
		uvm_config_db#(virtual axi_interface)::set(null, "*", "interface_vif",vif);
	end


	initial
	begin
		vif.clk=0;
		vif.resetn=0;
		#30 vif.resetn = 1;

		#1000 $finish;
	end

endmodule : top
