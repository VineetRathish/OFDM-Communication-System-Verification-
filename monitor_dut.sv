class monitor_dut extends uvm_monitor;
    `uvm_component_utils(monitor_dut)

    virtual ofdm_intf intf;

    uvm_analysis_port #(seq_item) send8;
    seq_item tr12;

    function new(string path="monitor_dut",uvm_component parent = null);
    super.new(path,parent);
  endfunction

   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send8 = new("send8", this);
    tr12=seq_item::type_id::create("tr12");

   if(!uvm_config_db#(virtual ofdm_intf) :: get(this,"","intf",intf))
      `uvm_error("[MON]","NOT ABLE TO ACCESS THE INTERFACE");
  endfunction

  virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);

    forever begin
        @(posedge intf.clk); begin
        if (intf.pushout) begin
            tr12.dec_out_int = intf.dataout;
            send8.write(tr12);
        end
        //`uvm_info("MONITOR_DUT", $sformatf("Decoder Output: %h", tr12.dec_out_int), UVM_NONE)
        $display("IN MONITOR_DUT Decoder Output: %h",tr12.dec_out_int);
    end
    end
    endtask
endclass
