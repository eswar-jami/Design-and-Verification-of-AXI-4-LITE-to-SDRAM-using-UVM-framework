class axi4lite_slave_mem extends uvm_component;
    `uvm_component_utils(axi4lite_slave_mem)

    // AXI4-Lite interface
    virtual axi_interface vif;
    virtual sdr_intf svif;

    // Memory array
    bit [15:0] mem [int];
    bit [15:0] temp;
    uvm_analysis_imp #(bit [15:0],axi4lite_slave_mem) s_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        s_ap=new("s_ap",this);
    endfunction

    function void write(bit [15:0] recieved_signal);
        temp = recieved_signal;
        $display("recieved data in axi_slave driver is %0h",temp);
    endfunction 

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_interface)::get(this, "", "interface_vif", vif)) begin
            `uvm_fatal("NOVIF", "axi Virtual interface not set for axi4lite_slave_mem") end
        if (!uvm_config_db#(virtual sdr_intf)::get(this,"", "sdram_interface", svif)) begin
            `uvm_fatal("NOVIF", "sdram Virtual interface not set for axi4lite_slave_mem") end
        
    endfunction
    // Run phase
    task run_phase(uvm_phase phase);
        vif.arready<=0;
        vif.awready<=0;
        vif.wready<=0;
        vif.rdata<=0;
        vif.rvalid<=0;
        vif.bvalid<=0;
        vif.bresp <= 2'b0;
        fork
        begin      
        forever begin
            // Wait for a valid transaction
            @(posedge vif.awvalid);
            
            if (vif.awvalid) begin
                // Write transaction
                @(posedge vif.clk);

                while(!svif.sys_INIT_DONE) begin
                 `uvm_info(get_full_name(),"inside write after init_done is 0 ",UVM_NONE)
                 @(posedge vif.clk); 
                end

                `uvm_info(get_full_name(),"inside write after init_done is 1 ",UVM_NONE)
                 vif.awready <= 1;
               @(negedge vif.awvalid);
                vif.awready <= 0;
               
                @(posedge vif.wvalid);
                @(posedge vif.clk);
                vif.wready <= 1;
                mem[vif.awaddr[22:0]] = vif.wdata;
                svif.sys_Data_Drive = vif.wdata;
                @(negedge vif.wvalid);
                vif.wready <= 0;
               
                vif.bvalid <= 1;
                vif.bresp <= 2'b0;
                wait (vif.bready == 1);
                @(posedge vif.clk);
                vif.bvalid <= 0;
            end
        end
    end
 begin
            
        
        forever begin
            // Wait for a valid transaction
            @(posedge vif.arvalid);
            
            if (vif.arvalid) begin
                // Read transaction
                @(posedge vif.clk);

                while(!svif.sys_INIT_DONE) begin
                 @(posedge vif.clk); 
                end

                vif.arready <= 1;
                

                @(negedge vif.arvalid);             
                vif.arready <= 0;              
                temp=0;              
                wait(temp!=0);             
              //  vif.rdata <= mem[vif.araddr[22:0]];
                vif.rdata <= temp;              
                vif.rvalid <= 1;            
                wait(vif.rready == 1);             
                @(posedge vif.clk);
                vif.rvalid <= 0;
                temp=0;
                vif.rdata <= 0;
            end
        end
    end
join
 endtask


endclass