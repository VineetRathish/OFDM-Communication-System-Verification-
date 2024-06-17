class seqn1 extends uvm_sequence #(seq_item);
  `uvm_object_utils(seqn1)

  function new(input string path="seqn1");
    super.new(path);
  endfunction

  task body();
    seq_item tr;
    //r = new();
    
    repeat(10)  begin
     tr = seq_item::type_id::create("tr");
    start_item(tr);
    tr.randomize();
    $display("input %h", tr.enc_in_int);
    $display("Inside Sequence");
    finish_item(tr);
     end
  endtask

endclass

