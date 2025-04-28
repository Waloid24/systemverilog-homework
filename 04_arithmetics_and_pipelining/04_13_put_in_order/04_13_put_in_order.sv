module put_in_order
#(
  parameter width    = 16,
  parameter n_inputs = 4
)
(
  input  logic                    clk,
  input  logic                    rst,
  input  logic [n_inputs-1:0]     up_vlds,
  input  logic [n_inputs-1:0][width-1:0] up_data,
  output logic                    down_vld,
  output logic [width-1:0]        down_data
);

  localparam COUNTER_width = (n_inputs > 1) ? $clog2(n_inputs) : 1;

  logic [width-1:0]       primary_buffer_data [n_inputs-1:0];
  logic [width-1:0]       secondary_buffer_data [n_inputs-1:0];
  logic [n_inputs-1:0]    primary_buffer_vld;
  logic [n_inputs-1:0]    secondary_buffer_vld;
  logic [COUNTER_width-1:0] counter;

  logic [n_inputs-1:0]    primary_buffer_vld_next;
  assign primary_buffer_vld_next = primary_buffer_vld & ~(1'b1 << counter);

  initial begin
    if (width <= 0) $fatal("Parameter width must be positive");
    if (n_inputs <= 0) $fatal("Parameter n_inputs must be positive");
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      counter <= '0;
      primary_buffer_vld <= '0;
      secondary_buffer_vld <= '0;
    end else begin
      if (primary_buffer_vld[counter]) begin
        counter <= (counter >= n_inputs-1) ? '0 : counter + 1;
      end

      primary_buffer_vld <= primary_buffer_vld_next | secondary_buffer_vld | up_vlds;
      secondary_buffer_vld <= (secondary_buffer_vld & ~(1'b1 << counter)) |
                             (primary_buffer_vld_next & up_vlds);
    end
  end

  always_ff @(posedge clk) begin
    for (int i = 0; i < n_inputs; i++) begin
      if (up_vlds[i] && !primary_buffer_vld_next[i]) begin
        primary_buffer_data[i] <= up_data[i];
      end
      if (up_vlds[i] && primary_buffer_vld[i]) begin
        secondary_buffer_data[i] <= up_data[i];
      end
    end
  end

  assign down_vld  = primary_buffer_vld[counter];
  assign down_data = primary_buffer_data[counter];

endmodule
