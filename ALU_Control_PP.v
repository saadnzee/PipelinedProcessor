module ALU_Control_PP (
input [1:0] ALUOp,
input [5:0] funct,
output reg [3:0] ALU_opcode
);
always @(*)
begin
case(ALUOp)
 2'b00: ALU_opcode <= 4'b0010; // LW+SW
 2'b01: ALU_opcode <= 4'b0110; // Branch
 2'b10: begin
 case(funct)
  6'b100000: ALU_opcode <= 4'b0010; // add
  6'b100010: ALU_opcode <= 4'b0110; // sub
  6'b100100: ALU_opcode <= 4'b0000; // and
  6'b100101: ALU_opcode <= 4'b0001; // or
  6'b101010: ALU_opcode <= 4'b0111; // not of Rs
 endcase
end
 2'b11: ALU_opcode <= 4'b1010;
endcase
end
endmodule

