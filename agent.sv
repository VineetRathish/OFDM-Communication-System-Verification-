class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  seqr seq_r;
  ofdm_drv dr;
  monitor mr;
  BDecode bd;
  monitor_dut mrd;

   
  function new(input string path="agent",uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq_r=seqr::type_id::create("seq_r",this);
    dr=ofdm_drv::type_id::create("dr",this);
    mr=monitor::type_id::create("mr",this);
    mrd=monitor_dut::type_id::create("mrd",this);
    bd=BDecode::type_id::create("bd",this);
  endfunction 
  ///////////////Connecting Seqr------->Driver
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dr.seq_item_port.connect(seq_r.seq_item_export);
    dr.fft.send5.connect(bd.recv5.analysis_export);
    bd.send6.connect(mr.recv6.analysis_export);

  endfunction
  
endclass
