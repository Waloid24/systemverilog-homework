//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts serial data to the parallel multibit value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits, the module should assert the parallel_valid
    // output and set the data.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic [width-1:0] accumulate_bits;
    logic [3:0] bit_count;

    always_ff @(posedge clk)
    begin
      if (rst)
      begin
        accumulate_bits <= '0;
        bit_count       <= '0;
        parallel_valid  <= '0;
        parallel_data   <= '0;
      end
      else
      begin
        parallel_valid <= '0;

        if (serial_valid)
        begin
          accumulate_bits <= {serial_data, accumulate_bits[width - 1:1]};
          bit_count       <= bit_count + 1;

          if (bit_count == width - 1)
          begin
            parallel_valid <= '1;
            parallel_data  <= {serial_data, accumulate_bits[width - 1:1]};
            bit_count      <= '0;
          end
        end
      end
    end

endmodule

