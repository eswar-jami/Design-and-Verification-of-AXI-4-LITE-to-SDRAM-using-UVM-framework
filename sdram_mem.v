



module sdr (
  sdr_DQ,        // sdr data
  sdr_A,         // sdr address
  sdr_BA,        // sdr bank address
  sdr_CK,        // sdr clock
  sdr_CKE,       // sdr clock enable
  sdr_CSn,       // sdr chip select
  sdr_RASn,      // sdr row address
  sdr_CASn,      // sdr column select
  sdr_WEn,       // sdr write enable
  sdr_DQM        // sdr write data mask
);


parameter Num_Meg    =  16; 
parameter Data_Width =  4;
parameter Num_Bank   =  4; 

parameter tAC = 5.4;
parameter tOH = 2.7;

parameter SDR_A_WIDTH  =  12;
parameter SDR_BA_WIDTH =  2; 

parameter MEG = 21'h100000;
parameter MEM_SIZE = Num_Meg * MEG * Num_Bank;
parameter ROW_WIDTH = 12;
parameter COL_WIDTH = (Data_Width ==  4) ? 11 :
                      (Data_Width ==  8) ? 10 :
                      (Data_Width == 16) ?  9 : 0;



input [SDR_A_WIDTH-1:0]  sdr_A;
input [SDR_BA_WIDTH-1:0] sdr_BA;
input                    sdr_CK;
input                    sdr_CKE;
input                    sdr_CSn;
input                    sdr_RASn;
input                    sdr_CASn;
input                    sdr_WEn;
input                    sdr_DQM;
inout [Data_Width-1:0]   sdr_DQ;



reg [Data_Width-1:0] Memory [*];    // for sdram storage
reg [Data_Width-1:0] Memory_read [*];   // for verification of data stored
reg [2:0]              casLatency;
reg [2:0]              burstLength;

reg [SDR_BA_WIDTH-1:0] bank;
reg [ROW_WIDTH-1:0]    row;
reg [COL_WIDTH-1:0]    column;

reg [3:0] counter;   

reg [Data_Width-1:0]   dataOut;
reg enableSdrDQ;

reg write;
reg latency;
reg read;
reg [15:0]read_count;
reg [15:0]write_count;



initial begin
  casLatency = 0;
  burstLength = 0;
  bank = 0;
  row = 0;
  column = 0;
  counter = 0;
  dataOut = 0; 
  enableSdrDQ = 0;
  write = 0;
  latency = 0;
  read = 0;
  read_count = 0;
  write_count = 0;
end

assign sdr_DQ =
         (Data_Width ==  4) ? (enableSdrDQ ? dataOut :  4'hz) :
         (Data_Width ==  8) ? (enableSdrDQ ? dataOut :  8'hzz) :
         (Data_Width == 16) ? (enableSdrDQ ? dataOut : 16'hzzzz) : 0;

always @(posedge sdr_CK)
  case ({sdr_CSn,sdr_RASn,sdr_CASn,sdr_WEn})
    4'b0000: begin
               $display($time,"ns : Load Mode Register 0x%h",sdr_A);
               casLatency = sdr_A[6:4];
               burstLength = (sdr_A[2:0] == 3'b000) ? 1 :
                             (sdr_A[2:0] == 3'b001) ? 2 :
                             (sdr_A[2:0] == 3'b010) ? 4 :
                             (sdr_A[2:0] == 3'b011) ? 8 : 0;
               $display($time,
                     "ns : mode: CAS Latency=0x%h, Burst Length=0x%h",
                     casLatency, burstLength);
             end
    4'b0001: $display($time,"ns : Auto Refresh Command");
    4'b0010:  begin
                 $display($time,"ns : Precharge Command");
               // bank_active[sdr_BA] = 0;
            end
    4'b0011: begin
                $display($time,"ns : Activate Command");
               if (bank == sdr_BA && row != sdr_A) begin
                 $display($time,"ns : Row change detected. Issuing Precharge Command.");
                 
               end
               $display($time,"ns : Activate Command");

               row = sdr_A;
             end
    4'b0100: begin
               $display($time,"ns : Write Command");
               column = (Data_Width ==  4) ? {sdr_A[11],sdr_A[9:0]} :
                        (Data_Width ==  8) ? {sdr_A[9:0]} :
                        (Data_Width == 16) ? {sdr_A[8:0]} : 0;
               bank = sdr_BA;
               write = 1;
               counter = burstLength;
               Memory[{row,column,bank}] = sdr_DQ;
               $display($time,
                     "ns :write: Bank=0x%h, Row=0x%h, Column=0x%h, Data=0x%h",
                     bank, row, column, sdr_DQ);
        write_count = write_count +1;
             end
    4'b0101: begin
               $display($time,"ns : Read Command");
               column = (Data_Width ==  4) ? {sdr_A[11],sdr_A[9:0]} :
                        (Data_Width ==  8) ? {sdr_A[9:0]} :
                        (Data_Width == 16) ? {sdr_A[8:0]} : 0;
               bank = sdr_BA;
               counter = {1'b0,casLatency} - 1;
               latency = 1;
             end
    4'b0110: $display($time,"ns : Burst Terminate");
    4'b0111: begin
//               $display($time,"ns : Nop Command");
               if ((write == 1) && (counter != 0))
                 begin
                   counter = counter - 1;
                   if (counter == 0) write = 0;
                   else
                     begin
                       column = column + 1;
                       Memory[{row,column,bank}] = sdr_DQ;
             write_count = write_count +1;
                       $display($time,
                         "ns :write: Bank=0x%h, Row=0x%h, Column=0x%h, Data=0x%h",
                         bank, row, column, sdr_DQ);
                     end
                 end
               else if ((read == 1) && (counter != 0))
                 begin
                   counter = counter - 1;
                   if (counter == 0)
                     begin
                       read = 0;
                       enableSdrDQ = #tOH 0;
                     end
                   else
                     begin
                       column = column + 1;
                       dataOut = #tAC Memory[{row,column,bank}];
             read_count = read_count +1;
             Memory_read[{row,column,bank}] = dataOut;
                       $display($time,
                         "ns : read: Bank=0x%h, Row=0x%h, Column=0x%h, Data=0x%h",
                         bank, row, column, dataOut);
             
                     end
                 end
               else if ((latency == 1) && (counter != 0))
                 begin
                   counter = counter - 1;
                   if (counter == 0)
                     begin
                       latency = 0;
                       read = 1;
                       counter = burstLength;
                       dataOut = #tAC Memory[{row,column,bank}];
             read_count = read_count +1;
             Memory_read[{row,column,bank}] = dataOut;
                       enableSdrDQ = 1;
                       $display($time,
                         "ns : read: Bank=0x%h, Row=0x%h, Column=0x%h, Data=0x%h",
                         bank, row, column, dataOut);
                     end
                 end
             end
  endcase

reg flag;
integer i;
always @(posedge sdr_CK)
begin
flag=1;

if ((read_count == write_count) && (write_count != 0))
  begin

  for (i = 0; i < Memory.size();i = i+1)
    begin
      if(Memory.exists(i))
      begin
   
    if (Memory[i] == Memory_read[i])
    begin 
      flag=1 & flag;
    end
   
    else
    begin
      flag=0 & flag;
    end
    end
  end

  end
end 
endmodule


