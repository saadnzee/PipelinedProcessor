module ALU_PP(
output reg [31:0] ALUResult,
output reg zero_flag,
input [31:0] Rs1,
input [31:0] Rs2,
input [3:0] ALU_opcode
);

always@(*)
begin
case(ALU_opcode)
 4'b0010: begin
  ALUResult <= Rs1+Rs2;
 end
 4'b0110: begin
  ALUResult <= Rs1-Rs2;
  if(ALUResult == 0)
   zero_flag = 1;
  else
   zero_flag = 0;
 end
 4'b0000: ALUResult <= Rs1&Rs2;
 4'b0001: ALUResult <= Rs1|Rs2;
 4'b0111: ALUResult <= ~Rs1;
 default: ALUResult = 6'd0;
endcase
end

endmodule
