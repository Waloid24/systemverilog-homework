//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input  logic clk,
    input  logic rst,
    input  logic [1:0] requests,
    output logic [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01

    logic [1:0] prev_gran;

    always_comb
    begin
      grants = '0; 
      
      if (requests[0] && requests[1])
      begin
        if (prev_gran[0])
          grants[1] = 1'b1;
        else
          grants[0] = 1'b1;
      end
      else if (requests[0])
        grants[0] = 1'b1;
      else if (requests[1])
        grants[1] = 1'b1;
    end

    always_ff @(posedge clk)
    begin
      if (rst)
        prev_gran <= '0;
      else if (|grants)
        prev_gran <= grants;
    end

endmodule

