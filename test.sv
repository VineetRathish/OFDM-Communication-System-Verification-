class test extends uvm_test;
  `uvm_component_utils(test)
  
  env e;
  seqn1 seq;
  
  
  function new(input string path="test",uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     e=env::type_id::create("e",this);
     //seq=seqn1::type_id::create("seq");
  endfunction 
  
  ////////////////Starting the sequence 
  virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);
    phase.raise_objection(this);
    seq = new();
    seq.start(e.a.seq_r);

     uvm_top.print_topology();
    phase.drop_objection(this);
  endtask
  
endclass
