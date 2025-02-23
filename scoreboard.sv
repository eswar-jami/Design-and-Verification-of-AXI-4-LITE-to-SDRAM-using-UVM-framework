`uvm_analysis_imp_decl(_from_axi_mon)
`uvm_analysis_imp_decl(_from_sdram_mon)

class top_scoreboard extends uvm_scoreboard;
  
  axi_m_txn m_txn;
  sdram_cntrl_txn sd_txn;

  bit [22:0] aw_addr[$];
  bit [22:0] ar_addr[$];
  bit [15:0] wdata[$];
  bit [15:0] rdata[$];
  bit [22:0] sd_r_addr[$];
  bit [22:0] sd_w_addr[$];
  bit [15:0] sd_wdata[$];
  bit [15:0] sd_rdata[$];


  `uvm_component_utils(top_scoreboard)

    int i;
    int count;
    int count_1;
  
  uvm_analysis_imp_from_axi_mon #(axi_m_txn,top_scoreboard) analysis_imp_axi;
  uvm_analysis_imp_from_sdram_mon #(sdram_cntrl_txn,top_scoreboard) analysis_imp_sdram;



  function new (string name="",uvm_component parent);
    super.new(name,parent);
    analysis_imp_axi = new("analysis_imp_axi",this);
    analysis_imp_sdram = new("analysis_imp_sdram",this);


  

    `uvm_info("scoreboard class","-----------this is the top scoreboard-------------",UVM_NONE)
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_full_name(),"-----------------SCOREBOARD Build Phase---------------------",UVM_NONE)
    m_txn = axi_m_txn::type_id::create("m_txn");
    sd_txn = sdram_cntrl_txn::type_id::create("sd_txn");
  endfunction 

  // AXI Write Function
  function void write_from_axi_mon(axi_m_txn m_txn);
    if (m_txn.awvalid) begin
      `uvm_info(get_type_name(), $sformatf("########################## AXI Write Addr: %0h", m_txn.aw_addr), UVM_NONE)
      aw_addr.push_back(m_txn.aw_addr);
    //`uvm_info(get_type_name(), $sformatf("****************Pushed AXI Write Addr in queue : %0h",aw_addr[2]), UVM_NONE)
    end
    if (m_txn.arvalid) begin
      `uvm_info(get_type_name(), $sformatf("AXI Read Addr: %0h", m_txn.ar_addr), UVM_NONE)
      ar_addr.push_back(m_txn.ar_addr);
    end
    if (m_txn.wvalid) begin
      `uvm_info(get_type_name(), $sformatf("AXI Write Data: %0h", m_txn.wdata), UVM_NONE)
      wdata.push_back(m_txn.wdata);
    end
    if (m_txn.rvalid) begin
      `uvm_info(get_type_name(), $sformatf("###########################  AXI Read Data: %0h", m_txn.rdata), UVM_NONE)
      rdata.push_back(m_txn.rdata);
    end
  endfunction

  // SDRAM Write Function
  function void write_from_sdram_mon(sdram_cntrl_txn sd_txn);
    if (sd_txn.sys_R_Wn) begin
      `uvm_info(get_type_name(), $sformatf("####################### Pushed SDRAM Read Addr: %0h", sd_txn.sys_adrs_drive), UVM_NONE)
      sd_r_addr.push_back(sd_txn.sys_adrs_drive);
      `uvm_info(get_type_name(), $sformatf("###################### Pushed SDRAM Read Data: %0h", sd_txn.sys_Data_Drive), UVM_NONE)
      sd_rdata.push_back(sd_txn.sys_Data_Drive);
    end 
    if(!sd_txn.sys_R_Wn) begin
      `uvm_info(get_type_name(), $sformatf("########################## Pushed SDRAM Write Addr: %0h", sd_txn.sys_adrs_drive), UVM_NONE)
      sd_w_addr.push_back(sd_txn.sys_adrs_drive);
      `uvm_info(get_type_name(), $sformatf("############################## Pushed SDRAM Write Data: %0h", sd_txn.sys_Data_Drive), UVM_NONE)
      sd_wdata.push_back(sd_txn.sys_Data_Drive);
    end

     `uvm_info(get_type_name(), $sformatf("*****************************Queue Sizes -> aw_addr: %0d, ar_addr: %0d, wdata: %0d, rdata: %0d, sd_r_addr: %0d, sd_w_addr: %0d, sd_wdata: %0d, sd_rdata: %0d",
              aw_addr.size(), ar_addr.size(), wdata.size(), rdata.size(),
              sd_r_addr.size(), sd_w_addr.size(), sd_wdata.size(), sd_rdata.size()), UVM_NONE)

      print_queues();
     compare_packet();

  endfunction


function void print_queues();
    int i;

    `uvm_info(get_type_name(), "------------------ QUEUE DATA ------------------", UVM_NONE)

    `uvm_info(get_type_name(), "AXI Write Address Queue:", UVM_NONE)
    for (i = 0; i < aw_addr.size(); i++)
        $display("Index [%0d]: %0h", i, aw_addr[i]);

    `uvm_info(get_type_name(), "AXI Read Address Queue:", UVM_NONE)
    for (i = 0; i < ar_addr.size(); i++)
        $display("Index [%0d]: %0h", i, ar_addr[i]);

    `uvm_info(get_type_name(), "AXI Write Data Queue:", UVM_NONE)
    for (i = 0; i < wdata.size(); i++)
        $display("Index [%0d]: %0h", i, wdata[i]);

    `uvm_info(get_type_name(), "AXI Read Data Queue:", UVM_NONE)
    for (i = 0; i < rdata.size(); i++)
        $display("Index [%0d]: %0h", i, rdata[i]);

    `uvm_info(get_type_name(), "SDRAM Read Address Queue:", UVM_NONE)
    for (i = 0; i < sd_r_addr.size(); i++)
        $display("Index [%0d]: %0h", i, sd_r_addr[i]);

    `uvm_info(get_type_name(), "SDRAM Write Address Queue:", UVM_NONE)
    for (i = 0; i < sd_w_addr.size(); i++)
        $display("Index [%0d]: %0h", i, sd_w_addr[i]);

    `uvm_info(get_type_name(), "SDRAM Write Data Queue:", UVM_NONE)
    for (i = 0; i < sd_wdata.size(); i++)
        $display("Index [%0d]: %0h", i, sd_wdata[i]);

    `uvm_info(get_type_name(), "SDRAM Read Data Queue:", UVM_NONE)
    for (i = 0; i < sd_rdata.size(); i++)
        $display("Index [%0d]: %0h", i, sd_rdata[i]);

    `uvm_info(get_type_name(), "---------------------------------------------------", UVM_NONE)

endfunction

  function void compare_packet();
    while (sd_r_addr.size() > 0 && sd_w_addr.size() > 0 && sd_wdata.size() > 0 && 
           sd_rdata.size() > 0 && aw_addr.size() > 0 && ar_addr.size() > 0 && 
           wdata.size() > 0) begin  
           //rdata.size() > 0        
    
      bit [22:0] sd_r_addr_val = sd_r_addr.pop_front();
      bit [22:0] sd_w_addr_val = sd_w_addr.pop_front();
      bit [15:0] sd_wdata_val = sd_wdata.pop_front();
      bit [15:0] sd_rdata_val = sd_rdata.pop_front();

      bit [22:0] aw_addr_val = aw_addr.pop_front();
      bit [22:0] ar_addr_val = ar_addr.pop_front();
      bit [15:0] wdata_val = wdata.pop_front();
      bit [15:0] rdata_val = rdata.pop_front();

      // `uvm_info(get_type_name(), $sformatf("-------------------------------------------------Comparing: SDRAM(%0h %0h %0h %0h) AXI(%0h %0h %0h %0h)", 
      //           sd_r_addr_val, sd_w_addr_val, sd_wdata_val, sd_rdata_val, 
      //           aw_addr_val, ar_addr_val, wdata_val, rdata_val), UVM_NONE)

      `uvm_info(get_type_name(), "---------------- POPPED DATA ----------------", UVM_NONE)
      $display("AXI Write Addr  : %0h", aw_addr_val);
      $display("AXI Read Addr   : %0h", ar_addr_val);
      $display("AXI Write Data  : %0h", wdata_val);
      $display("AXI Read Data   : %0h", rdata_val);
      $display("SDRAM Read Addr : %0h", sd_r_addr_val);
      $display("SDRAM Write Addr: %0h", sd_w_addr_val);
      $display("SDRAM Write Data: %0h", sd_wdata_val);
      $display("SDRAM Read Data : %0h", sd_rdata_val);
      `uvm_info(get_type_name(), "--------------------------------------------", UVM_NONE)


     if (aw_addr_val == sd_w_addr_val) begin
            `uvm_info(get_type_name(), "Write Address Match!", UVM_NONE)
            if (ar_addr_val == sd_r_addr_val) begin
                `uvm_info(get_type_name(), "Read Address Match!", UVM_NONE)
                if (wdata_val == sd_wdata_val) begin
                    `uvm_info(get_type_name(), "Write Data Match!", UVM_NONE)
                    if (rdata_val == sd_rdata_val) begin
                        count++;
                        `uvm_info(get_type_name(), $sformatf("------------------------- DATA %d MATCHED SUCCESSFULLY!!! ------------------------------", count), UVM_NONE);
                    end else begin
                        `uvm_info(get_type_name(), "Read Data MISMATCH!", UVM_NONE)
                    end
                end else begin
                    `uvm_info(get_type_name(), "Write Data MISMATCH!", UVM_NONE)
                end
            end else begin
                `uvm_info(get_type_name(), "Read Address MISMATCH!", UVM_NONE)
            end
        end else begin
            `uvm_info(get_type_name(), "Write Address MISMATCH!", UVM_NONE)
        end
    end

    count_1++;  
    


    if(count_1 > 5) begin
      if(count == 4) begin
        `uvm_info(get_type_name(), "----------------TEST PASS-------------------------", UVM_NONE);
      end else begin
        `uvm_info(get_type_name(), "------------------TEST FAIL-----------------------", UVM_NONE);
      end
    end
  endfunction
endclass : top_scoreboard







































// if(i==0)begin
  		 // 	$display("sd_r_addr=%0h",sd_r_addr.pop_front());
		 // 	$display("sd_w_addr=%0h",sd_w_addr.pop_front());
		 // 	$display("sd_wdata=%0h",sd_wdata.pop_front());
		 // 	$display("sd_rdata=%0h",sd_rdata.pop_front());
  		 // 	i++;
  		 // end
  		 // else begin
	  	// 	$display("================================================");
		// 	$display("aw_addr=%0h",aw_addr.pop_front());
		// 	$display("ar_addr=%0h",ar_addr.pop_front());
		// 	$display("wdata=%0h",wdata.pop_front());
		// 	$display("rdata=%0h",wdata.pop_front());
		// 	$display("sd_r_addr=%0h",sd_r_addr.pop_front());
		// 	$display("sd_w_addr=%0h",sd_w_addr.pop_front());
		// 	$display("sd_wdata=%0h",sd_wdata.pop_front());
		// 	$display("sd_rdata=%0h",sd_rdata.pop_front());j
		// 	$display("================================================");




		// 	 if((aw_addr.pop_front()) == (sd_w_addr.pop_front()))begin

		// 	 	if((ar_addr.pop_front()) == (sd_r_addr.pop_front()))begin

		// 	 		if((wdata.pop_front()) == (sd_wdata.pop_front()))begin

		// 	 			if((rdata.pop_front()) == (sd_rdata.pop_front()))begin
		// 	 				count++;
		// 	 				`uvm_info(get_type_name(),$sformatf("DATA %d MATCHED SUCCESSFULLY!!!",count),UVM_LOW);
		// 	 			end

		// 			end

		// 	 	end

		// 	 end
		// end
		// count1++;	