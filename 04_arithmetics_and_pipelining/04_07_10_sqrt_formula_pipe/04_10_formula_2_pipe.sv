//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);

    // Task:
    //
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    logic vld1, vld2, vld3;
    logic [31:0] res1, res2, res3;

    isqrt sqrt1(
          .clk(clk),
          .rst(rst),
          .x_vld(arg_vld),
          .x(a),
          .y_vld(vld1),
          .y(res1)
    );

    isqrt sqrt2(
          .clk(clk),
          .rst(rst),
          .x_vld(vld1 & arg_vld),
          .x(res1 + b),
          .y_vld(vld2),
          .y(res2)
    );

    isqrt sqrt3(
          .clk(clk),
          .rst(rst),
          .x_vld(vld2 & arg_vld),
          .x(res2 + c),
          .y_vld(vld3),
          .y(res3)
    );    

    assign res_vld = vld3;
    assign res = res3;


endmodule
