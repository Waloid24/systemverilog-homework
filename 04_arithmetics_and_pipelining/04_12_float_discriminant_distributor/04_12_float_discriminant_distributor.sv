module float_discriminant_distributor (
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

     logic [FLEN-1:0] a_pipe [0:4];
     logic [FLEN-1:0] b_pipe [0:4];
     logic [FLEN-1:0] c_pipe [0:4];
     logic            valid_pipes [0:4];
 
     logic disc_res_vld;
     logic [FLEN-1:0] disc_res;
     logic disc_res_negative;
     logic disc_busy;
     logic disc_error;
 
     float_discriminant disc_calc (
         .clk(clk),
         .rst(rst),
         .arg_vld(arg_vld),
         .a(a),
         .b(b),
         .c(c),
         .res_vld(disc_res_vld),
         .res(disc_res),
         .res_negative(disc_res_negative),
         .err(disc_error),
         .busy(disc_busy)
     );
 
     always_ff @(posedge clk or posedge rst) begin
         if (rst) begin
             for (int i = 0; i < 4; i++) begin
                 a_pipe[i]     <= '0;
                 b_pipe[i]     <= '0;
                 c_pipe[i]     <= '0;
                 valid_pipes[i] <= 1'b0;
             end
         end else begin
             for (int i = 4-1; i > 0; i--) begin
                 a_pipe[i] <= a_pipe[i-1];
                 b_pipe[i] <= b_pipe[i-1];
                 c_pipe[i] <= c_pipe[i-1];
                 valid_pipes[i] <= valid_pipes[i-1];
             end
 
             a_pipe[0]       <= a;
             b_pipe[0]       <= b;
             c_pipe[0]       <= c;
             valid_pipes[0]  <= arg_vld;
         end
     end
 
     always_ff @(posedge clk or posedge rst) begin
         if (rst) begin
             res_vld      <= 1'b0;
             res          <= '0;
             res_negative <= 1'b0;
             err          <= 1'b0;
             busy         <= 1'b0;
         end else begin
             res_vld      <= disc_res_vld;
             res_negative <= disc_res_negative;
             res          <= disc_res;
             err          <= disc_error;
             busy         <= disc_busy || (valid_pipes[0] && !disc_res_vld);
         end
     end

endmodule
