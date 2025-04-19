//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens
(
    input  logic clk,
    input  logic rst,
    input  logic a,
    output logic b,
    output logic overflow
);
    // Task:
    // Implement a serial module that doubles each incoming token '1' two times.
    // The module should handle doubling for at least 200 tokens '1' arriving in a row.
    //
    // In case module detects more than 200 sequential tokens '1', it should assert
    // an overflow error. The overflow error should be sticky. Once the error is on,
    // the only way to clear it is by using the "rst" reset signal.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 10010011000110100001100100
    // b -> 11011011110111111001111110

    logic [7:0] count;

    always_ff @(posedge clk)
    begin
      if (rst)
      begin
        count    <= '0;
        overflow <= '0;
        b        <= '0;
      end
      else
      begin
          // Overflow logic
        if (a)
        begin
          if (count == 200)
            overflow <= '1;
          else
          begin
            count <= count + 1'b1;
            b     <= '1;
          end
        end
        else
        begin
          if (count == '0)
            b <= '0;
          else
          begin
            count <= count - 1'b1;
            b <= '1;
          end
        end
      end
    end

endmodule

