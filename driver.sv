class ofdm_drv extends uvm_driver#(seq_item);
  `uvm_component_utils(ofdm_drv)
  
  uvm_analysis_port#(seq_item) send1;///driver to encoder 
  uvm_tlm_analysis_fifo #(seq_item) recv3;//ifft to driver
  uvm_analysis_port #(seq_item) send4;
  // send ifft output in driver to fft
  // send fft output from fft to decoder
  
  seq_item tr;
  seq_item tr1;
  seq_item tr2;
  
  encoder enc;
  IFFT_Processor ifft;
  FFT_Processor fft;
  
  virtual ofdm_intf intf;
  
  function new(input string path="ofdm_drv",uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send1=new("send1",this);
    recv3=new("recv3",this);
    send4 = new("send4",this);
    enc=encoder::type_id::create("enc",this);
    ifft=IFFT_Processor::type_id::create("ifft",this);
    fft = FFT_Processor::type_id::create("fft",this);
    `uvm_info("Driver","In Build Phase",UVM_NONE)
    if(!uvm_config_db#(virtual ofdm_intf) :: get(this,"","intf",intf))
      `uvm_error("[DRV]","NOT ABLE TO ACCESS THE INTERFACE");
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
    send1.connect(enc.recv1.analysis_export);
    enc.send2.connect(ifft.recv2.analysis_export);
    ifft.send3.connect(recv3.analysis_export);
    send4.connect(fft.recv4.analysis_export);
  endfunction
    

  
  virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);
    tr=seq_item::type_id::create("tr");
    tr1=seq_item::type_id::create("tr1");
    tr2=seq_item::type_id::create("tr2");
    `uvm_info("Driver","In RUn Phase",UVM_NONE)
   forever begin
    seq_item_port.get_next_item(tr);
     tr1.enc_in_int=tr.enc_in_int;
     $display("Inside Driver");
     send1.write(tr1);//////////////////////
     recv3.get(tr2);//////////////////////
     send4.write(tr2);
    for (int ix = 0; ix<128;ix++) begin
    `uvm_info("IFFT OUTPUT in DRiver",$sformatf("Recevied [%0d]:  real: %f imag : %f",ix,tr2.vr[ix],tr2.vi[ix]),UVM_NONE)
    end

    @(posedge intf.clk);begin
     intf.pushin=1;
     intf.firstdata=1;
     intf.dinr=tr2.vr[0] * 32768;
     intf.dini=tr2.vi[0] * 32768;
     $display ("DUT INPUTS: %h  %h  real: %f   %f",intf.dinr,intf.dini,tr2.vr[0],tr2.vi[0]);
     for(int dd=1;dd<128;dd=dd+1) begin
       @(posedge intf.clk); begin
       intf.firstdata=0;
       intf.dinr=tr2.vr[dd]*32768;
       intf.dini=tr2.vi[dd]*32768;
       $display ("DUT INPUTS [%d]: %h  %h  real: %f   %f",dd,intf.dinr,intf.dini,tr2.vr[dd],tr2.vi[dd]);
       end
     end
     intf.pushin=0;
     repeat(130)@(posedge intf.clk);
     ///////////
    end
    seq_item_port.item_done();

    end
    
  endtask
  
endclass

