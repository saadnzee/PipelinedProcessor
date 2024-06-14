module RegisterFile_PP(
output [31:0] Rs,
output [31:0] Rt,
input [31:0] Data_In,
input [4:0] rs,
input [4:0] rt,
input [4:0] rd,
input rst,
input clk,
input RegWrite
);

reg [31:0] regfile [31:0];

initial begin 
regfile[0] = 32'd54;
regfile[1] = 32'd55;
regfile[2] = 32'd56;
regfile[3] = 32'd57;
regfile[4] = 32'd58;
regfile[5] = 32'd59;
regfile[6] = 32'd60;
regfile[7] = 32'd5;
regfile[8] = 32'd10;
regfile[9] = 32'd10;
regfile[10] = 32'd61;
regfile[11] = 32'd62;
regfile[12] = 32'd63;
regfile[13] = 32'd64;
regfile[14] = 32'd65;
regfile[15] = 32'd66;
end

assign Rs = regfile[rs];
assign Rt = regfile[rt];

always@(negedge clk) begin
if(RegWrite)
 regfile[rd] <= Data_In;
end

endmodule


