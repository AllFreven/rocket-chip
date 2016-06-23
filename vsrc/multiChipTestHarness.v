// See LICENSE for license details.

extern "A" void htif_fini(input reg failure);

extern "A" void htif_tick
(
  output reg                    htif_in_valid,
  input  reg                    htif_in_ready,
  output reg  [`HTIF_WIDTH-1:0] htif_in_bits,

  input  reg                    htif_out_valid,
  output reg                    htif_out_ready,
  input  reg  [`HTIF_WIDTH-1:0] htif_out_bits,

  output reg  [31:0]            exit
);

extern "A" void memory_tick
(
  input  reg [31:0]               channel,

  input  reg                      ar_valid,
  output reg                      ar_ready,
  input  reg [`MEM_ADDR_BITS-1:0] ar_addr,
  input  reg [`MEM_ID_BITS-1:0]   ar_id,
  input  reg [2:0]                ar_size,
  input  reg [7:0]                ar_len,

  input  reg                      aw_valid,
  output reg                      aw_ready,
  input  reg [`MEM_ADDR_BITS-1:0] aw_addr,
  input  reg [`MEM_ID_BITS-1:0]   aw_id,
  input  reg [2:0]                aw_size,
  input  reg [7:0]                aw_len,

  input  reg                      w_valid,
  output reg                      w_ready,
  input  reg [`MEM_STRB_BITS-1:0] w_strb,
  input  reg [`MEM_DATA_BITS-1:0] w_data,
  input  reg                      w_last,

  output reg                      r_valid,
  input  reg                      r_ready,
  output reg [1:0]                r_resp,
  output reg [`MEM_ID_BITS-1:0]   r_id,
  output reg [`MEM_DATA_BITS-1:0] r_data,
  output reg                      r_last,

  output reg                      b_valid,
  input  reg                      b_ready,
  output reg [1:0]                b_resp,
  output reg [`MEM_ID_BITS-1:0]   b_id
);

module BlackBoxTileLinkNetwork(
  input clock,
  input reset,

  input         tl_in_0_acquire_valid,
  output        tl_in_0_acquire_ready,
  input  [ 1:0] tl_in_0_acquire_bits_client_xact_id,
  input         tl_in_0_acquire_bits_is_builtin_type,
  input  [ 2:0] tl_in_0_acquire_bits_a_type,
  input  [25:0] tl_in_0_acquire_bits_addr_block,
  input  [ 2:0] tl_in_0_acquire_bits_addr_beat,
  input  [11:0] tl_in_0_acquire_bits_union,
  input  [63:0] tl_in_0_acquire_bits_data,

  output        tl_in_0_grant_valid,
  input         tl_in_0_grant_ready,
  output [ 1:0] tl_in_0_grant_bits_client_xact_id,
  output        tl_in_0_grant_bits_manager_xact_id,
  output        tl_in_0_grant_bits_is_builtin_type,
  output [ 3:0] tl_in_0_grant_bits_g_type,
  output [ 2:0] tl_in_0_grant_bits_addr_beat,
  output [63:0] tl_in_0_grant_bits_data,

  input         tl_in_1_acquire_valid,
  output        tl_in_1_acquire_ready,
  input  [ 1:0] tl_in_1_acquire_bits_client_xact_id,
  input         tl_in_1_acquire_bits_is_builtin_type,
  input  [ 2:0] tl_in_1_acquire_bits_a_type,
  input  [25:0] tl_in_1_acquire_bits_addr_block,
  input  [ 2:0] tl_in_1_acquire_bits_addr_beat,
  input  [11:0] tl_in_1_acquire_bits_union,
  input  [63:0] tl_in_1_acquire_bits_data,

  output        tl_in_1_grant_valid,
  input         tl_in_1_grant_ready,
  output [ 1:0] tl_in_1_grant_bits_client_xact_id,
  output        tl_in_1_grant_bits_manager_xact_id,
  output        tl_in_1_grant_bits_is_builtin_type,
  output [ 3:0] tl_in_1_grant_bits_g_type,
  output [ 2:0] tl_in_1_grant_bits_addr_beat,
  output [63:0] tl_in_1_grant_bits_data,

  output        tl_out_0_acquire_valid,
  input         tl_out_0_acquire_ready,
  output [ 1:0] tl_out_0_acquire_bits_client_xact_id,
  output        tl_out_0_acquire_bits_is_builtin_type,
  output [ 2:0] tl_out_0_acquire_bits_a_type,
  output [25:0] tl_out_0_acquire_bits_addr_block,
  output [ 2:0] tl_out_0_acquire_bits_addr_beat,
  output [11:0] tl_out_0_acquire_bits_union,
  output [63:0] tl_out_0_acquire_bits_data,

  input         tl_out_0_grant_valid,
  output        tl_out_0_grant_ready,
  input  [ 1:0] tl_out_0_grant_bits_client_xact_id,
  input         tl_out_0_grant_bits_manager_xact_id,
  input         tl_out_0_grant_bits_is_builtin_type,
  input  [ 3:0] tl_out_0_grant_bits_g_type,
  input  [ 2:0] tl_out_0_grant_bits_addr_beat,
  input  [63:0] tl_out_0_grant_bits_data
);

// RapidIO goes here

endmodule

module multiChipTestHarness;

  reg [31:0] seed;
  initial seed = $get_initial_random_seed();

  //-----------------------------------------------
  // Instantiate the processor

  reg clk   = 1'b0;
  reg reset = 1'b1;
  reg r_reset = 1'b1;
  reg start = 1'b0;

  always #`CLOCK_PERIOD clk = ~clk;

  reg [  63:0] max_cycles = 0;
  reg [  63:0] trace_count = 0;
  reg [1023:0] vcdplusfile = 0;
  reg [1023:0] vcdfile = 0;
  reg          verbose = 0;
  wire         printf_cond = verbose && !reset;
  integer      stderr = 32'h80000002;

  reg htif_out_ready;
  reg htif_in_valid;
  reg [`HTIF_WIDTH-1:0] htif_in_bits;
  wire htif_in_ready, htif_out_valid;
  wire [`HTIF_WIDTH-1:0] htif_out_bits;

`include `TBVFRAG

  always @(posedge clk)
  begin
    r_reset <= reset;
  end

  reg [31:0] exit = 0;

  always @(posedge htif_clk)
  begin
    if (reset || r_reset)
    begin
      htif_in_valid <= 0;
      htif_out_ready <= 0;
      exit <= 0;
    end
    else
    begin
      htif_tick
      (
        htif_in_valid,
        htif_in_ready,
        htif_in_bits,
        htif_out_valid,
        htif_out_ready,
        htif_out_bits,
        exit
      );
    end
  end

  //-----------------------------------------------
  // Start the simulation

  // Read input arguments and initialize
  initial
  begin
    $value$plusargs("max-cycles=%d", max_cycles);
    verbose = $test$plusargs("verbose");
`ifdef DEBUG
    if ($value$plusargs("vcdplusfile=%s", vcdplusfile))
    begin
      $vcdplusfile(vcdplusfile);
      $vcdpluson(0);
      $vcdplusmemon(0);
    end

    if ($value$plusargs("vcdfile=%s", vcdfile))
    begin
      $dumpfile(vcdfile);
      $dumpvars(0, dut);
      $dumpon;
    end
`define VCDPLUSCLOSE $vcdplusclose; $dumpoff;
`else
`define VCDPLUSCLOSE
`endif

    // Strobe reset
    #777.7 reset = 0;

  end

  reg [255:0] reason = 0;
  always @(posedge clk)
  begin
    if (max_cycles > 0 && trace_count > max_cycles)
      reason = "timeout";
    if (exit > 1)
      $sformat(reason, "tohost = %d", exit >> 1);

    if (reason)
    begin
      $fdisplay(stderr, "*** FAILED *** (%s) after %d simulation cycles", reason, trace_count);
      `VCDPLUSCLOSE
      htif_fini(1'b1);
    end

    if (exit == 1)
    begin
      if (verbose)
        $fdisplay(stderr, "Completed after %d simulation cycles", trace_count);
      `VCDPLUSCLOSE
      htif_fini(1'b0);
    end
  end

  always @(posedge clk)
  begin
    trace_count = trace_count + 1;
`ifdef GATE_LEVEL
    if (verbose)
    begin
      $fdisplay(stderr, "C: %10d", trace_count-1);
    end
`endif
  end

endmodule
