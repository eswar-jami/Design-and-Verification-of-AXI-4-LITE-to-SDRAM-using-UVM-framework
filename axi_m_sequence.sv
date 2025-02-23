
class axi_m_sequence extends uvm_sequence#(axi_m_txn);

	`uvm_object_utils(axi_m_sequence)
     axi_m_txn txn;

	//int no_of_trans = 3;
	bit [31:0] addr,data;
   // bit trans_type;

	function new(string name="axi_m_sequence");
		super.new(name);
	endfunction

	task body();
         data=#5 'hABCD;
		repeat(5) begin
			$display("entered loop");
			addr=addr+'h8;			
			data=data+'h8;
		   txn=axi_m_txn::type_id::create("txn");
		   start_item(txn);

		   assert(txn.randomize() with {aw_addr == addr;
		    	                        wdata == data;
		    	                        type_trans==WRITE_v ;} );

		  //  txn.print();
		   finish_item(txn);

            #300;

		   start_item(txn);

		    assert(txn.randomize() with {ar_addr == addr;
		    	                        type_trans == READ_v;} );

		    //ar_addr == txn.aw_addr;
		   // txn.print();
		    
		   finish_item(txn);
		   #500;
           //get_response(txn);
           $display("exited loop");
		end

	endtask

endclass 