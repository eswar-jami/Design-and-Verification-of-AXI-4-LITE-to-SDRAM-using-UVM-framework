`uvm_analysis_imp_decl(_port_c)
`uvm_analysis_imp_decl(_port_d)
class axi_sdram_Coverage extends uvm_component;

	
	`uvm_component_utils(axi_sdram_Coverage)
	
	axi_m_txn           a_txn;
	sdram_cntrl_txn sdram_txn;

	uvm_analysis_imp_port_c #(axi_m_txn,        axi_sdram_Coverage) analysis_imp_c;  
	uvm_analysis_imp_port_d #(sdram_cntrl_txn,    axi_sdram_Coverage) analysis_imp_d; 

	

	covergroup cg_axi_sdram();
		option.comment="Coverage for axi2sdram controller";
		option.per_instance = 1;
          
          //AXI Signals
		    aw_addr : coverpoint (a_txn.aw_addr);
			wdata   : coverpoint (a_txn.wdata);
			ar_addr : coverpoint (a_txn.ar_addr);

			rdata   : coverpoint (a_txn.rdata);
			awvalid : coverpoint (a_txn.awvalid);
			arvalid : coverpoint (a_txn.arvalid);
			wvalid  : coverpoint (a_txn.wvalid);                                         

			rvalid  : coverpoint (a_txn.rvalid);

		 // SDRAM Signals
			sys_R_Wn       : coverpoint (sdram_txn.sys_R_Wn);       
			sys_ADSn       : coverpoint (sdram_txn.sys_ADSn);       
			sys_DLY_100US  : coverpoint (sdram_txn.sys_DLY_100US);  
			sys_REF_REQ    : coverpoint (sdram_txn.sys_REF_REQ);    
			sys_A          : coverpoint (sdram_txn.sys_A);          

			sys_CYC_END    : coverpoint (sdram_txn.sys_CYC_END);    
			sys_REF_ACK    : coverpoint (sdram_txn.sys_REF_ACK);    
			sys_D_VALID    : coverpoint (sdram_txn.sys_D_VALID);    
			sys_INIT_DONE  : coverpoint (sdram_txn.sys_INIT_DONE);  
			sdr_A          : coverpoint (sdram_txn.sdr_A);          

			sdr_BA         : coverpoint (sdram_txn.sdr_BA);         
			sdr_CKE        : coverpoint (sdram_txn.sdr_CKE);        
			sdr_CSn        : coverpoint (sdram_txn.sdr_CSn);        
			sdr_RASn       : coverpoint (sdram_txn.sdr_RASn);       
			sdr_CASn       : coverpoint (sdram_txn.sdr_CASn);       

			sdr_WEn        : coverpoint (sdram_txn.sdr_WEn);        
			sdr_DQM        : coverpoint (sdram_txn.sdr_DQM);        
			sys_Data       : coverpoint (sdram_txn.sys_Data);       
			sdr_DQ         : coverpoint (sdram_txn.sdr_DQ);         

			sys_Data_Drive : coverpoint (sdram_txn.sys_Data_Drive); 
			sys_adrs_drive : coverpoint (sdram_txn.sys_adrs_drive);

	endgroup

	function new (string name="",uvm_component parent);
			super.new(name,parent);
			analysis_imp_c = new("analysis_imp_c", this);
    		analysis_imp_d = new("analysis_imp_d", this);
			cg_axi_sdram=new();
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info(get_full_name(),"-----------------COVERAGE Bulid Phase---------------------",UVM_NONE)
		   a_txn=axi_m_txn::type_id::create("a_txn");
		   sdram_txn=sdram_cntrl_txn::type_id::create("sdram_txn");
	endfunction

  	virtual function void write_port_c(axi_m_txn axi_pkt);
    	//`uvm_info(get_type_name(),$sformatf(" Inside write_port_a method. Received axi_pkt On Analysis Imp Port#########################################################################################################"),UVM_LOW)
    	//`uvm_info(get_type_name(),$sformatf(" Printing axi_pkt, \n %s",axi_pkt.sprint()),UVM_LOW)
    	//axi_pkt.print();
		a_txn = axi_pkt;
	 	// cg_AXI_SDRAM.sample();
  	endfunction
  

  	virtual function void write_port_d(sdram_cntrl_txn sdram_pkt);
    	// `uvm_info(get_type_name(),$sformatf(" Inside write_port_b method. Received sdram_pkt On Analysis Imp Port$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"),UVM_LOW)
    	// `uvm_info(get_type_name(),$sformatf(" Printing sdram_pkt, \n %s", sdram_pkt.sprint()),UVM_LOW)
    	// sdram_pkt.print();
		sdram_txn =sdram_pkt;
	 	cg_axi_sdram.sample();
  	endfunction

	function void report_phase(uvm_phase phase);
		//`uvm_info(get_type_name(), $sformatf("Received AXI transaction: %s", axi_tr.sprint()), UVM_LOW)
	//	`uvm_info(get_type_name(), $sformatf("Received SDRAM transaction: %s", sdram_tr.sprint()), UVM_LOW)
     	`uvm_info(get_full_name(),$sformatf("Coverage is %0.2f %%", cg_axi_sdram.get_coverage()),UVM_LOW);
     	// `uvm_info(get_full_name(),$sformatf("Coverage is %0.2f %%", ,UVM_LOW);
     	
     	//`uvm_report_coverage();
  	endfunction


endclass