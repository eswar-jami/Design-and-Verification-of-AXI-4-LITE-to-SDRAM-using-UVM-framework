
class sdram_cntrl_sequencer extends uvm_sequencer#(sdram_cntrl_txn);

	`uvm_component_utils(sdram_cntrl_sequencer)

    function new(string name="sdram_cntrl_sequencer",uvm_component parent = null);
		super.new(name,parent);
	endfunction

    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("","this is build_phase of sequencer",UVM_NONE);
    endfunction

endclass