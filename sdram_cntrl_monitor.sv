class sdram_cntrl_monitor extends uvm_monitor;
    `uvm_component_utils(sdram_cntrl_monitor)

     virtual sdr_intf svif;

    uvm_analysis_port #(sdram_cntrl_txn) sd_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        sd_port=new("sd_port",this);
     //   sd_txn = sdram_cntrl_txn::type_id::create("sd_txn", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
          `uvm_info(get_full_name(),"this is the monitor of sdram controller ",UVM_NONE)

         if (!uvm_config_db#(virtual sdr_intf)::get(this, "", "sdram_interface", svif))
             `uvm_fatal("NOVIF", "Virtual interface not set for sdram_cntrl_monitor")
    endfunction

    task run_phase(uvm_phase phase);
       fork
        sd_monitor_write();
        sd_monitor_read();          
       join    
    endtask

  task sd_monitor_write();
      sdram_cntrl_txn sd_txn;
      forever begin
        sd_txn = sdram_cntrl_txn::type_id::create("sd_txn");
        @(negedge svif.sys_R_Wn) begin
            if((svif.w_en)) begin
            sd_txn.sys_R_Wn=0;
            sd_txn.sys_Data_Drive = svif.sys_Data_Drive;
            sd_txn.sys_adrs_drive = svif.sys_adrs_drive; 
        end
        end
    `uvm_info("","-----------------------------------------------------------------------------------------------------------------",UVM_NONE)
    `uvm_info("",$sformatf("write captured in sdram_monitor : ADDR = %0h , Data = %0h ",sd_txn.sys_adrs_drive,sd_txn.sys_Data_Drive),UVM_NONE)
     sd_port.write(sd_txn);           
      end
  endtask

  task sd_monitor_read();
      sdram_cntrl_txn sd_txn;
      forever begin
     sd_txn = sdram_cntrl_txn::type_id::create("sd_txn");
    @(posedge svif.sys_R_Wn)begin
     if(svif.r_en) begin
     sd_txn.sys_R_Wn=1;
     sd_txn.sys_Data_Drive = svif.sys_Data_Drive;
     sd_txn.sys_adrs_drive = svif.sys_adrs_drive; 
    end
    end
    `uvm_info("","------------------------------------------------------------------------------------------------------------------",UVM_NONE)
     `uvm_info("",$sformatf("Read captured in sdram_monitor : ADDR = %0h , Data = %0h ",sd_txn.sys_adrs_drive,sd_txn.sys_Data_Drive),UVM_NONE)
     sd_port.write(sd_txn);           
      end
  endtask
    
    
endclass
