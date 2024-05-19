module IF_ID_Register(
 output reg [31:0] PC_Out,
 output reg [31:0] Instr_Out,
 input clk,
 input rst,
 input [31:0] PC_In,
 input [31:0] Instr_In,
 input we_IF_ID
);

always@(posedge clk) begin
if (rst==1) begin
 PC_Out <= 0;
 Instr_Out <= 0;
end
else begin
 if (we_IF_ID == 1'b1) begin
 PC_Out <= PC_In;
 Instr_Out <= Instr_In;
 end
end
end
endmodule

