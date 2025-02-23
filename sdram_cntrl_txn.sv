class sdram_cntrl_txn extends uvm_sequence_item;

	parameter SDR_A_WIDTH =12 ;
         parameter SDR_BA_WIDTH =2 ;
         parameter RA_MSB=22;
         parameter CA_LSB=0;


	       logic                       sys_R_Wn;
		    logic                       sys_ADSn;
		    logic                  sys_DLY_100US;
          logic                    sys_REF_REQ;
	   	 logic  [RA_MSB:CA_LSB]         sys_A;


          logic                      sys_CYC_END;
          logic                      sys_REF_ACK;
	       logic                      sys_D_VALID;
		    logic                      sys_INIT_DONE;
          logic [SDR_A_WIDTH-1:0]    sdr_A;
		logic [SDR_BA_WIDTH-1:0]   sdr_BA;
		logic                      sdr_CKE;
		logic                      sdr_CSn;
		logic                      sdr_RASn;
		logic                      sdr_CASn;
		logic                      sdr_WEn;
		logic                      sdr_DQM;
		logic [15:0]               sys_Data;
		logic [15:0]               sdr_DQ;

      logic [15:0]            sys_Data_Drive;
      logic [RA_MSB:CA_LSB]   sys_adrs_drive;

    
    
	

   `uvm_object_utils_begin(sdram_cntrl_txn)
      `uvm_field_int  (sys_R_Wn,              UVM_ALL_ON)
      `uvm_field_int  (sys_ADSn,              UVM_ALL_ON)
      `uvm_field_int  (sys_DLY_100US,         UVM_ALL_ON)
      `uvm_field_int  (sys_REF_REQ,           UVM_ALL_ON)
      `uvm_field_int  (sys_A,                 UVM_ALL_ON)
      `uvm_field_int  (sys_CYC_END,           UVM_ALL_ON)
      `uvm_field_int  (sys_REF_ACK,           UVM_ALL_ON)
      `uvm_field_int  (sys_D_VALID,           UVM_ALL_ON)
      `uvm_field_int  (sys_INIT_DONE,         UVM_ALL_ON)
      `uvm_field_int  (sdr_A,                 UVM_ALL_ON)
      `uvm_field_int  (sdr_BA,                UVM_ALL_ON)
      `uvm_field_int  (sdr_CKE,               UVM_ALL_ON)
      `uvm_field_int  (sdr_CSn,               UVM_ALL_ON)
      `uvm_field_int  (sdr_RASn,              UVM_ALL_ON)
      `uvm_field_int  (sdr_CASn,              UVM_ALL_ON)
      `uvm_field_int  (sdr_WEn,               UVM_ALL_ON)
      `uvm_field_int  (sdr_DQM,               UVM_ALL_ON)
      `uvm_field_int  (sys_Data,              UVM_ALL_ON)
      `uvm_field_int  (sdr_DQ,                UVM_ALL_ON)


   `uvm_object_utils_end

	function new(string name="sdram_cntrl_txn");
		super.new(name);
	endfunction

endclass