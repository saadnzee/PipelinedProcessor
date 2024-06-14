module Decoder_PP(
output [4:0] rs,rt,rd,shamt,
output reg [5:0] opcode,
output [25:0] jump_address_temp,
output [15:0] im_temp,
input [31:0] Instr,
input rst
);

always@* begin
 if (rst)
  opcode <= 6;
 else
  opcode <= Instr[31:26];
end

// R-TYPE
assign rs = Instr[25:21];
assign rt = Instr[20:16];
assign rd = Instr[15:11];
assign shamt = Instr[10:6]; 

// I-Type 
assign rs = Instr[25:21];
assign rt = Instr[20:16];
assign im_temp = Instr[15:0];

// J-Type
assign jump_address_temp = Instr[25:0];

endmodule

