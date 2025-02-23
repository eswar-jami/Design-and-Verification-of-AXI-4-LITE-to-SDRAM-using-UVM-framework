typedef enum {READ_v,WRITE_v} axi_txn_enum;

class axi_m_txn extends uvm_sequence_item;

	parameter DATA_WIDTH = 16;
	parameter ADDR_WIDTH = 32;
    parameter RESPONSE_WIDTH = 2;

	randc logic [ADDR_WIDTH-1:0]     aw_addr;
	randc logic [DATA_WIDTH-1:0]     wdata;
	randc logic [ADDR_WIDTH-1:0]     ar_addr;
	      logic [DATA_WIDTH-1:0]     rdata;
              logic awvalid;
              logic arvalid;
              logic wvalid;
              logic rvalid;
    
    
	rand  axi_txn_enum  type_trans; 
	rand bit  sel;   
	      logic [RESPONSE_WIDTH-1:0] wresp;
	      logic [RESPONSE_WIDTH-1:0] rresp;

    rand int unsigned cycles;

    constraint c{
        cycles <= 20;
    }

    constraint c1 {
   	aw_addr inside {[0:500]};
   	ar_addr inside {[0:500]};
   }


   `uvm_object_utils_begin(axi_m_txn)
      `uvm_field_int  (aw_addr,              UVM_ALL_ON)
      `uvm_field_int  (wdata,              UVM_ALL_ON)
      `uvm_field_int  (ar_addr,              UVM_ALL_ON)
      `uvm_field_int  (rdata,              UVM_ALL_ON)
      `uvm_field_enum (axi_txn_enum, type_trans, UVM_ALL_ON)	
      `uvm_field_int  (cycles,            UVM_ALL_ON)
      `uvm_field_int  (sel,            UVM_ALL_ON)
   `uvm_object_utils_end

	function new(string name="axi_m_txn");
		super.new(name);
	endfunction

endclass
     