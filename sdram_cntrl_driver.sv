// `include "sdr_para.v"

class sdram_cntrl_driver extends uvm_component;

    parameter clock_time = 10;
    parameter reset_time = 100;
   parameter sys_CLK_period = tCK;

    `uvm_component_utils(sdram_cntrl_driver)

    virtual sdr_intf svif;
    virtual axi_interface vif;
    axi_m_txn tx;
    bit [3:0]temp[4];
    int i;
    uvm_analysis_imp#(axi_m_txn,sdram_cntrl_driver) imp_txn;
    uvm_analysis_port#(bit [15:0]) stoa_read;
  

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        imp_txn=new("imp_txn",this);
        stoa_read=new("stoa_read",this);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual sdr_intf)::get(this, "", "sdram_interface", svif)) begin
            `uvm_fatal("NOVIF", "Sdram Virtual interface not set for sdram_cntrl_driver")
        end

        if (!uvm_config_db#(virtual axi_interface)::get(this, "", "interface_vif", vif)) begin
            `uvm_fatal("NOVIF", "axi Virtual interface not set for sdram_cntrl_driver") end
    endfunction
    

 function void write(axi_m_txn txn);
    `uvm_info(get_full_name(), "SDRAM_Driver_packet inside write implementation", UVM_NONE)
  
      if (txn.type_trans == WRITE_v) begin
        fork begin 
         @(negedge svif.sys_CLK);
          svif.sys_Data_Enable = 1'b1;
           write_data(txn.aw_addr, txn.wdata);
      //  `uvm_info(get_full_name(), $sformatf("Updated sys_A: %0h, sys_Data_Drive: %0h, sys_Data_Enable: %0b", svif.sys_A, svif.sys_Data_Drive, svif.sys_Data_Enable), UVM_NONE)

        `uvm_info(get_full_name(), $sformatf("Received transaction: %s", txn.sprint()), UVM_NONE) 
         end 

        join_none
        
    end else if (txn.type_trans == READ_v) begin
        `uvm_info(get_full_name(),"inside read transaction of sdram _ controller driver ",UVM_NONE);
        fork begin
             @(negedge svif.sys_CLK);
               svif.sys_Data_Enable = 1'b0;
               read(txn.ar_addr,txn); 
         //   `uvm_info(get_full_name(), $sformatf("Updated sys_A: %0h, sys_Data_Drive: %0h, sys_Data_Enable: %0b", svif.sys_A, svif.sys_Data_Drive, svif.sys_Data_Enable), UVM_NONE)
            
            `uvm_info(get_full_name(), $sformatf("Received transaction: %s", txn.sprint()), UVM_NONE)
        end
          
        join_none
      
    end

    // Print updated values

endfunction


    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "This is the run_phase of sdram_cntrl_driver", UVM_NONE)
         fork
           $display("inside run_phase");  
        
          begin
             $display("inside loop1");  
           forever #(sys_CLK_period/2) svif.sys_CLK_int <= ~svif.sys_CLK_int;
           end
           begin
             $display("inside loop2");  
             forever#1 svif.sys_CLK = svif.sys_CLK_en & svif.sys_CLK_int; 
           end
        

         begin
         $display("inside loop3");
         svif.sys_R_Wn    <= #1 1'b1;
         svif.sys_ADSn    <= #1 1'b1;
         svif.sys_DLY_100US <= #1 1'b0;
         svif.sys_REF_REQ <= #1 1'b0;
         svif.sys_CLK_int <= #1 1'b0;
         svif.sys_RESET   <= #1 1'b1;
         svif.sys_A       <= #1 24'hFFFFFF;
         svif.sys_Data_Drive    <= #1 16'hzzzz;
         svif.sys_CLK_en  <= #1 1'b0;
         #clock_time;
         svif.sys_CLK_en  <= #1 1'b1;
         #reset_time;
          @(posedge  svif.sys_CLK);
            $display($time,"ns : Coming Out Of Reset");
         svif.sys_RESET    <= #1 1'b0;
           #100;
         svif.sys_DLY_100US    <= #1 1'b1;
          @(posedge   svif.sys_INIT_DONE);
             #500;
          @(negedge  svif.sys_CLK);

       end
      
     join
      $display("sdram control exited loop");
    endtask


task write_data;
    input [23:1] addr;
    input [15:0] data;
  begin
     svif.sys_A = addr;
     svif.sys_adrs_drive = addr;
     svif.sys_ADSn = 0;  //addrs strobe setting to 0 when new mem is
     svif.sys_R_Wn = 0;
    #sys_CLK_period;
     svif.sys_ADSn = 1;
     svif.sys_Data_Drive = data;
     
    #(sys_CLK_period * (NUM_CLK_WRITE + NUM_CLK_WAIT + 4));
    // svif.sys_Data_Drive = 16'hzzzz;
     svif.sys_R_Wn = 1;
     svif.sys_A = 24'hzzzzzz;
     //stoa_read.write(data);
    svif.w_en = 1'b1;
  end
     //bit [15:0] signal_value = data;

endtask

task read;
    input [23:1] addr;
    output axi_m_txn txn;

  begin
    txn=new();
    $display(" entered loop in driver ");
     svif.sys_A = addr;
     svif.sys_adrs_drive = addr;
     svif.sys_ADSn = 0;
     svif.sys_R_Wn = 1;
    #sys_CLK_period;
     //  $display(" Siva entered_1");
     svif.sys_ADSn = 1;
     #sys_CLK_period;
      #sys_CLK_period;
   // #(sys_CLK_period * (NUM_CLK_CL + NUM_CLK_READ + 3));
     svif.sys_R_Wn = 1;
     // $display(" Siva entered_2,%0t",$time);
     svif.sys_A = 24'hzzzzzz;
     wait(svif.sdr_DQ!=='z);
    //  $display(" Siva entered_3");

     repeat(4)
     begin
     @(negedge svif.sys_CLK);
     temp[i][3:0]=svif.sdr_DQ[3:0];
     $display("temp value is %0h",temp[i]);
      i=i+1;
   //  $display(" Siva entered_4");
     end
     i=0;
     txn.rdata={temp[3][3:0],temp[2][3:0],temp[1][3:0],temp[0][3:0]};
    // $display(" Siva entered_5");
     stoa_read.write(txn.rdata);
     $display("read task inside sdram control driver : %0h ",txn.rdata);
  //   $display(" Siva entered_6");
     svif.r_en = 1'b1;
  end
endtask

endclass : sdram_cntrl_driver