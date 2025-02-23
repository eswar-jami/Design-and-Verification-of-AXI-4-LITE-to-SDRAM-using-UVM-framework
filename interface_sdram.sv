interface sdr_intf();
 

         parameter SDR_A_WIDTH =12;
         parameter SDR_BA_WIDTH =2 ;
         parameter RA_MSB=22;
         parameter CA_LSB=0;

         
        logic                      sys_R_Wn;
        logic                      sys_ADSn;
        logic                      sys_DLY_100US;
        logic                      sys_CLK;
        logic                      sys_RESET;
        logic                      sys_REF_REQ;
        logic  [RA_MSB:CA_LSB]     sys_A;

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
        logic                      sys_CLK_en;
        logic                      sys_CLK_int;

        //inout [15:0]             sys_Data;
        //inout [15:0]             sdr_DQ;  
        wire [15:0]                sys_Data;
        // wire [3:0]                 sdr_DQ;    

        logic [15:0] sys_Data_Drive;
        logic  sys_Data_Enable;
        wire [3:0] sdr_DQ;

        logic [RA_MSB:CA_LSB] sys_adrs_drive;
        logic                     r_en;
        logic                     w_en;


//assign sys_adrs_drive=sys_A;
assign sys_Data=(sys_Data_Enable)?sys_Data_Drive:'hz;

assign sys_DLY_100US=1'b1; 

endinterface : sdr_intf
