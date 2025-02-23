class axi_m_agent extends uvm_agent;

    `uvm_component_utils(axi_m_agent)

    axi_m_driver drv;
    axi_m_monitor mon;
    axi_m_sequencer sqr;

    function new(string name="axi_m_agent",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv=axi_m_driver::type_id::create("drv",this);
        mon=axi_m_monitor::type_id::create("mon",this);
        sqr= axi_m_sequencer::type_id::create("sqr",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
        $display("connection done");
    endfunction

endclass