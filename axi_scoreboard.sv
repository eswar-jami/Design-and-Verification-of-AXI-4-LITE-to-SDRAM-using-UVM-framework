class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)

    uvm_analysis_imp#(axi_m_txn, axi_scoreboard) sb_imp;
    bit [31:0] mem [int]; // Reference memory model

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_imp = new("sb_imp", this);
    endfunction

    function void write(axi_m_txn txn);
        if (txn.type_trans == WRITE) begin
            mem[txn.aw_addr] = txn.wdata;
            `uvm_info(get_full_name(), $sformatf("Scoreboard: Write stored Addr = %0h, Data = %0h", txn.aw_addr, txn.wdata), UVM_NONE)
        end else if (txn.type_trans == READ) begin
            if (mem.exists(txn.ar_addr) && mem[txn.ar_addr] != txn.rdata) begin
                `uvm_error(get_full_name(), $sformatf("Scoreboard: Data mismatch at Addr = %0h, Expected = %0h, Received = %0h", txn.ar_addr, mem[txn.ar_addr], txn.rdata))
            end else begin
                `uvm_info(get_full_name(), $sformatf("Scoreboard: Read verification passed Addr = %0h, Data = %0h", txn.ar_addr, txn.rdata), UVM_NONE)
            end
        end
    endfunction
endclass