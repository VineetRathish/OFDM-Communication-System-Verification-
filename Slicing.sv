class BDecode extends uvm_monitor;
`uvm_component_utils(BDecode)
  
  uvm_tlm_analysis_fifo #(seq_item) recv5;///////////
  uvm_analysis_port #(seq_item) send6;
  virtual ofdm_intf intf;
  
    real re_l_parts[128];  // For clarity and to avoid reserved keyword conflict
    real im_l_parts[128];  // For consistency with real_part
    real full_scale;
    real tpoints[4] = {0.0, 333.0, 666.0, 1000.0};
    real fspoints[4];
    real decision_points[3];
    real fsq;
  reg [47:0] bv;
  reg [47:0] output_data;
  seq_item recieve;
  seq_item tr8;
  //monitor mr;
  function new(input string path="BDecode",uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     recv5=new("recv5",this);
     send6=new("send6",this);
     //mr = monitor::type_id::create("mr",this);
     recieve = seq_item::type_id::create("recieve",this);
     tr8 = seq_item::type_id::create("tr8");
     //intf=ofdm_intf::type_id::create("intf",this);
     if(!uvm_config_db#(virtual ofdm_intf)::get(this, "", "intf", intf))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".intf"});
  endfunction
  


    // Constructor
/*    function new(real re_l_vals[], real im_l_vals[]);
        this.re_l_parts = re_l_vals;
        this.im_l_parts = im_l_vals;
    endfunction */
    // Helper method to compute magnitude squared of a complex number
    function real asq(real r_al, real imag);
        return r_al * r_al + imag * imag;
    endfunction

    // Helper method to find the maximum of two reals
    function real max(real a, real b);
        return (a > b) ? a : b;
    endfunction

    // Main method to decode spectrum
  function reg [47:0] decode();
      reg [47:0] result = 0;
        // Calculate the full scale based on the magnitude squared of bins 55 or 57
        full_scale = max(asq(re_l_parts[55], im_l_parts[55]), asq(re_l_parts[57], im_l_parts[57]));

        // Calculate full scale points
        for (int i = 0; i < 4; i++) begin
          fspoints[i] = tpoints[i] * full_scale/1000;  // Scaled to full scale
        end

        // Set decision points
        decision_points[0] = asq(167.0 * full_scale / 1000.0, 0.0);
        decision_points[1] = asq((167.0 + 333.0) * full_scale / 1000.0, 0.0);
      decision_points[2] = asq((167.0 + 666.0) * full_scale / 1000.0, 0.0);
        // Decode the spectrum into bitstream
        for (int x = 4; x < 52; x += 2) begin
            fsq = asq(re_l_parts[x], im_l_parts[x]);
          
            bv = 3;
            for (int dx = 0; dx < 3; dx++) begin
                if (fsq < decision_points[dx]) begin
                    bv = dx;
                    break;
                end
            end
            //result |= bv << (x - 4) / 2;  // Shift bv into the correct bit position
          bv=bv<<(x-4);
          result=result|bv;
        end

        return result;
    endfunction


    virtual task run_phase (uvm_phase phase);
      forever begin
          recv5.get(recieve);
          re_l_parts = recieve.wki_real;
          im_l_parts = recieve.wki_imag;
          output_data = decode();
          //$display("Decoder Output: %h",output_data);
          tr8.dec_out_int = output_data;
          send6.write(tr8);
     end

    endtask: run_phase
endclass

















