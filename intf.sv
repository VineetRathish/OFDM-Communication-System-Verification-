interface ofdm_intf(input clk);
  

      logic reset;
     logic pushin;
     logic firstdata;
     reg  signed [16:0] dinr;
     reg  signed [16:0] dini;
     logic pushout;
     logic [47:0] dataout;
  
endinterface
