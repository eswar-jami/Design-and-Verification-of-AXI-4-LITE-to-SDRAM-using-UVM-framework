class axi_s_agent extends uvm_agent;

    `uvm_component_utils(axi_s_agent)

    axi4lite_slave_mem      s_drv;
    axi_s_sequencer   s_sqr;

    function new(string name="axi_s_agent",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        s_drv = axi4lite_slave_mem::type_id::create("s_drv",this);
        s_sqr = axi_s_sequencer::type_id::create("s_sqr",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //s_drv.seq_item_port.connect(s_sqr.seq_item_export);
        $display("connection done in slave agent");
    endfunction
endclass