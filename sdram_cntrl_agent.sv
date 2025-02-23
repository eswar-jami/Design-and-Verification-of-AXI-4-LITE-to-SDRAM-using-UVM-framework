class sdram_cntrl_agent extends uvm_agent;

    `uvm_component_utils(sdram_cntrl_agent)

    sdram_cntrl_driver      sdram_drv;
    sdram_cntrl_sequencer   sdram_sqr;
    sdram_cntrl_monitor      mon;

    function new(string name="sram_cntrl_agent",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
         mon=sdram_cntrl_monitor::type_id::create("mon",this);
        sdram_drv = sdram_cntrl_driver::type_id::create("sdram_drv",this);
        sdram_sqr = sdram_cntrl_sequencer::type_id::create("sdram_sqr",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //write sequencer driver connection
       //sdram_drv.seq_item_port.connect(sdram_sqr.seq_item_export);
    endfunction
endclass