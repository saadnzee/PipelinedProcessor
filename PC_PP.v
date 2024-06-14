module PC_PP(
 input clk,
 input rst,
 input PCSrc,
 input [31:0] PC_Branch,
 input [31:0] Jump_Address,
 input jump,
 input PCWrite,
 output reg [31:0] PC_Out
);

always@(posedge clk) begin 
 if (rst == 1)
  PC_Out <= 0;
 else if (PCWrite == 1'b1) begin
  if (PCSrc == 1'b1)
   PC_Out <= PC_Branch+1;
  else if (jump == 1'b1)
   PC_Out <= Jump_Address;
  else
   PC_Out <= PC_Out+1;
  end
end
endmodule



