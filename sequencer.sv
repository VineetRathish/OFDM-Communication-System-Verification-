class seqr extends uvm_sequencer #(seq_item);
  `uvm_component_utils(seqr)
  
  function new(string path ="seqr",uvm_component parent = null);
    super.new(path,parent);
  endfunction

  function void build_phase (uvm_phase phase);
  super.build_phase(phase);
  `uvm_info("Sequencer","IN BUILD PHASE",UVM_NONE)
  endfunction : build_phase
  
endclass
