class encoder extends uvm_component;
  
  `uvm_component_utils(encoder)
  uvm_tlm_analysis_fifo #(seq_item)  recv1;//driver to encoder
  uvm_analysis_port#(seq_item) send2;//encoder to ifft
  
  
  seq_item tr3;
  seq_item tr4;

  
  function new(input string path="encoder",uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send2=new("send2",this);
    recv1=new("recv1",this);
    `uvm_info("Encoder","In Build Phase",UVM_NONE)
    tr3=seq_item::type_id::create("tr3");
    tr4=seq_item::type_id::create("tr4");
  endfunction
  

  virtual task enc();

    bit [47:0] enc_in_int;
    real enc_real[128];
    real enc_img [128] = '{default:0};
    int  start = 4;
    real amp[4] = '{0.000, 0.333, 0.666, 1.000};

    
    if (!this.randomize()) $display("Randomization failed");
    for (int i = 0; i < 48; i = i + 2) begin
      int index = start + i;
      int index_comp = 127 - (start + i);
      int bit_value = {tr3.enc_in_int[i+1], tr3.enc_in_int[i]};
      
      enc_real[index] = amp[bit_value % 4];
      enc_real[index_comp] = amp[bit_value % 4];
    end
    enc_real[55] = 1;
    enc_real[128-55] = 1;
    
    tr4.wki_real=enc_real;
    tr4.wki_imag=enc_img;
    for(int ee=0;ee<128;ee=ee+1)
      `uvm_info("[ENC]",$sformatf("enc_real[%0d]: %0f, enc_img[%0d]: %0f",ee,enc_real[ee],ee,enc_img[ee]),UVM_NONE)

    
  endtask

  virtual task run_phase (uvm_phase phase);
      super.run_phase(phase);
      `uvm_info ("ENCODER","IN RUN PHASE",UVM_NONE)
      forever begin
          recv1.get(tr3);/////////////////////
          enc();
          send2.write(tr4);////////////////////////
      end
      `uvm_info("ENCODER","EXITING RUN PHASE",UVM_NONE)
  endtask : run_phase
endclass
