class IFFT_Processor extends uvm_driver;
  `uvm_component_utils(IFFT_Processor)
  
  seq_item tr5;
  seq_item tr6;

  
  uvm_tlm_analysis_fifo #(seq_item) recv2;//encoder to ifft
  uvm_analysis_port#(seq_item) send3;//ifft to driver
  
  function new(input string path="IFFT_Processor",uvm_component parent = null);
    super.new(path,parent);
        this.twi();
  endfunction
  
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     send3=new("send3",this);
     recv2=new("recv2",this);
     tr5=seq_item::type_id::create("tr5");
     tr6=seq_item::type_id::create("tr6");
  endfunction
  
  
  parameter int N = 128;
  real twi_real[N/2];
  real twi_imag[N/2];
  real wki_real[N];
  real wki_imag[N];
  real vr[128];
  real vi[128];
////////////////////////////////////////////////////////////////////////
 /*function new();
    this.twi();
  endfunction */
////////////////////////////////////////////////////////////////////////
  function void twi();
    for (int k = 0; k < N/2; k++) begin
      this.twi_real[k] = $cos(2.0 * 3.141592653589793 * k / N); 
      this.twi_imag[k] = $sin(2.0 * 3.141592653589793* k / N);
    end
  endfunction
/////////////////////////////////////////////////////////////////////////
  function void bit_reversal();
    real temp_real[128], temp_imag[128];
    int rx, wx;
    for (int ix = 0; ix < N; ix++) begin
      wx = ix;
      rx = 0;
      for (int qq = 0; qq < $clog2(N); qq++) begin
        rx = rx << 1;
        if (wx & 1) rx = rx | 1;
        wx = wx >> 1;
      end

      wki_real [ix] = tr5.wki_real[rx];
      wki_imag [ix] = tr5.wki_imag[rx];
      //`uvm_info("BIT REVERSAL",$sformatf("input : Index: %d real: %f imag: %f \n Output: Index: %d  real: %f, Imag : %f ",ix,tr5.wki_real[ix],tr5.wki_imag[ix],rx,wki_real[ix],wki_imag[ix]),UVM_NONE)

      /*
      if (ix < rx) begin
        temp_real = tr5.wki_real[ix];
        wki_real[ix] = tr5.wki_real[rx];
        wki_real[rx] = temp_real;
        temp_imag = tr5.wki_imag[ix];
        wki_imag[ix] = tr5.wki_imag[rx];
        wki_imag[rx] = temp_imag;
      end*/

    end
  endfunction
/////////////////////////////////////////////////////////////////////////////////////////////////////////
  virtual task run_phase (uvm_phase phase); 
  super.run_phase(phase);

    forever begin
    
    int lvl, bs, ix, twix, i1, i2; // Declare i1, i2 here
    real t_real, t_imag, v_real, v_imag;
    int spread = 2;
    recv2.get(tr5);///////////////////////
    this.bit_reversal();

    for (lvl = 0; lvl < $clog2(N); lvl++) begin
      bs = 0;
      while (bs < N) begin
        for (ix = bs; ix < bs + spread / 2; ix++) begin
          twix = (ix % (spread)) * (N / spread);
          i1 = ix;
          i2 = ix + spread / 2;

          t_real = twi_real[twix];
          t_imag = twi_imag[twix];

          v_real = wki_real[i2] * t_real - wki_imag[i2] * t_imag;
          v_imag = wki_real[i2] * t_imag + wki_imag[i2] * t_real;

          wki_real[i2] = wki_real[i1] - v_real;
          wki_imag[i2] = wki_imag[i1] - v_imag;
          wki_real[i1] = wki_real[i1] + v_real;
          wki_imag[i1] = wki_imag[i1] + v_imag;
        end
        bs += spread;
      end
      spread *= 2;
    end
   
    for (ix = 0; ix < N; ix++) begin
      tr6.vr[ix]=wki_real[ix]/N;
      tr6.vi[ix]=wki_imag[ix]/N;
      `uvm_info("[IFFT OUTPUT]",$sformatf("VR : [%0d]: %0f, VI : [%0d]: %0f",ix,tr6.vr[ix],ix,tr6.vi[ix]),UVM_NONE);
    end
   send3.write(tr6);///////////////////////////
    end

    endtask
endclass
