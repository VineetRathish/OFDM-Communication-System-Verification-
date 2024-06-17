class env extends uvm_env;
  `uvm_component_utils(env)
  
  agent a;
  scor scr;
  //monitor mr1;
  
   
  function new(input string path="env",uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     a=agent::type_id::create("a",this);
     scr=scor::type_id::create("scr",this);
    // mr1=monitor::type_id::create("mr1", this);
  endfunction 
  
  //////////////Connecting Monitor--------->Scro
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.mr.send7.connect(scr.recv7.analysis_export);
    a.mrd.send8.connect(scr.recv8.analysis_export);
    //mr1.send7.connect(scr.recv7.analysis_export);
  endfunction
  
endclass
