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

    // Instantiate the float_discriminant module
    float_discriminant u_float_discriminant (
        .clk(clk),
        .rst(rst),
        .arg_vld(arg_vld),
        .a(a),
        .b(b),
        .c(c),
        .res_vld(res_vld),
        .res(res),
        .res_negative(res_negative),
        .err(err)
    );

    // Counter to track pending computations for busy signal
    logic [31:0] pending_count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pending_count <= 0;
        end else begin
            case ({arg_vld, res_vld})
                2'b00: pending_count <= pending_count;                  // No change
                2'b01: if (pending_count > 0) pending_count <= pending_count - 1; // Result produced
                2'b10: pending_count <= pending_count + 1;             // New input accepted
                2'b11: pending_count <= pending_count;                 // Input accepted and result produced
            endcase
        end
    end

    // Busy is high when there are pending computations or a new input is being accepted
    assign busy = (pending_count > 0) || arg_vld;

endmodule
