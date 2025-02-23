class axi_m_monitor extends uvm_monitor;
    `uvm_component_utils(axi_m_monitor)

    virtual axi_interface vif;
    uvm_analysis_port #(axi_m_txn) mon_ap;

    // Local memory for storing writes
    bit [31:0] mem [int];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_ap = new("mon_ap", this);
        if (!uvm_config_db#(virtual axi_interface)::get(this, "", "interface_vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not set for axi_monitor")
    endfunction

    task run_phase(uvm_phase phase);
        fork
            monitor_write();
            monitor_read();
        join
    endtask

    task monitor_write();
        axi_m_txn txn;
        forever begin
            @(posedge vif.awvalid);
            txn = axi_m_txn::type_id::create("txn");
            txn.awvalid = vif.awvalid;
            txn.type_trans = WRITE_v;
            txn.aw_addr = vif.awaddr;

            @(posedge vif.wvalid);
            txn.wdata = vif.wdata;
            txn.wvalid = vif.wvalid;
            mem[vif.awaddr] = vif.wdata;
            `uvm_info("","-------------------------------------------------------------------------------------------",UVM_NONE)
            `uvm_info(get_full_name(), $sformatf("Write captured: Addr = %0h, Data = %0h", txn.aw_addr, txn.wdata), UVM_NONE)
            mon_ap.write(txn);
        end
    endtask

    task monitor_read();
        axi_m_txn txn;
        forever begin
            @(posedge vif.arvalid);
            txn = axi_m_txn::type_id::create("txn");
            txn.arvalid = vif.arvalid;
            txn.type_trans = READ_v;
            txn.ar_addr = vif.araddr;
  mon_ap.write(txn);
            $display("siva arvalid recieved");
            @(posedge vif.rvalid);
             $display("siva rvalid recieved");
            txn.rdata = vif.rdata;
            txn.rvalid = vif.rvalid;
            if (mem.exists(vif.araddr) && mem[vif.araddr] != vif.rdata) begin
                `uvm_info("","-------------------------------------------------------------------------------------------",UVM_NONE)
                `uvm_error(get_full_name(), $sformatf("Data mismatch! Addr = %0h, Expected = %0h, Received = %0h", txn.ar_addr, mem[vif.araddr], vif.rdata))
            end else if (mem.exists(vif.araddr)) begin
                `uvm_info("","-------------------------------------------------------------------------------------------",UVM_NONE)
                `uvm_info(get_full_name(), $sformatf("Read captured: Addr = %0h, Data = %0h (Match)", txn.ar_addr, txn.rdata), UVM_NONE)
            end else begin
                `uvm_info("","-------------------------------------------------------------------------------------------",UVM_NONE)
                `uvm_info(get_full_name(), $sformatf("Read captured: Addr = %0h, Data = %0h (Address Not Found)", txn.ar_addr, txn.rdata), UVM_NONE)
            end
          
        end
    endtask
    
endclass
