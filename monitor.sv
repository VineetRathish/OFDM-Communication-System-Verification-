class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  seq_item tr9;
  seq_item tr10;
 virtual ofdm_intf intf;
  uvm_analysis_port#(seq_item) send7;
  uvm_tlm_analysis_fifo#(seq_item) recv6;
  
  function new(string path="monitor",uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     tr10=seq_item::type_id::create("tr10");
     tr9=seq_item::type_id::create("tr9");
     recv6=new("recv6",this);
    send7=new("send7",this);
   if(!uvm_config_db#(virtual ofdm_intf) :: get(this,"","intf",intf))
      `uvm_error("[MON]","NOT ABLE TO ACCESS THE INTERFACE");
  endfunction
  

  virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);
    forever begin
      recv6.get(tr9);
      tr10.dec_out_int = tr9.dec_out_int;
      send7.write(tr10);
      $display("IN MON Decoder Output: %h",tr9.dec_out_int);
    end
    
  endtask
  
endclass
