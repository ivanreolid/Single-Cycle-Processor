module imem #(
  parameter MEM_SIZE = 4096,
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
)(
  input  logic [ADDR_WIDTH-1:0] address_i,
  output logic [DATA_WIDTH-1:0] instruction_o
);

  logic [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];

  assign instruction_o = mem[address_i];

  initial begin
    // TODO: Populate memory with correct instructions
    for (int i = 0; i < MEM_SIZE; ++i) begin
      mem[i] = i * 100;
    end
    mem[1] = 32'h4470;  // ADD r1, r2 -> r7
    mem[2] = 32'h40B23; // SUB r6, r5 -> r18
  end

endmodule
