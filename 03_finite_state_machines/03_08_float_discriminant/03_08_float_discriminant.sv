//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    enum logic [3:0] {
        st_idle,

        st_send_b2,
        st_wait_b2,

        st_send_ac,
        wait_ac,

        st_send_4ac,
        st_wait_4ac,

        st_send_res,
        st_wait_res,

        st_output
    } state, next_state;

    logic [FLEN-1:0] b2, ac, four_ac;
    logic [FLEN-1:0] four = 64'h4010000000000000;

    logic [FLEN-1:0] fmult_a, fmult_b, fsub_a, fsub_b;
    logic [FLEN-1:0] fmult_res, fsub_res;

    logic fmult_up_valid, fmult_down_valid, fmult_busy, fmult_err;
    logic fsub_up_valid,  fsub_down_valid,  fsub_busy,  fsub_err;

    f_mult u_mult (
        .clk(clk), .rst(rst),
        .a(fmult_a), .b(fmult_b), .up_valid(fmult_up_valid),
        .res(fmult_res), .down_valid(fmult_down_valid),
        .busy(fmult_busy), .error(fmult_err)
    );

    f_sub u_sub (
        .clk(clk), .rst(rst),
        .a(fsub_a), .b(fsub_b), .up_valid(fsub_up_valid),
        .res(fsub_res), .down_valid(fsub_down_valid),
        .busy(fsub_busy), .error(fsub_err)
    );

    always_comb
    begin
      res_vld        = 0;
      fmult_up_valid = 0;
      fsub_up_valid  = 0;

      busy         = (state != st_idle && state != st_output);
      err          = fmult_err | fsub_err;
      res_negative = res[FLEN-1];

      case (state)
        st_idle:
          if (arg_vld)
              next_state = st_send_b2;

        st_send_b2:
        begin
          fmult_up_valid = 1;
          fmult_a = b;
          fmult_b = b;

          next_state = st_wait_b2;
        end

        st_wait_b2:
          if (fmult_down_valid) begin
              b2 <= fmult_res;
              next_state = st_send_ac;
          end
            
        st_send_ac:
        begin
          fmult_up_valid = 1;
          fmult_a = a;
          fmult_b = c;

          next_state = wait_ac;
        end

        wait_ac:
          if (fmult_down_valid)
          begin
            ac <= fmult_res;
            next_state = st_send_4ac;
          end

        st_send_4ac:
        begin
          fmult_up_valid = 1;
          fmult_a = four;
          fmult_b = ac;

          next_state = st_wait_4ac;
        end

        st_wait_4ac:
          if (fmult_down_valid)
          begin
            four_ac <= fmult_res;
            next_state = st_send_res;
          end

        st_send_res:
        begin
          fsub_up_valid = 1;
          fsub_a = b2;
          fsub_b = four_ac;

          next_state = st_wait_res;
        end

        st_wait_res:
          if (fsub_down_valid)
          begin
            res <= fsub_res;
            next_state = st_output;
          end

        st_output:
        begin
          res_vld    = 1;
          next_state = st_idle;
        end
      endcase
    end

    always_ff @(posedge clk) begin
      if (rst) 
        state <= st_idle;
      else 
        state <= next_state;
    end

endmodule
