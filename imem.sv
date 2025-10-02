module imem (
  input  logic [31:0] address_i,
  output logic [31:0] instruction_o
);

  logic [31:0] mem[4095:0];

  assign instruction_o = mem[address_i];

  initial begin
    // TODO: Populate memory with correct instructions
    for (int i = 0; i < 4096; ++i) begin
      mem[i] = i * 100;
    end
  end

endmodule
