class axi_m_driver extends uvm_driver#(axi_m_txn);
    
  `uvm_component_utils(axi_m_driver)
   
   virtual axi_interface vif;
   axi_m_txn txn;
   shortint mem[int];

    int awaddr,araddr;
    int to_ctr =0;

 function new(string name="axi_m_driver",uvm_component parent = null);
     super.new(name,parent);
 endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(uvm_config_db#(virtual axi_interface)::get(this, "", "interface_vif",vif) ) begin
      `uvm_info("","master driver got the interface signals",UVM_NONE);
    end 
    else begin
        //`uvm_fatal("","config db failed in driver phase");
    end
    
  endfunction

  virtual task run_phase(uvm_phase phase);

    `uvm_info(get_full_name(),"resetting signals of master ",UVM_NONE);
         
      while(!(vif.resetn)) begin
      `uvm_info("axi_m_driver","resetn reached",UVM_NONE);
      //vif.GPIN    <= 32'h0;
       vif.awaddr  <= 32'h0;
       vif.awprot  <=  3'h0;
       vif.awvalid <=  1'b0;
       vif.wdata   <= 32'h0;
       vif.wstrb   <=  4'h0;
       vif.wvalid  <=  1'b0;
       vif.bready  <=  1'b0;
       vif.araddr  <= 32'h0;
       vif.arprot  <=  3'h0;
       vif.arvalid <=  1'b0;
       vif.rready  <=  1'b0;  

       @(posedge vif.clk);
       end     
         get_and_drive();  
  endtask

  virtual task get_and_drive();
      forever begin
           `uvm_info(get_full_name(),"entering master driver run phase forever loop",UVM_NONE);
          seq_item_port.get_next_item(txn);
          driver_transfer(txn);
          seq_item_port.item_done();
         `uvm_info(get_full_name(),"exiting master driver run phase forever loop",UVM_NONE);
      end

  endtask



  virtual task driver_transfer(axi_m_txn tx);
    driver_address_phase(tx);
   // driver_data_phase(tx);
  endtask

  virtual task driver_address_phase(axi_m_txn tx);
    // `uvm_info("axi_m_driver","driver_address phase",UVM_HIGH)
    case(tx.type_trans)
      READ_v : drive_read_address_channel(tx);
      WRITE_v: drive_write_address_channel(tx);
    endcase
  endtask

 

 virtual task drive_write_address_channel (axi_m_txn tx);
  
  `uvm_info(get_full_name(),$sformatf("entering master write adress channel is %0h",tx.aw_addr),UVM_NONE);
  
  vif.awaddr  = {16'h0, tx.aw_addr};
  vif.awprot  = 3'h0;
  vif.awvalid = 1'b1;
   
 to_ctr=0;
  
  while(!vif.awready) begin   
     to_ctr=to_ctr+1;
      if (to_ctr == 31) begin
        `uvm_error("axi_m_driver","AWREADY timeout");
        break;
      end
      @(posedge vif.clk);
   end
 
  @(posedge vif.clk);
  //if(vif.awready && vif.awvalid) begin
   vif.awaddr  = 'b0;
   vif.awprot  = 'b0;
   vif.awvalid = 'b0;
  //end
  
   drive_write_data_channel(tx.wdata);

endtask


virtual task drive_read_address_channel (axi_m_txn tx);

  `uvm_info(get_full_name(),"In master read adress channel",UVM_NONE);
vif.araddr  = {16'h0, tx.ar_addr};
vif.arprot  = 3'h0;
vif.arvalid = 1'b1;
 
to_ctr=0;

 while(!vif.arready) begin   
     to_ctr=to_ctr+1;
      if (to_ctr == 31) begin
        `uvm_error("axi_m_driver","ARREADY timeout");
        break;
      end
      @(posedge vif.clk);
   end

  @(posedge vif.clk);
     vif.araddr  = 0;
     vif.arprot  = 0;
     vif.arvalid = 0;

  drive_read_data_channel(); 

endtask 
  
virtual task drive_write_data_channel (input bit[31:0] data);
to_ctr=0;

`uvm_info(get_full_name(),$sformatf("entering master write data channel"),UVM_NONE);

vif.wvalid <= 1'b1;
vif.wdata  <= data; 
vif.wstrb  <= 4'hf;


while(!vif.wready) begin
  `uvm_info(get_full_name(),$sformatf("waiting for wready : %0d  to_ctr :  %0d",vif.wready,to_ctr),UVM_NONE);
  to_ctr=to_ctr+1;
    if (to_ctr == 31) begin
      `uvm_error("axi_m_driver","WREADY timeout");
      break;
    end
 @(posedge vif.clk);
end

`uvm_info(get_full_name(),$sformatf("data sent from master is : %0h",data),UVM_NONE);

 @(posedge vif.clk);
vif.wdata  = 32'h0;
vif.wstrb  = 4'h0;
vif.wvalid = 1'b0;

write_response();
endtask

virtual task write_response();

`uvm_info(get_full_name(),"entering master write response channel ",UVM_NONE);
to_ctr = 0;
while(!vif.bvalid) begin
  to_ctr=to_ctr+1;
    if (to_ctr == 31) begin
      `uvm_error("axi_m_driver","AWREADY timeout");
      break;
    end
@(posedge vif.clk);
end

vif.bready = 1'b1;

@(posedge vif.clk);
if(vif.bready && vif.bvalid) begin
  vif.bready = 1'b0;
end

endtask


// drive read data channel
virtual task drive_read_data_channel();
 
 to_ctr = 0;
 vif.rready = 1'b1; 
while(!vif.rvalid) begin
  to_ctr=to_ctr+1;
    if (to_ctr == 5000) begin
      `uvm_error("axi_m_driver","RVALID timeout");
      break;
    end
  @(posedge vif.clk);
end

 mem[araddr] = vif.rdata;
 
   @(negedge vif.rvalid);
     vif.rready = 1'b0;

endtask : drive_read_data_channel


endclass