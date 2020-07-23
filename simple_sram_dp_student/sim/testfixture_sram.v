//behavior tb
`timescale 1ns/10ps
`define CYCLE	3.00
`define End_CYCLE  1000000            // Modify cycle times once your design need more cycle times!
`define PAT1        "../sram_input_test" 
`define PAT2        "../sram_output_test"
`define SDFFILE     "./sram_wrapper_syn.sdf"

module sram_tb;

	parameter NUM_PAT = 64;
	
    reg  		 		clk;
	reg  		 		reset;
    reg  [511:0]  		sram_in;
    reg  		 		valid_in;
    wire [511:0]      	sram_out;
    wire       	 		valid_out;
	
	reg [31:0]			in_index, out_index;
	reg  [511:0] golden_sram_in  [NUM_PAT-1:0];
	reg  [511:0] golden_sram_out [NUM_PAT-1:0];
		
	wire pass = (sram_out==golden_sram_out[out_index]);
    
	sram_wrapper sram_unit
	(
		.CLK(clk),
		.RST(reset),
		.sram_in(sram_in),
		.valid_in(valid_in),
		.sram_out(sram_out),
		.valid_out(valid_out)
	);

	`ifdef SDF
	   initial $sdf_annotate(`SDFFILE, sram_unit );
	`endif

    // waveform dump
    initial begin
        $fsdbDumpfile("sram.fsdb" );
        $fsdbDumpvars(0, sram_unit, "+mda");
    end
	
	initial begin
		$display("--------------------------- [ Simulation Starts !! ] ---------------------------");	
		$readmemh(`PAT1, golden_sram_in);
		$readmemh(`PAT2, golden_sram_out);
	end
        
    // clock
    initial begin
        clk = 1'b0;
        forever #(`CYCLE*0.5) clk = ~clk;
    end
	
	wire stop_all = (out_index==NUM_PAT);
	integer err_cnt, i, k, iters;
	
    initial begin
        reset = 1'b0; valid_in = 1'b0; in_index = 0; out_index = 0; err_cnt = 0; iters = 0; 
        #(`CYCLE) reset = 1'b1;
		#(3*`CYCLE) reset = 1'b0;
		#(`CYCLE)
		while(!stop_all) begin
			@(negedge clk);
			iters = iters+1;
			valid_in = 1'b0;
			if(in_index<=NUM_PAT-1) begin
				valid_in = 1'b1;//(k>=19);
				sram_in = golden_sram_in[in_index];
				in_index = in_index+1;
			end
			else begin
				if(valid_out) begin
					if (!pass) begin
						$display(" Pattern %d failed !. Expected candidate = %h, but the Response candidate = %h !! ", out_index, golden_sram_out[out_index], sram_out);
						err_cnt = err_cnt + 1;
					end else begin
						$display("Pattern %d is passed !. Expected candidate = %h, Response candidate = %h !! ", out_index, golden_sram_out[out_index], sram_out);
					end
					out_index = out_index+1;
				end
			end
        end
		
		#(`CYCLE*2); 
		$display("--------------------------- Simulation Stops !!---------------------------");
		if (err_cnt) begin 
			$display("============================================================================");
			$display("\n (T_T) ERROR found!! There are %d errors in total.\n", err_cnt);
			$display("============================================================================");
		end
		 else begin 
			$display("============================================================================");
			$display("\n");
			$display("        ****************************              ");
			$display("        **                        **        /|__/|");
			$display("        **  Congratulations !!    **      / O,O  |");
			$display("        **                        **    /_____   |");
			$display("        **  Simulation Complete!! **   /^ ^ ^ \\  |");
			$display("        **                        **  |^ ^ ^ ^ |w|");
			$display("        *************** ************   \\m___m__|_|");
			$display("\n");
			$display("============================================================================");
			$finish;
		end
		$finish;
    end
	

	always@(err_cnt) begin
		if (err_cnt >= 10) begin
			$display("============================================================================");
			$display("\n (>_<) ERROR!! There are more than 10 errors during the simulation! Please check your code @@ \n");
			$display("============================================================================");
			$finish;
		end
	end
	
	initial begin 
		#`End_CYCLE;
		$display("================================================================================================================");
		$display("(/`n`)/ ~#  There is something wrong with your code!!"); 
		$display("Time out!! The simulation didn't finish after %d cycles!!, Please check it!!!", `End_CYCLE); 
		$display("================================================================================================================");
		$finish;
	end
endmodule
