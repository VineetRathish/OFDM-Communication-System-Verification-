`include "uvm_macros.svh"
`include "pkg.sv"
`include "intf.sv"
`include "ofdm_file"
import uvm_pkg::*;
import ofdm_pkg::*;
module top;
reg clk;


  ofdm_intf intf(clk);
initial begin
    clk = 0;
intf.reset = 1;
#1;
intf.reset = 0;
    forever #5 clk = ~clk;  // Assuming 10 time units per cycle
  end


`ifdef ofdm
ofdmdec a1 ( clk, intf.reset,
                intf.pushin, intf.firstdata,
                intf.dinr,
                intf.dini,
                intf.pushout, intf.dataout);

`elsif ofdm0
ofdmdec a1 (clk, intf.reset,
                intf.pushin, intf.firstdata,
                intf.dinr,
                intf.dini,
                intf.pushout, intf.dataout);


`elsif ofdm1
ofdmdec a1 (clk, intf.reset,
                intf.pushin, intf.firstdata,
                intf.dinr,
                intf.dini,
                intf.pushout, intf.dataout);


`elsif ofdm2
ofdmdec a1 (clk, intf.reset,
                intf.pushin, intf.firstdata,
                intf.dinr,
                intf.dini,
                intf.pushout, intf.dataout);

`elsif ofdm3
ofdmdec a1 (clk, intf.reset,
                intf.pushin, intf.firstdata,
                intf.dinr,
                intf.dini,
                intf.pushout, intf.dataout);


`elsif ofdm4
ofdmdec a1 (clk, intf.reset,
                intf.pushin, intf.firstdata,
                intf.dinr,
                intf.dini,
                intf.pushout, intf.dataout);


`elsif ofdm5
ofdmdec a1 (clk, intf.reset,
                intf.pushin, intf.firstdata,
                intf.dinr,
                intf.dini,
                intf.pushout, intf.dataout );


`elsif ofdm6
ofdmdec a1 (clk, intf.reset,
                intf.pushin, intf.firstdata,
                intf.dinr,
                intf.dini,
                intf.pushout, intf.dataout);


`elsif ofdm7
ofdmdec a1 (clk, intf.reset,
                intf.pushin, intf.firstdata,
                intf.dinr,
                intf.dini,
                intf.pushout, intf.dataout);


`elsif ofdm8
ofdmdec a1 (clk, intf.reset,
                intf.pushin, intf.firstdata,
                intf.dinr,
                intf.dini,
                intf.pushout, intf.dataout );

`else
ofdmdec a1 (clk, intf.reset,
                intf.pushin, intf.firstdata,
                intf.dinr,
                intf.dini,
                intf.pushout, intf.dataout);


`endif

  initial 
    begin
      uvm_config_db#(virtual ofdm_intf)::set(null,"*","intf",intf);
     $display(" running test");
    run_test("test");
  end

  initial begin
    //uvm_config_db#(virtual veif)::set(uvm_root::get(),"*","vif",if1);
    $dumpfile("dump.vcd");
    $dumpvars;
end
endmodule
