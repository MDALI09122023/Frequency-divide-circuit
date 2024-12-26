module d_ff (
  input wire D,       // Data input
  input wire clk,     // Clock input
  input wire reset,   // Asynchronous reset input
  output reg q        // Output
);

  // Asynchronous reset
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      q <= 1'b0;      // Reset the output to 0
    end else begin
      q <= D;         // On clock edge, set q to D
    end
  end

endmodule

module generate_example #(parameter N = 4) (
    input wire clk,
    input wire reset,
    output wire clkout
);

  wire [N-1:0] q;
  wire [N-1:0] t;

  // Generate block to create N D flip-flops
  genvar i;
  generate
    for (i = 0; i < N; i = i + 1) begin : dff_array
      if (i == 0) begin
        d_ff dff (
          .D(~q[i]),
          .q(q[i]),
          .clk(clk),
          .reset(reset)
        );
      end else begin
        d_ff dff (
          .D(~q[i]),
          .q(q[i]),
          .clk(q[i-1]),
          .reset(reset)
        );
      end
    end
  endgenerate

  // Assign the output of the last flip-flop to clkout
  buf (clkout,q[N-1]);

endmodule

module testtwocircuit (
  input wire clk,     // Clock input
  input wire rst,     // Reset input
  output wire clkout  // Output
);

  // Instantiate the generate_example module
  generate_example #(4) gen_example (
    .clk(clk),
    .reset(rst),
    .clkout(clkout)
  );

endmodule


module testtwocircuit_TB;
  // Testbench signals
  reg clk;
  reg rst;
  wire clkout;

  // Instantiate the device under test (DUT)
  testtwocircuit dut (
    .clk(clk),
    .rst(rst),
    .clkout(clkout)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // Clock with a period of 10 time units
  end

  // Test sequence
  initial begin
    // Initialize signals
    rst = 1;

    // Apply reset
    #10;
    rst = 0;
    #10;

    // Apply some test vectors
    #100;  // Wait for a duration to observe the behavior

    // Apply reset again
    rst = 0;
    #10;
    rst = 0;
    #10;

    // Apply some more test vectors
    #100;  // Wait for a duration to observe the behavior

    // Finish simulation
    #50;
    $finish;
  end

  // Monitor signals
  initial begin
    $monitor("Time: %0t, clk: %b, rst: %b, clkout: %b", $time, clk, rst, clkout);
  end
endmodule