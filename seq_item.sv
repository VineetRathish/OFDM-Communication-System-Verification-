class seq_item extends uvm_sequence_item;
  `uvm_object_utils(seq_item)
  
  ////////// Declaring inputs as rand. 
  rand bit [47:0] enc_in_int;
  bit  [47:0] dec_out_int;
  
  real enc_real[128];
  real enc_img [128];
  real wki_real[128];
  real wki_imag [128];
  
  
  real vr[128];
  real vi[128];

  
  function new(string path="seq_item");
    super.new(path);
  endfunction
  
endclass

