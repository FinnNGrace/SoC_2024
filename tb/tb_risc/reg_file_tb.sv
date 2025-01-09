`timescale 1ns / 1ps
module reg_file_tb;
    reg         clk, rst;
    reg [4:0]   rs1_addr, rs2_addr, rd_addr;
    reg [31:0]  rd_data;
    reg         rd_wren;
    wire [31:0] rs1_data, rs2_data;

    reg_file DUT(
		.clk(clk),
		.rst_n(rst),
		.rs1_addr(rs1_addr),
		.rs2_addr(rs2_addr),
		.rd_addr(rd_addr),
		.rd_wr_en(rd_wren),
		.rd_data(rd_data),
		.rs1_data(rs1_data),
		.rs2_data(rs2_data)
    );
    
    initial begin
    clk = 0;
    forever #5 clk = ~clk;
    end     

    //reset all x0 - x31 to zero in 5ns
    initial begin
		rst 		= 1'b0;		// 1 bit, reset all to zero
		rs1_addr 	= 5'd0;		
		rs2_addr	= 5'd0;
		rd_addr 	= 5'd0;
		rd_wren 	= 1'b0;		// 1 bit
		rd_data	= 32'h0;		//32 bit
		#3;
		rst         = 1'b1;
		#2;
    end

    initial begin
		// rs1_data updated
		$display ("rs1_data updated");
	   	rd_wren = 1; rd_addr = 3; rd_data = 32'hFFFFFFFF;
		rs1_addr = 3; rs2_addr = 4;
		#5;
		$display ("T = %2d, rd_wren = %1d, rd_addr = %2d, rd_data = %8h, rs1_addr = %2d, rs2_addr = %2d", $time, rd_wren, rd_addr, rd_data, rs1_addr, rs2_addr);
		#1;
		if (rs1_data == 32'hFFFFFFFF) 
		$display ("T = %2d, rs1_data = %8h, rs2_data = %8h, PASSED", $time, rs1_data, rs2_data);
		else
		$display ("T = %2d, rs1_data = %8h, rs2_data = %8h, FAILED", $time, rs1_data, rs2_data);
		// rs2_data updated
		$display ("rs2_data updated");
		rd_wren = 1; rd_addr = 4; rd_data = 32'hAAAAAAAA;
		rs1_addr = 3; rs2_addr = 4;
		#9;
		$display ("T = %2d, rd_wren = %1d, rd_addr = %2d, rd_data = %8h, rs1_addr = %2d, rs2_addr = %2d", $time, rd_wren, rd_addr, rd_data, rs1_addr, rs2_addr);
		#1;
		if (rs2_data == 32'hAAAAAAAA) 
		$display ("T = %2d, rs1_data = %8h, rs2_data = %8h, PASSED", $time, rs1_data, rs2_data);
		else
		$display ("T = %2d, rs1_data = %8h, rs2_data = %8h, FAILED", $time, rs1_data, rs2_data);		
		// rs1_data fetched, rs2_data fetched
		$display ("rs1_data fetched, rs2_data fetched");
		rd_wren = 0; rd_addr = 4; rd_data = 32'hAAAAAAAA;
		rs1_addr = 3; rs2_addr = 4;
		#9;
		$display ("T = %2d, rd_wren = %1d, rd_addr = %2d, rd_data = %8h, rs1_addr = %2d, rs2_addr = %2d", $time, rd_wren, rd_addr, rd_data, rs1_addr, rs2_addr);
		#1;
		if (rs2_data == 32'hAAAAAAAA && rs1_data == 32'hFFFFFFFF) 
		$display ("T = %2d, rs1_data = %8h, rs2_data = %8h, PASSED", $time, rs1_data, rs2_data);
		else
		$display ("T = %2d, rs1_data = %8h, rs2_data = %8h, FAILED", $time, rs1_data, rs2_data);	

		#9 $finish;
	end
    
endmodule