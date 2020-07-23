	//behavior tb
`timescale 1ns/10ps
`define CYCLE1	10.00
`define CYCLE2	3.00
`define End_CYCLE  100000            // Modify cycle times once your design need more cycle times!
`define SDFFILE     "./async_fifo_syn.sdf"

module async_fifo_unit_test;

    integer i;

    parameter DSIZE = 16; // 16 bits
    parameter ASIZE = 8;  //2**8=256 words

    reg              wclk;
    reg              wrst_n;
    reg              winc;
    reg  [DSIZE-1:0] wdata;
    wire             wfull;
    wire             awfull;
    reg              rclk;
    reg              rrst_n;
    reg              rinc;
    wire [DSIZE-1:0] rdata;
    wire             rempty;
    wire             arempty;

    async_fifo  dut //#(DSIZE,ASIZE) dut 
    (
		wclk,
		wrst_n,
		winc,
		wdata,
		wfull,
		awfull,
		rclk,
		rrst_n,
		rinc,
		rdata,
		rempty,
		arempty
    );
	
	parameter 	num_tries = 1000;
	reg [DSIZE-1:0]	   fifo_in 	[num_tries-1:0];
	reg [DSIZE-1:0]	   fifo_out [num_tries-1:0];
	
	integer freq1, freq2;
	

	`ifdef SDF
	   initial $sdf_annotate(`SDFFILE, dut );
	`endif

    // waveform dump
    initial begin
        $fsdbDumpfile("async_fifo.fsdb" );
        $fsdbDumpvars(0, async_fifo_unit_test, "+mda");
    end
        
    // clock
    initial begin
        rclk = 1'b0;
        forever #(`CYCLE1*0.5) rclk = ~rclk;
    end
    initial begin
        wclk = 1'b0;
        forever #(`CYCLE2*0.5) wclk = ~wclk;
	end
	
	wire	last_rd, last_wr;
	reg		wr_success, rd_success, wen, ren, wr_done, rd_done, start;
	integer err_cnt, wr_count, rd_count;
	
	///////////////////////////TASK DEFINITION////////////////////////////////	
    task setup();
    begin
		wr_count = 0;
		rd_count = 0;
		wen = 0;
		ren = 0;
		wr_done = 0;
		rd_done = 0;
		start = 0;
		err_cnt = 0;		
        wrst_n = 1'b0;
        winc = 1'b0;
        wdata = 0;
        rrst_n = 1'b0;
        rinc = 1'b0;
		`ifdef PAT2
			freq1 = 5;
			freq2 = 10;
		`elsif PAT3
			freq1 = 1;
			freq2 = 10;
		`else
			freq1 = 3;
			freq2 = 10;
		`endif
        #(10*`CYCLE1);
        wrst_n = 1;
        rrst_n = 1;
        #(20*`CYCLE1);
		start = 1;
    end
    endtask
	
	
	// Write to FIFO if not full and wen
	always@(negedge wclk) begin
		wr_success = 0;
		winc = 0;
		if(!wfull && wen) begin
			wr_success = 1;
			winc = 1;
			wdata = $urandom % (2**DSIZE);
			fifo_in[wr_count] = wdata;
			wr_count = wr_count+1;
		end
	end
	
	// Read from FIFO if not empty and ren
	always@(negedge rclk) begin
		if(rinc) begin
			fifo_out[rd_count] = rdata;
			rd_count = rd_count+1;
		end
		rd_success = 0;
		rinc = 0;
		if(!rempty && ren) begin
			rinc = 1;
			rd_success = 1;
		end
	end
	
    initial begin
		setup;
	end
	
    initial begin	
		wait(start);	
		//Randomly writes "num_tries" data
		while(wr_count<num_tries) begin
			@(posedge wclk) 
			wen = (($urandom %20)<freq1);
		end
		wen = 0;
		wr_done = 1;
	end
	
    initial begin	
		wait(start);
		
		while(rd_count<num_tries) begin
			@(posedge rclk) 
			ren = (($urandom %20)<freq2);
		end
		ren = 0;
		rd_done = 1;
	end
	
	
	//////////////////////////////////VERIFICATION////////////////////////////////////////
    initial begin
	
		wait(start);
		
		wait(rd_done==1 && wr_done == 1);
		
		if(rd_count != wr_count) begin
			$display(" The number of writes and reads are not equal ! Writes = %d, but Reads = %d !! ", wr_count, rd_count);
			err_cnt = err_cnt + 1; 
			#0.001;
		end
		
		for(i = 0; i < rd_count; i=i+1) begin
			if (!(fifo_out[i]===fifo_in[i])) begin
				$display(" Pattern %d failed ! FIFO input = %d, but FIFO output = %d !! ", i, fifo_in[i], fifo_out[i]);
				err_cnt = err_cnt + 1; 
				#0.001;
			end else begin
				$display("Pattern %d is passed ! FIFO input = %d, FIFO output = %d !!", i, fifo_in[i], fifo_out[i]);
			end
		end
				
		#(`CYCLE1*10); 
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
