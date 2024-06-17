class scor extends uvm_scoreboard;
`uvm_component_utils(scor)
  
  uvm_tlm_analysis_fifo #(seq_item) recv7;
  uvm_tlm_analysis_fifo #(seq_item) recv8;
  seq_item tr11;
  seq_item tr13;
  function new(input string path="scor",uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv7=new("recv7",this);
    recv8=new("recv8",this);
    tr11=seq_item::type_id::create("tr11");
    tr13=seq_item::type_id::create("tr13");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);
    forever begin
    recv7.get(tr11);
    recv8.get(tr13);
    if(tr13.dec_out_int == tr11.dec_out_int) begin
    `uvm_info ("[SCR]", "Test case is passed",UVM_NONE);
    end
    else begin
    `uvm_error ("[SCR]", "Test case is not passed");
    /*$display("IN SCB Decoder Output: %h",tr11.dec_out_int);
    $display("IN SCB Decoder Output: %h",tr13.dec_out_int);*/
    end
    end
endtask
  
endclass

