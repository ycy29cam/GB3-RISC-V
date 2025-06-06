/*
 *		Branch Predictor FSM
 */

// module branch_predictor(
// 		clk,
// 		actual_branch_decision,
// 		branch_decode_sig,
// 		branch_mem_sig,
// 		in_addr,
// 		offset,
// 		branch_addr,
// 		prediction
// 	);

// 	/*
// 	 *	inputs
// 	 */
// 	input		clk;
// 	input		actual_branch_decision;
// 	input		branch_decode_sig;
// 	input		branch_mem_sig;
// 	input [31:0]	in_addr;
// 	input [31:0]	offset;

// 	/*
// 	 *	outputs
// 	 */
// 	output [31:0]	branch_addr;
// 	output		prediction;

// 	/*
// 	 *	internal state
// 	 */
// 	reg [1:0]	s;

// 	reg		branch_mem_sig_reg;

// 	/*
// 	 *	The `initial` statement below uses Yosys's support for nonzero
// 	 *	initial values:
// 	 *
// 	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
// 	 *
// 	 *	Rather than using this simulation construct (`initial`),
// 	 *	the design should instead use a reset signal going to
// 	 *	modules in the design and to thereby set the values.
// 	 */
// 	initial begin
// 		s = 2'b00;
// 		branch_mem_sig_reg = 1'b0;
// 	end

// 	always @(negedge clk) begin
// 		branch_mem_sig_reg <= branch_mem_sig;
// 	end

// 	/*
// 	 *	Using this microarchitecture, branches can't occur consecutively
// 	 *	therefore can use branch_mem_sig as every branch is followed by
// 	 *	a bubble, so a 0 to 1 transition
// 	 */
// 	always @(posedge clk) begin
// 		if (branch_mem_sig_reg) begin
// 			s[1] <= (s[1]&s[0]) | (s[0]&actual_branch_decision) | (s[1]&actual_branch_decision);
// 			s[0] <= (s[1]&(!s[0])) | ((!s[0])&actual_branch_decision) | (s[1]&actual_branch_decision);
// 		end
// 	end
	
// 	assign branch_addr = in_addr + offset;
// 	assign prediction = s[1] & branch_decode_sig;
// endmodule



// Improved branch predictor with 256‑entry 2‑bit BHT
// (minimal changes to ports; simulation sections kept intact)


module branch_predictor(
        clk,
        actual_branch_decision,
        branch_decode_sig,
        branch_mem_sig,
        in_addr,
        offset,
        branch_addr,
        prediction
    );

    /*
     *  inputs
     */
    input       clk;
    input       actual_branch_decision;
    input       branch_decode_sig;
    input       branch_mem_sig;
    input [31:0] in_addr;
    input [31:0] offset;

    /*
     *  outputs
     */
    output [31:0]    branch_addr;
    output          prediction;

    /*
     *  internal state
     */
    // 2‑bit saturating counter that holds the *current* prediction value
    // for the branch in the DECODE stage – keeps the simulation code intact.

    // One‑cycle delayed MEM‑stage branch signal (unchanged)
    reg       branch_mem_sig_reg;

    // 256‑entry Branch History Table – indexed by bits [9:2] of the PC
    reg  [1:0] bht [0:255];
    wire [7:0] index = in_addr[9:2];

    // Remember the table entry belonging to the branch that is currently
    // flowing down the pipeline so we can update it in MEM.
    reg  [7:0] commit_index;

    // Latch the prediction of the branch when it is in DECODE so the
    // simulator can check it later in MEM.
    reg        predicted_taken_reg;

`ifdef SIMULATION
    // Simple statistics counters – unchanged except for using the new
    // registered prediction value.
    reg [31:0] total_branches;
    reg [31:0] correct_predictions;
    initial begin
        total_branches        = 32'd0;
        correct_predictions   = 32'd0;
    end
`endif

    /*------------------------------------------------------------
     *  Reset / initialisation (kept – note about Yosys remains)
     *----------------------------------------------------------*/
    integer i;
    initial begin
        branch_mem_sig_reg = 1'b0;
        // Initialise the whole BHT to 2'b00 (strong NOT‑TAKEN)
        for (i = 0; i < 256; i = i + 1) begin
            bht[i] = 2'b00;
        end
    end

    /*------------------------------------------------------------
     *  Pipeline bookkeeping
     *----------------------------------------------------------*/
    // MEM‑stage signal delay (unchanged)
    always @(negedge clk) begin
        branch_mem_sig_reg <= branch_mem_sig;
    end

    // Capture the index and the *current* prediction when the branch is in
    // DECODE.  This is a single outstanding branch because the pipeline
    // inserts a bubble after every branch.
    always @(posedge clk) begin
        if (branch_decode_sig) begin
            commit_index        <= index;
            predicted_taken_reg <= bht[index][1];
        end
    end

    /*------------------------------------------------------------
     *  Update rule for the 2‑bit saturating counter in MEM
     *----------------------------------------------------------*/
    always @(posedge clk) begin
        if (branch_mem_sig_reg) begin
            if (actual_branch_decision) begin  // branch **taken**
                if (bht[commit_index] != 2'b11)
                    bht[commit_index] <= bht[commit_index] + 2'b01;
            end else begin                     // branch **not taken**
                if (bht[commit_index] != 2'b00)
                    bht[commit_index] <= bht[commit_index] - 2'b01;
            end
        end
    end

`ifdef SIMULATION
    /*
     *  Simple accuracy counters (unchanged apart from using the new
     *  registered prediction value).
     */
    always @(posedge clk) begin
        if (branch_mem_sig_reg) begin
            total_branches <= total_branches + 1;
            if (predicted_taken_reg == actual_branch_decision)
                correct_predictions <= correct_predictions + 1;
        end
    end
`endif

    /*------------------------------------------------------------
     *  Outputs
     *----------------------------------------------------------*/
    assign branch_addr = in_addr + offset;
    // Use the BHT entry for the *current* PC to form the decode‑stage
    // prediction.  The extra AND keeps the original hand‑shake with the
    // outside world unchanged.
    assign prediction  = bht[index][1] & branch_decode_sig;

endmodule