class sdram_cntrl_sequence extends uvm_sequence#(sdram_cntrl_txn);

	`uvm_object_utils(sdram_cntrl_sequence)
         sdram_cntrl_txn txn;

	
	function new(string name="sdram_cntrl_sequence");
		super.new(name);
	endfunction

	task body();
       
        txn=sdram_cntrl_txn::type_id::create("txn");

	endtask

endclass 