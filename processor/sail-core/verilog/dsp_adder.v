module adder_dsp (
    input [31:0] input1, // 32-bit input1
    input [31:0] input2, // 32-bit input2
    input is_sub, // 0 for addition, 1 for subtraction
    output [31:0] out,    // 32-bit output
    output CO 
);
    // Using a DSP block to perform addition
    // The DSP block is configured to add two 16-bit numbers
    // input1[31:16] + input2[15:0] and input2[31:16] + input1[15:0]
    // The result is a 32-bit output

    wire [31:0] result;
    wire carry_out;

    SB_MAC16 mac_inst (
      .A(input1[31:16]),           
      .B(input2[15:0]),            
      .C(input2[31:16]),
      .D(input1[15:0]),
      .O(result),
      .CI(1'b0),             // No carry-in
      .CO(carry_out),        // Final carry-out from top adder
      .CLK(1'b0),
      .CE(1'b1),
      .IRSTTOP(1'b0), .IRSTBOT(1'b0),
      .ORSTTOP(1'b0), .ORSTBOT(1'b0),
      .OLOADTOP(1'b0), .OLOADBOT(1'b0),
      .OHOLDTOP(1'b0), .OHOLDBOT(1'b0),
      .AHOLD(1'b0), .BHOLD(1'b0),
      .CHOLD(1'b0), .DHOLD(1'b0),
      .ACCUMCI(1'b0), .ACCUMCO(),
      .SIGNEXTIN(1'b0), .SIGNEXTOUT(),
    .ADDSUBTOP(is_sub), .ADDSUBBOT(is_sub)  
    );

    defparam mac_inst.TOPOUTPUT_SELECT        = 2'b00; // direct output (Top Output Select: 00: Adder/Subtractor, not registered)
    defparam mac_inst.BOTOUTPUT_SELECT        = 2'b00; // direct output (Bottom Output Select:00: Adder/Subtractor, not registered)

    defparam mac_inst.TOPADDSUB_LOWERINPUT    = 2'b00; // A
    defparam mac_inst.TOPADDSUB_UPPERINPUT    = 1'b1;  // C
    defparam mac_inst.TOPADDSUB_CARRYSELECT   = 2'b00; // constant 0

    defparam mac_inst.BOTADDSUB_LOWERINPUT    = 2'b00; // B
    defparam mac_inst.BOTADDSUB_UPPERINPUT    = 1'b1;  // D
    defparam mac_inst.BOTADDSUB_CARRYSELECT   = 2'b00; // constant 0

    defparam mac_inst.MODE_8x8                = 1'b0;  // disable multiplier
    defparam mac_inst.A_SIGNED                = 1'b0;
    defparam mac_inst.B_SIGNED                = 1'b0;

    assign out = result;
    assign carry_out = CO;
endmodule