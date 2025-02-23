class base_test extends uvm_test;
   
    `uvm_component_utils(base_test)

   //axi_m_sequencer sqr;
    axi_m_sequence sq_1,sq_2;
    axi_m_env env;


    function new(string name="base_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
      //  sqcr=axi_m_sequencer::type_id::create("sqcr",this);
        env=axi_m_env::type_id::create("env",this);
        sq_1=axi_m_sequence::type_id::create("sq_1");
        sq_2=axi_m_sequence::type_id::create("sq_2");
    endfunction

    virtual task run_phase(uvm_phase phase);

    phase.raise_objection(this);
      fork
        sq_1.start(env.agnt.sqr);
        sq_2.start(env.s_agnt.s_sqr);
       join
    phase.drop_objection(this);

    endtask

endclass