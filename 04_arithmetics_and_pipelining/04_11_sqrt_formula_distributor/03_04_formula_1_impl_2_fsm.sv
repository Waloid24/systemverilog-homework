//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm
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

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    // Task:
    // Implement a module that calculates the formula from the `formula_1_fn.svh` file
    // using two instances of the isqrt module in parallel.
    //
    // Design the FSM to calculate an answer and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

        enum logic [2:0] {
      st_idle             = 3'd0,
      st_a_b_res_wait     = 3'd1,
      st_c_res_wait       = 3'd2,
      st_done             = 3'd3
    }
    state, next_state;

    logic [15:0] a_sqrt, b_sqrt, c_sqrt;

    always_comb
    begin
      next_state = state;
      res_vld = 0;

      isqrt_1_x_vld = '0;
      isqrt_1_x     = 'x;

      isqrt_2_x_vld = '0;
      isqrt_2_x     = 'x;

      case (state)
        st_idle:
        begin
          isqrt_1_x = a;
          isqrt_2_x = b;

          if (arg_vld)
          begin
            isqrt_1_x_vld = '1;
            isqrt_2_x_vld = '1;
            next_state    = st_a_b_res_wait;
          end
        end

        st_a_b_res_wait:
        begin
          isqrt_1_x = c;
          
          if (isqrt_1_y_vld && isqrt_2_y_vld)
          begin
            isqrt_1_x_vld = '1;
            a_sqrt = isqrt_1_y;
            b_sqrt = isqrt_2_y;
            next_state    = st_c_res_wait;
          end
        end

        st_c_res_wait:
        begin
          if (isqrt_1_y_vld)
          begin
            c_sqrt    = isqrt_1_y;
            next_state = st_done;
          end
        end

        st_done:
        begin
          res_vld = 1;
          res = a_sqrt + b_sqrt + c_sqrt;
          next_state = st_idle;
        end
      endcase
    end

    always_ff @ (posedge clk)
      if (rst)
        state <= st_idle;
      else
        state <= next_state;

    always_ff @ (posedge clk)
      if (state == st_idle)
        res <= '0;


endmodule
