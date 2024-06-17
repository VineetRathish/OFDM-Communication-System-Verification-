
class FFT_Processor extends uvm_monitor;
  `uvm_component_utils(FFT_Processor)
  
   uvm_tlm_analysis_fifo #(seq_item) recv4;
   uvm_analysis_port#(seq_item) send5;/////fft to slicing

    parameter int N = 128;  // Parameterize N for flexibility
    real tw_real[N/2];  // Real part of twiddle factors
    real tw_imag[N/2];  // Imaginary part of twiddle factors
    real wk_real[N];  // Working array for real part
    real wk_imag[N];  // Working array for imaginary part
    seq_item t7;
    seq_item tr2;
   virtual ofdm_intf intf;

  
   function new(input string path="FFT_Processor",uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  
  
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv4 = new("recv4",this);
     send5=new("send4",this);
     tr2 = seq_item::type_id::create("tr2",this);
     t7 = seq_item::type_id::create("t7",this);
     //decoder = BDecode::type_id::create("decoder",this);
     //intf=ofdm_intf::type_id::create("intf",this);
     if(!uvm_config_db#(virtual ofdm_intf)::get(this, "", "intf", intf))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".intf"});
  
  endfunction
  
  function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      //send5.connect(decoder.recv5.analysis_export);
  endfunction : connect_phase
  

    // Constructor to initialize twiddle factors and other setups
  /*function new ();
    tw();
  endfunction */
  
 
  /////////////////////////////////////////////////////
    // Function to initialize twiddle factors
  function void tw();
        int k;
        for (k = 0; k < N/2; k++) begin
            this.tw_real[k] = $cos(2.0 * 3.141592653589 * k / N);
          this.tw_imag[k] = -$sin(2.0 * 3.141592653589 * k / N);
        end
    endfunction

////////////////////////////////////////////////////////////	
    // Function to perform bit-reversal
    function void bit_reversal();
        real temp_real, temp_imag;
        int rx, wx;
      for (int ix = 0; ix < N; ix++) begin
            wx = ix;
            rx = 0;
            for (int qq = 0; qq < $clog2(N); qq++) begin
                rx = rx << 1;
                if (wx & 1) rx = rx | 1;
                wx = wx >> 1;
            end
            wk_real [ix] = tr2.vr[rx];
            wk_imag [ix] = tr2.vi[rx];
            //`uvm_info("FFT :: BIT REVERSAL",$sformatf("input : Index: %d real: %f imag: %f \n Output: Index: %d  real: %f, Imag : %f ",ix,tr2.vr[ix],tr2.vi[ix],rx,wk_real[ix],wk_imag[ix]),UVM_NONE)
        end
    endfunction

// Function to perform fft
/////////////////////////////////////////////////////////////////////////////////////////////////////////
virtual task run_phase (uvm_phase phase);
    super.run_phase(phase);

    forever begin
     int ix, i1, i2, twix;  // Declare loop and index variables at the beginning
    int lvl;
    int spread = 2;
    int bs;
    real wk1_real[128],wk1_imag[128];
    real t_real, t_imag, v_real, v_imag;  // Declare variables used in butterfly computations
    recv4.get(tr2);
    tw();
    this.bit_reversal();  // Perform bit reversal on the input data
    wk1_real = wk_real;
    wk1_imag = wk_imag;
    for (int ix=0;ix<128;ix++)begin

    //`uvm_info ("BIT REVERSAL TO BUTTERFLY:",$sformatf("real: %f , Imag : %f",wk1_real[ix],wk1_imag[ix]),UVM_NONE)
    end
// -----------------------

    for (lvl = 0; lvl < 7; lvl++) begin
        bs = 0;
        while (bs < N) begin
            for (ix = bs; ix < bs + (spread / 2); ix++) begin
                twix = (ix % (spread)) * (N / spread);
                i1 = ix;
                i2 = ix + spread / 2;

                // Load twiddle factors
                t_real = tw_real[twix];
                t_imag = tw_imag[twix];
                //$display ("wk_real :%f  %f   wk_imag: %f   %f",wk_real[i1],wk_real[i2],wk_imag[i1],wk_imag[i2]);
                // Compute temporary values for butterfly
              v_real = (wk1_real[i2] * t_real) - (wk1_imag[i2] * t_imag);
              v_imag = (wk1_real[i2] * t_imag) + (wk1_imag[i2] * t_real);

                // Perform butterfly operations
                wk1_real[i2] = wk1_real[i1] - v_real;
                wk1_imag[i2] = wk1_imag[i1] - v_imag;
                wk1_real[i1] = wk1_real[i1] + v_real;
                wk1_imag[i1] = wk1_imag[i1] + v_imag;
            end
            bs += spread;
        end
            spread *= 2;
        
    end

    // Normalize the results
    for (ix = 0; ix < N; ix++) begin
        t7.wki_real[ix] = wk1_real[ix] ;
        t7.wki_imag[ix] = wk1_imag[ix] ;
        `uvm_info("[FFT OUTPUT]",$sformatf("VR : [%0d]: %0f, VI : [%0d]: %0f",ix,wk1_real[ix],ix,wk1_imag[ix]),UVM_NONE);
    end
  send5.write(t7);
  end
endtask

endclass


///////////////////////////////////////////////////
/* @(posedge intf.clk)
intf.firstdata=1;
intf.pushin=1;
wk_real[0]=[intf.dinr/32768];
wk_imag[0]=[intf.dini/32768]; */


