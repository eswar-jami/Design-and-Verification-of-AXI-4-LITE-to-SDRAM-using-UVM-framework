
interface axi_interface;

     parameter DATA_WIDTH = 32;
     parameter RESPONSE_WIDTH = 2;
     logic clk;
     logic resetn;
 
     logic                  awvalid;
     logic                  awready;
     logic [DATA_WIDTH-1:0] awaddr;
     logic [2:0]            awprot;
 
     logic                    wvalid;
     logic                    wready;
     logic [DATA_WIDTH-1:0]   wdata;
     logic [DATA_WIDTH/8-1:0] wstrb;
 
     logic                      bvalid;
     logic                      bready;
     logic [RESPONSE_WIDTH-1:0] bresp;
 
     
     logic                  arvalid;
     logic                  arready;               
     logic [DATA_WIDTH-1:0] araddr;
     logic [2:0]            arprot;
 
     logic                  rvalid;
     logic                  rready;
     logic [1:0]            rresp;
     logic [DATA_WIDTH-1:0] rdata;

 
 endinterface
