module ID_EX_Register(
 output reg [31:0] PC_Out,
 output reg [31:0] Rs_Out,
 output reg [31:0] Rt_Out,
 output reg [31:0] im_Out,
 output reg [4:0] rt_Out,
 output reg [4:0] rd_Out,
 output reg [4:0] rs_Out,
 output reg [31:0] Jump_Address_Out,
 input clk,
 input rst,
 input [31:0] Jump_Address_In,
 input [31:0] PC_In,
 input [31:0] Rs_In,
 input [31:0] Rt_In,
 input [31:0] im_In,
 input [4:0] rt_In,
 input [4:0] rd_In,
 input [4:0] rs_In,
 input rst_ID_EX
);

always@(posedge clk) begin
if(rst==1 || rst_ID_EX==1) begin
 PC_Out <= 0;
 Rs_Out <= 0;
 Rt_Out <= 0;
 im_Out <= 0;
 rt_Out <= 0;
 rd_Out <= 0;
 rs_Out <= 0;
 Jump_Address_Out <= 0;
end

else begin
 PC_Out <= PC_In;
 Rs_Out <= Rs_In;
 Rt_Out <= Rt_In;
 im_Out <= im_In;
 rt_Out <= rt_In;
 rd_Out <= rd_In;
 rs_Out <= rs_In;
 Jump_Address_Out <= Jump_Address_In;
end

end
endmodule

