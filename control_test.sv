`ifndef control_test
`define control_test


class control_test extends uvm_test;
   
    `uvm_component_utils(control_test)

   //axi_m_sequencer sqr;
   //sdram_cntrl_sequence ;
     axi_m_sequence sq_1,sq_2;
    sdram_cntrl_env envr;


    function new(string name="control_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        envr=sdram_cntrl_env::type_id::create("envr",this);
        sq_1=axi_m_sequence::type_id::create("sq_1");
        sq_2=axi_m_sequence::type_id::create("sq_2");
    endfunction

    virtual task run_phase(uvm_phase phase);

    phase.raise_objection(this);
    fork
      sq_2.start(envr.agnt.sqr);
      sq_1.start(envr.s_agnt.sdram_sqr);
    join
     //#1000; 
    phase.drop_objection(this);

    endtask

endclass

`endif
