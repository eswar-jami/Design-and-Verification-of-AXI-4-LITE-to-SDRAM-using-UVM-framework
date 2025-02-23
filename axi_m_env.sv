class axi_m_env extends uvm_env;

    `uvm_component_utils(axi_m_env)
     
     axi_m_agent agnt;
     axi_s_agent s_agnt;


    axi_m_monitor mon;
    axi_scoreboard sb;

    function new(string name="axi_m_env",uvm_component parent=null);
        super.new(name,parent);
    endfunction
 
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agnt=axi_m_agent::type_id::create("agent",this);
        s_agnt=axi_s_agent::type_id::create("s_agnt",this);
    endfunction

   /* function void connect_phase(uvm_phase phase);
        super.build_phase(phase);
        mon.mon_ap.connect(sb.sb_imp);
    endfunction*/


    function void end_of_elaboration_phase(uvm_phase phase);
     super.end_of_elaboration_phase(phase);
     uvm_top.print_topology();
     endfunction

endclass