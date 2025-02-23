class axi_m_sequencer extends uvm_sequencer#(axi_m_txn);

	`uvm_component_utils(axi_m_sequencer)

    function new(string name="axi_m_sequencer",uvm_component parent = null);
		super.new(name,parent);
	endfunction

    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("","this is build_phase of sequencer",UVM_NONE);
    endfunction

endclass
