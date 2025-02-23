class sdram_cntrl_env extends uvm_env;

    `uvm_component_utils(sdram_cntrl_env)

    scoreboard scb;
     
     sdram_cntrl_agent s_agnt;
     axi_m_agent agnt;
     axi_s_agent sl_agnt;
     //axi_m_monitor a_mon;
     //sdram_cntrl_driver  s_drv;
    

    function new(string name="sdram_cntrl_env",uvm_component parent=null);
        super.new(name,parent);
    endfunction
 
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        s_agnt=sdram_cntrl_agent::type_id::create("s_agnt",this);
        agnt=axi_m_agent::type_id::create("agnt",this);
        sl_agnt=axi_s_agent::type_id::create("sl_agnt",this);
        scb=scoreboard::type_id::create("scb",this);

        //a_mon=axi_m_monitor::type_id::create("a_mon",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agnt.mon.mon_ap.connect(s_agnt.sdram_drv.imp_txn);
        s_agnt.sdram_drv.stoa_read.connect(sl_agnt.s_drv.s_ap);
        s_agnt.mon.sd_port.connect(scb.analysis_imp_sdram);
        agnt.mon.mon_ap.connect(scb.analysis_imp_axi);

    endfunction


    function void end_of_elaboration_phase(uvm_phase phase);
     super.end_of_elaboration_phase(phase);
     uvm_top.print_topology();
     endfunction

endclass