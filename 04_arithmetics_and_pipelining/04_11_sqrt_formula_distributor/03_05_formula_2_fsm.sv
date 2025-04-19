//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // Task:
    //
    // Implement a module that calculates the formula from the `formula_2_fn.svh` file
    // using only one instance of the isqrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

      enum logic [2:0]
  {
    st_idle  = 3'd0,
    st_1_arg = 3'd1,
    st_2_arg = 3'd2,
    st_3_arg = 3'd3
  }
  state, next_state;

  logic [31:0] bc_sum, abc_sum;

  always_comb
  begin
    next_state = state;
    res_vld = '0;

    isqrt_x_vld = '0;
    isqrt_x = 'x;

    case (state)
    st_idle:
    begin
      isqrt_x = c;

      if (arg_vld)
      begin
        isqrt_x_vld = '1;
        next_state = st_1_arg;
      end
    end

    st_1_arg:
    begin
      if (isqrt_y_vld)
      begin
        bc_sum = b + isqrt_y;
        isqrt_x_vld = '1;
        isqrt_x = bc_sum;
        next_state = st_2_arg;
      end
    end

    st_2_arg:
    begin
      if (isqrt_y_vld)
      begin
        abc_sum = a + isqrt_y;
        isqrt_x_vld = '1;
        isqrt_x = abc_sum;
        next_state = st_3_arg;
      end
    end

    st_3_arg:
    begin
      if (isqrt_y_vld)
      begin
        res_vld = 1;
        res = isqrt_y;
        next_state = st_idle;
      end
    end
    endcase
  end

  always_ff @ (posedge clk)
  begin
    if (rst)
      state <= st_idle;
    else
      state <= next_state;
  end

  always_ff @ (posedge clk)
    if (state == st_idle)
      res <= '0;


endmodule
