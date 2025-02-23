`include "uvm_macros.svh"
import uvm_pkg::*;


`include "sdr_top.v"
// `include "sdram_control.v"
`include "sdr_para.v"
`include "interface_sdram.sv"
`include "axi_interface.sv"



typedef class control_test;
typedef class sdram_cntrl_sequencer;
typedef class sdram_cntrl_txn;
typedef class sdram_cntrl_monitor;
typedef class sdram_cntrl_env;
typedef class sdram_cntrl_driver;
typedef class sdram_cntrl_agent;
typedef class axi_m_sequencer;
typedef class axi_m_sequence;
typedef class axi_m_txn;
typedef class axi_m_monitor;
typedef class axi_m_agent;
typedef class axi_m_driver;
typedef class axi4lite_slave_mem;
typedef class axi_s_agent;
typedef class axi_s_sequencer;
typedef class scoreboard;


`include "axi_m_sequencer.sv"
`include "axi_m_sequence.sv"
`include "axi_m_txn.sv"
`include "axi_m_monitor.sv"
`include "axi_m_agent.sv"
`include "axi_m_driver.sv"
`include "axi_s_driver_1.sv"
`include "axi_s_agent.sv"
`include "axi_s_sequencer.sv"

`include "control_test.sv"
`include "sdram_cntrl_driver.sv"
`include "sdram_cntrl_env.sv"
`include "sdram_cntrl_monitor.sv"
`include "sdram_cntrl_sequencer.sv"
`include "sdram_cntrl_txn.sv"
`include "sdram_cntrl_agent.sv"
`include "scb.sv"

`include "sdram_mem.v"




module top_tb;


 wire sys_R_Wn;      // read/write#
wire sys_ADSn;      // address strobe
wire sys_DLY_100US; // sdr power and clock stable for 100 us
wire sys_CLK;       // sdr clock
wire sys_RESET;     // reset signal
wire sys_REF_REQ;   // sdr auto-refresh request
wire sys_REF_ACK;   // sdr auto-refresh acknowledge
wire [23:1] sys_A;  // address bus
wire [15:0] sys_D;  // data bus
wire sys_D_VALID;   // data valid
wire sys_CYC_END;   // end of current cycle
wire sys_INIT_DONE; // initialization completed, ready for normal operation

wire [3:0] sdr_DQ;  // sdr data
wire [11:0] sdr_A;  // sdr address
wire [1:0] sdr_BA;  // sdr bank address
wire sdr_CKE;       // sdr clock enable
wire sdr_CSn;       // sdr chip select
wire sdr_RASn;      // sdr row address
wire sdr_CASn;      // sdr column select
wire sdr_WEn;       // sdr write enable
wire sdr_DQM;       // sdr write data mask


	sdr_intf svif();
    axi_interface vif();

always #5 vif.clk = ~vif.clk;


	     parameter SDR_A_WIDTH =12;
         parameter SDR_BA_WIDTH =2 ;
         parameter RA_MSB=22;
         parameter CA_LSB=11;

initial 
begin
	run_test("control_test");
end

initial
    begin
    uvm_config_db#(virtual axi_interface)::set(null, "*", "interface_vif",vif);
   
	uvm_config_db#(virtual sdr_intf)::set(null,"*", "sdram_interface", svif);
end


initial
    begin
        vif.clk=0;

        vif.resetn=0;


        #300 vif.resetn = 1;

        #10000 $finish;
    end






sdr_top UUT(
  .sys_R_Wn(svif.sys_R_Wn),      // read/write#
  .sys_ADSn(svif.sys_ADSn),      // address strobe
  .sys_DLY_100US(svif.sys_DLY_100US), // sdr power and clock stable for 100 us
  .sys_CLK(svif.sys_CLK),       // sdr clock
  .sys_RESET(svif.sys_RESET),     // reset signal
  .sys_REF_REQ(svif.sys_REF_REQ),   // sdr auto-refresh request
  .sys_REF_ACK(sys_REF_ACK),   // sdr auto-refresh acknowledge
  .sys_A(svif.sys_A),         // address bus
  .sys_Data(svif.sys_Data),         // data bus
  .sys_D_VALID(sys_D_VALID),   // data valid
  .sys_CYC_END(svif.sys_CYC_END),   // end of current cycle
  .sys_INIT_DONE(svif.sys_INIT_DONE), // initialization completed, ready for normal operation

  .sdr_DQ(sdr_DQ),        // sdr data
  .sdr_A(sdr_A),         // sdr address
  .sdr_BA(sdr_BA),        // sdr bank address
  .sdr_CKE(sdr_CKE),       // sdr clock enable
  .sdr_CSn(sdr_CSn),       // sdr chip select
  .sdr_RASn(sdr_RASn),      // sdr row address
  .sdr_CASn(sdr_CASn),      // sdr column select
  .sdr_WEn(sdr_WEn),       // sdr write enable
  .sdr_DQM(sdr_DQM)        // sdr write data mask
);

assign svif.sdr_DQ=sdr_DQ;

sdr SDR_SDRAM(
  .sdr_DQ(sdr_DQ),
  .sdr_A(sdr_A),
  .sdr_BA(sdr_BA),
  .sdr_CK(svif.sys_CLK),
  .sdr_CKE(sdr_CKE),
  .sdr_CSn(sdr_CSn),       // sdr chip select
  .sdr_RASn(sdr_RASn),      // sdr row address
  .sdr_CASn(sdr_CASn),      // sdr column select
  .sdr_WEn(sdr_WEn),       // sdr write enable
  .sdr_DQM(sdr_DQM)
);





endmodule 
