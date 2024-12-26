module d_ff (
  input wire D,       // Data input
  input wire clk,     // Clock input
  input wire reset,   // Asynchronous reset input
  output reg q,       // Output
  output reg qbar     // Inverted output
);

  // Asynchronous reset
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      q <= 1'b0;      // Reset the output to 0
      qbar <= 1'b1;   // Reset the inverted output to 1
    end else begin
      q <= D;         // On clock edge, set q to D
      qbar <= ~D;     // On clock edge, set qbar to the inverse of D
    end
  end

endmodule

module testcircuit(clk, rst, clkout);
  input wire clk, rst;
  output wire clkout;
  wire t1, t2;
  wire q1, q2;

  // instantiation
  d_ff D1(.D(t1), .q(q1), .qbar(t1), .clk(clk), .reset(rst));
  d_ff D2(.D(t2), .q(q2), .qbar(t2), .clk(~clk),.reset(rst));
  and (clkout ,t1 , t2);
endmodule
  

module testcircuit_TB;
  // Testbench signals
  reg clk;
  reg rst;
  wire clkout;

  // Instantiate the device under test (DUT)
  testcircuit dut (
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

    // Apply random test vectors for a duration
    repeat (20) begin
      #10; // Wait for the next clock edge
    end

    // Apply reset again
    rst = 1; #10;
    rst = 0; #10;

    // Apply more random test vectors
    repeat (20) begin
      #10; // Wait for the next clock edge
    end

    // Finish simulation
    #50;
    $finish;
  end

  // Monitor signals
  initial begin
    $monitor("Time: %0t, clk: %b, rst: %b, clkout: %b", $time, clk, rst, clkout);
  end
endmodule