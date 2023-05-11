// Copyright (C) 2022 RapidSilicon
//5:20 PM
//Thursday, November 17, 2022

`default_nettype none
// ---------------------------------------- //
// ----- DSP cells simulation modules ----- //
// --------- Control bits in ports -------- //
// ---------------------------------------- //


module RS_DSP (
    input  wire [19:0] a,
    input  wire [17:0] b,
    input  wire [ 5:0] acc_fir,
    output wire [37:0] z,
    output wire [17:0] dly_b,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       lreset,

    input  wire [2:0] feedback,
    input  wire       load_acc,
    input  wire       unsigned_a,
    input  wire       unsigned_b,

    input  wire       saturate_enable,
    input  wire [5:0] shift_right,
    input  wire       round,
    input  wire       subtract
);

	//-- Aram -- register_inputs and output_select are part of MODE_BITS
    parameter [83:0] MODE_BITS = 84'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

    //Avinash//Aram// RS_DSP
    localparam [2:0] output_select = MODE_BITS[82:80];
    localparam register_inputs = MODE_BITS[83];

    localparam NBITS_ACC = 64;
    localparam NBITS_A = 20;
    localparam NBITS_B = 18;
    localparam NBITS_Z = 38;

    wire [NBITS_Z-1:0] dsp_full_z;
    wire [NBITS_B-1:0] dsp_full_dly_b;

    assign z = dsp_full_z;
    assign dly_b = dsp_full_dly_b;

    dsp_t1_sim_cfg_ports #(
        .NBITS_A(NBITS_A),
        .NBITS_B(NBITS_B),
        .NBITS_ACC(NBITS_ACC),
        .NBITS_Z(NBITS_Z)
    ) dsp_full (
        .a_i(a),
        .b_i(b),
        .z_o(dsp_full_z),
        .dly_b_o(dsp_full_dly_b),

        .acc_fir_i(acc_fir),
        .feedback_i(feedback),
        .load_acc_i(load_acc),

        .unsigned_a_i(unsigned_a),
        .unsigned_b_i(unsigned_b),

        .clock_i(clk),
        .s_reset(lreset),

        .saturate_enable_i(saturate_enable),
        .round_i(round),
        .shift_right_i(shift_right),
        .subtract_i(subtract),

        .output_select_i(output_select),
        .register_inputs_i(register_inputs),
        .coef_0_i(COEFF_0),
        .coef_1_i(COEFF_1),
        .coef_2_i(COEFF_2),
        .coef_3_i(COEFF_3)
    );
endmodule


module RS_DSP_MULT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    input  wire [2:0] feedback,
    input  wire       unsigned_a,
    input  wire       unsigned_b
);


    parameter [79:0] MODE_BITS = 80'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

    //Avinash// RS_DSP_MULT
    localparam [2:0] output_select = 3'b000;
    localparam register_inputs = 1'b0;

    RS_DSP #(
        .MODE_BITS({register_inputs, output_select, COEFF_3, COEFF_2, COEFF_1, COEFF_0})
    ) dsp (
        .a(a),
        .b(b),
        .z(z),
        .feedback(feedback),
        .unsigned_a(unsigned_a),
        .unsigned_b(unsigned_b)
    );
endmodule


module RS_DSP_MULT_REGIN (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       lreset,

    input  wire [2:0] feedback,
    input  wire       unsigned_a,
    input  wire       unsigned_b
);


    parameter [79:0] MODE_BITS = 80'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

    //Avinash// RS_DSP_MULT_REGIN
    localparam [2:0] output_select = 3'b000;
    localparam register_inputs = 1'b1;

    RS_DSP #(
        .MODE_BITS({register_inputs, output_select, COEFF_3, COEFF_2, COEFF_1, COEFF_0})
    ) dsp (
        .a(a),
        .b(b),
        .z(z),
        .feedback(feedback),
        .unsigned_a(unsigned_a),
        .unsigned_b(unsigned_b),
        .clk(clk),
        .lreset(lreset)
    );
endmodule


module RS_DSP_MULT_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       lreset,

    input  wire [2:0] feedback,
    input  wire       unsigned_a,
    input  wire       unsigned_b
);


    parameter [79:0] MODE_BITS = 80'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

   //Avinash// RS_DSP_MULT_REGOUT
    localparam [2:0] output_select = 3'b100;
    localparam register_inputs = 1'b0;

    RS_DSP #(
        .MODE_BITS({register_inputs, output_select, COEFF_3, COEFF_2, COEFF_1, COEFF_0})
    ) dsp (
        .a(a),
        .b(b),
        .z(z),
        .feedback(feedback),
        .unsigned_a(unsigned_a),
        .unsigned_b(unsigned_b),
        .clk(clk),
        .lreset(lreset)
    );
endmodule


module RS_DSP_MULT_REGIN_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       lreset,

    input  wire [2:0] feedback,
    input  wire       unsigned_a,
    input  wire       unsigned_b
);


    parameter [79:0] MODE_BITS = 80'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

    //Avinash// RS_DSP_MULT_REGIN_REGOUT
    localparam [2:0] output_select = 3'b100;
    localparam register_inputs = 1'b1;

    RS_DSP #(
        .MODE_BITS({register_inputs, output_select, COEFF_3, COEFF_2, COEFF_1, COEFF_0})
    ) dsp (
        .a(a),
        .b(b),
        .z(z),
        .feedback(feedback),
        .unsigned_a(unsigned_a),
        .unsigned_b(unsigned_b),
        .clk(clk),
        .lreset(lreset)
    );
endmodule


module RS_DSP_MULTADD (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    input  wire       clk,
    input  wire       lreset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract
);


    parameter [79:0] MODE_BITS = 80'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

    //Avinash// RS_DSP_MULTADD
    localparam [2:0] output_select = 3'b010;
    localparam register_inputs = 1'b0;

    RS_DSP #(
        .MODE_BITS({register_inputs, output_select, COEFF_3, COEFF_2, COEFF_1, COEFF_0})
    ) dsp (
        .a(a),
        .b(b),
        .z(z),
        .feedback(feedback),
        .acc_fir(acc_fir),
        .load_acc(load_acc),
        .unsigned_a(unsigned_a),
        .unsigned_b(unsigned_b),
        .clk(clk),
        .lreset(lreset),
        .saturate_enable(saturate_enable),
        .shift_right(shift_right),
        .round(round),
        .subtract(subtract)
    );
endmodule



module RS_DSP_MULTADD_REGIN (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract
);


    parameter [79:0] MODE_BITS = 80'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

  //Avinash// RS_DSP_MULTADD_REGIN
     localparam [2:0] output_select = 3'b010;
     localparam register_inputs = 1'b1;


    RS_DSP #(
        .MODE_BITS({register_inputs, output_select, COEFF_3, COEFF_2, COEFF_1, COEFF_0})
    ) dsp (
        .a(a),
        .b(b),
        .z(z),
        .feedback(feedback),
        .acc_fir(acc_fir),
        .load_acc(load_acc),
        .unsigned_a(unsigned_a),
        .unsigned_b(unsigned_b),
        .clk(clk),
        .lreset(lreset),
        .saturate_enable(saturate_enable),
        .shift_right(shift_right),
        .round(round),
        .subtract(subtract)
    );
endmodule



module RS_DSP_MULTADD_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract
);

    parameter [79:0] MODE_BITS = 80'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

 //Avinash// RS_DSP_MULTADD_REGOUT
    localparam [2:0] output_select = 3'b110;
    localparam register_inputs = 1'b0;

    RS_DSP #(
        .MODE_BITS({register_inputs, output_select, COEFF_3, COEFF_2, COEFF_1, COEFF_0})
    ) dsp (
        .a(a),
        .b(b),
        .z(z),
        .feedback(feedback),
        .acc_fir(acc_fir),
        .load_acc(load_acc),
        .unsigned_a(unsigned_a),
        .unsigned_b(unsigned_b),
        .clk(clk),
        .lreset(lreset),
        .saturate_enable(saturate_enable),
        .shift_right(shift_right),
        .round(round),
        .subtract(subtract)
    );
endmodule



module RS_DSP_MULTADD_REGIN_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract
);


    parameter [79:0] MODE_BITS = 80'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

    //Avinash// RS_DSP_MULTADD_REGIN_REGOUT
    localparam [2:0] output_select = 3'b110;
    localparam register_inputs = 1'b1;

    RS_DSP #(
        .MODE_BITS({register_inputs, output_select, COEFF_3, COEFF_2, COEFF_1, COEFF_0})
    ) dsp (
        .a(a),
        .b(b),
        .z(z),
        .feedback(feedback),
        .acc_fir(acc_fir),
        .load_acc(load_acc),
        .unsigned_a(unsigned_a),
        .unsigned_b(unsigned_b),

        .clk(clk),
        .lreset(lreset),

        .saturate_enable(saturate_enable),
        .shift_right(shift_right),
        .round(round),
        .subtract(subtract)
    );
endmodule


module RS_DSP_MULTACC (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire        load_acc,
    input  wire [ 2:0] feedback,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract
);
    parameter [79:0] MODE_BITS = 80'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

    //Avinash// RS_DSP_MULTACC
    localparam [2:0] output_select = 3'b001;
    localparam register_inputs = 1'b0;

    RS_DSP #(
        .MODE_BITS({register_inputs, output_select, COEFF_3, COEFF_2, COEFF_1, COEFF_0})
    ) dsp (
        .a(a),
        .b(b),
        .z(z),
        .feedback(feedback),
        .load_acc(load_acc),
        .unsigned_a(unsigned_a),
        .unsigned_b(unsigned_b),
        .clk(clk),
        .lreset(lreset),
        .saturate_enable(saturate_enable),
        .shift_right(shift_right),
        .round(round),
        .subtract(subtract)
    );
endmodule


module RS_DSP_MULTACC_REGIN (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire [ 2:0] feedback,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract
);


    parameter [79:0] MODE_BITS = 80'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

    //Avinash// RS_DSP_MULTACC_REGIN
    localparam [2:0] output_select = 3'b001;
    localparam register_inputs = 1'b1;

    RS_DSP #(
        .MODE_BITS({register_inputs, output_select, COEFF_3, COEFF_2, COEFF_1, COEFF_0})
    ) dsp (
        .a(a),
        .b(b),
        .z(z),
        .feedback(feedback),
        .load_acc(load_acc),

        .unsigned_a(unsigned_a),
        .unsigned_b(unsigned_b),

        .clk(clk),
        .lreset(lreset),

        .saturate_enable(saturate_enable),
        .shift_right(shift_right),
        .round(round),
        .subtract(subtract)
    );
endmodule



module RS_DSP_MULTACC_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire [ 2:0] feedback,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract
);


    parameter [79:0] MODE_BITS = 80'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

   //Avinash// RS_DSP_MULTACC_REGOUT
    localparam [2:0] output_select = 3'b101;
    localparam register_inputs = 1'b0;

    RS_DSP #(
        .MODE_BITS({register_inputs, output_select, COEFF_3, COEFF_2, COEFF_1, COEFF_0})
    ) dsp (
        .a(a),
        .b(b),
        .z(z),
        .feedback(feedback),
        .load_acc(load_acc),

        .unsigned_a(unsigned_a),
        .unsigned_b(unsigned_b),

        .clk(clk),
        .lreset(lreset),

        .saturate_enable(saturate_enable),
        .shift_right(shift_right),
        .round(round),
        .subtract(subtract)
    );
endmodule



module RS_DSP_MULTACC_REGIN_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        lreset,

    input  wire [ 2:0] feedback,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract
);


    parameter [79:0] MODE_BITS = 80'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

   //Avinash// RS_DSP_MULTACC_REGIN_REGOUT
    localparam [2:0] output_select = 3'b101;
    localparam register_inputs = 1'b1;

    RS_DSP #(
        .MODE_BITS({register_inputs, output_select, COEFF_3, COEFF_2, COEFF_1, COEFF_0})
    ) dsp (
        .a(a),
        .b(b),
        .z(z),

        .feedback(feedback),
        .load_acc(load_acc),

        .unsigned_a(unsigned_a),
        .unsigned_b(unsigned_b),

        .clk(clk),
        .lreset(lreset),

        .saturate_enable(saturate_enable),
        .shift_right(shift_right),
        .round(round),
        .subtract(subtract)
    );
endmodule

module dsp_t1_20x18x64_cfg_ports (
    input  wire [19:0] a_i,
    input  wire [17:0] b_i,
    input  wire [ 5:0] acc_fir_i,
    output wire [37:0] z_o,
    output wire [17:0] dly_b_o,

    (* clkbuf_sink *)
    input  wire        clock_i,
    input  wire        reset_i,

    input  wire [ 2:0] feedback_i,
    input  wire        load_acc_i,
    input  wire        unsigned_a_i,
    input  wire        unsigned_b_i,

    //input  wire [ 2:0] output_select_i,
    input  wire        saturate_enable_i,
    input  wire [ 5:0] shift_right_i,
    input  wire        round_i,
    input  wire        subtract_i
    //input  wire        register_inputs_i
);

    parameter [19:0] COEFF_0 = 20'd0;
    parameter [19:0] COEFF_1 = 20'd0;
    parameter [19:0] COEFF_2 = 20'd0;
    parameter [19:0] COEFF_3 = 20'd0;
    parameter [2:0] OUTPUT_SELECT = 3'b000;
    parameter REGISTER_INPUTS = 1'b0;

    RS_DSP #(
        .MODE_BITS({REGISTER_INPUTS, 
                    OUTPUT_SELECT, 
                    COEFF_3, 
                    COEFF_2, 
                    COEFF_1, 
                    COEFF_0})
    ) dsp (
        .a(a_i),
        .b(b_i),
        .z(z_o),
        .dly_b(dly_b_o),

        .acc_fir(acc_fir_i),
        .feedback(feedback_i),
        .load_acc(load_acc_i),

        .unsigned_a(unsigned_a_i),
        .unsigned_b(unsigned_b_i),

        .clk(clock_i),
        .lreset(reset_i),

        .saturate_enable(saturate_enable_i),
        .round(round_i),
        .shift_right(shift_right_i),
        .subtract(subtract_i)
    );
endmodule


module dsp_t1_sim_cfg_ports # (
    parameter NBITS_ACC  = 64,
    parameter NBITS_A    = 20,
    parameter NBITS_B    = 18,
    parameter NBITS_Z    = 38
)(
    input  wire [NBITS_A-1:0] a_i,
    input  wire [NBITS_B-1:0] b_i,
    output wire [NBITS_Z-1:0] z_o,
    output reg  [NBITS_B-1:0] dly_b_o,

    input  wire [5:0]         acc_fir_i,
    input  wire [2:0]         feedback_i,
    input  wire               load_acc_i,

    input  wire               unsigned_a_i,
    input  wire               unsigned_b_i,

    input  wire               clock_i,
    input  wire               s_reset,

    input  wire               saturate_enable_i,
    input  wire [2:0]         output_select_i,
    input  wire               round_i,
    input  wire [5:0]         shift_right_i,
    input  wire               subtract_i,
    input  wire               register_inputs_i,
    input  wire [NBITS_A-1:0] coef_0_i,
    input  wire [NBITS_A-1:0] coef_1_i,
    input  wire [NBITS_A-1:0] coef_2_i,
    input  wire [NBITS_A-1:0] coef_3_i
);

// FIXME: The version of Icarus Verilog from Conda seems not to recognize the
// $error macro. Disable this sanity check for now because of that.
`ifndef __ICARUS__
    if (NBITS_ACC < NBITS_A + NBITS_B) begin
        initial begin
            $error("NBITS_ACC must be > NBITS_A + NBITS_B");
        end
    end
`endif

    // Input registers
    reg  [NBITS_A-1:0]  r_a;
    reg  [NBITS_B-1:0]  r_b;
    reg  [5:0]          r_acc_fir;
    reg                 r_unsigned_a;
    reg                 r_unsigned_b;
    reg                 r_load_acc;
    reg  [2:0]          r_feedback;
    reg  [5:0]          r_shift_d1;
    reg  [5:0]          r_shift_d2;
    reg         r_subtract;
    reg         r_sat;
    reg         r_rnd;
    reg [NBITS_ACC-1:0] acc;

    initial begin
        r_a          <= 0;
        r_b          <= 0;

        r_acc_fir    <= 0;
        r_unsigned_a <= 0;
        r_unsigned_b <= 0;
        r_feedback   <= 0;
        r_shift_d1   <= 0;
        r_shift_d2   <= 0;
        r_subtract   <= 0;
        r_load_acc   <= 0;
        r_sat        <= 0;
        r_rnd        <= 0;
    end

    always @(posedge clock_i or posedge s_reset) begin
        if (s_reset) begin

            r_a <= 'h0;
            r_b <= 'h0;

            r_acc_fir    <= 0;
            r_unsigned_a <= 0;
            r_unsigned_b <= 0;
            r_feedback   <= 0;
            r_shift_d1   <= 0;
            r_shift_d2   <= 0;
            r_subtract   <= 0;
            r_load_acc   <= 0;
            r_sat    <= 0;
            r_rnd    <= 0;

        end else begin

            r_a <= a_i;
            r_b <= b_i;

            r_acc_fir    <= acc_fir_i;
            r_unsigned_a <= unsigned_a_i;
            r_unsigned_b <= unsigned_b_i;
            r_feedback   <= feedback_i;
            r_shift_d1   <= shift_right_i;
            r_shift_d2   <= r_shift_d1;
            r_subtract   <= subtract_i;
            r_load_acc   <= load_acc_i;
            r_sat    <= r_sat;
            r_rnd    <= r_rnd;

        end
    end

    // Registered / non-registered input path select
    wire [NBITS_A-1:0]  a = register_inputs_i ? r_a : a_i;
    wire [NBITS_B-1:0]  b = register_inputs_i ? r_b : b_i;

    wire [5:0] acc_fir = register_inputs_i ? r_acc_fir : acc_fir_i;
    wire       unsigned_a = register_inputs_i ? r_unsigned_a : unsigned_a_i;
    wire       unsigned_b = register_inputs_i ? r_unsigned_b : unsigned_b_i;
    wire [2:0] feedback   = register_inputs_i ? r_feedback   : feedback_i;
    wire       load_acc   = register_inputs_i ? r_load_acc   : load_acc_i;
    wire       subtract   = register_inputs_i ? r_subtract   : subtract_i;
    wire       sat    = register_inputs_i ? r_sat : saturate_enable_i;
    wire       rnd    = register_inputs_i ? r_rnd : round_i;

    // Shift right control
    wire [5:0] shift_d1 = register_inputs_i ? r_shift_d1 : shift_right_i;
    wire [5:0] shift_d2 = output_select_i[1] ? shift_d1 : r_shift_d2;

    // Multiplier
    wire unsigned_mode = unsigned_a & unsigned_b;
    wire [NBITS_A-1:0] mult_a;
    assign mult_a = (feedback == 3'h0) ?   a :
                    (feedback == 3'h1) ?   a :
                    (feedback == 3'h2) ?   a :
                    (feedback == 3'h3) ?   acc[NBITS_A-1:0] :
                    (feedback == 3'h4) ?   coef_0_i :
                    (feedback == 3'h5) ?   coef_1_i :
                    (feedback == 3'h6) ?   coef_2_i :
                       coef_3_i;    // if feedback == 3'h7

    wire [NBITS_B-1:0] mult_b = (feedback == 2'h2) ? {NBITS_B{1'b0}}  : b;

    wire [NBITS_A-1:0] mult_sgn_a = mult_a[NBITS_A-1];
    wire [NBITS_A-1:0] mult_mag_a = (mult_sgn_a && !unsigned_a) ? (~mult_a + 1) : mult_a;
    wire [NBITS_B-1:0] mult_sgn_b = mult_b[NBITS_B-1];
    wire [NBITS_B-1:0] mult_mag_b = (mult_sgn_b && !unsigned_b) ? (~mult_b + 1) : mult_b;

    wire [NBITS_A+NBITS_B-1:0] mult_mag = mult_mag_a * mult_mag_b;
    wire mult_sgn = (mult_sgn_a && !unsigned_a) ^ (mult_sgn_b && !unsigned_b);

    wire [NBITS_A+NBITS_B-1:0] mult = (unsigned_a && unsigned_b) ?
        (mult_a * mult_b) : (mult_sgn ? (~mult_mag + 1) : mult_mag);

    // Sign extension
    wire [NBITS_ACC-1:0] mult_xtnd = unsigned_mode ?
        {{(NBITS_ACC-NBITS_A-NBITS_B){1'b0}},                    mult[NBITS_A+NBITS_B-1:0]} :
        {{(NBITS_ACC-NBITS_A-NBITS_B){mult[NBITS_A+NBITS_B-1]}}, mult[NBITS_A+NBITS_B-1:0]};

    // Adder
    wire [NBITS_ACC-1:0] acc_fir_int = unsigned_a ? {{(NBITS_ACC-NBITS_A){1'b0}},         a} :
                                                    {{(NBITS_ACC-NBITS_A){a[NBITS_A-1]}}, a} ;

    wire [NBITS_ACC-1:0] add_a = (subtract) ? (~mult_xtnd + 1) : mult_xtnd;
    wire [NBITS_ACC-1:0] add_b = (feedback_i == 3'h0) ? acc :
                                 (feedback_i == 3'h1) ? {{NBITS_ACC}{1'b0}} : (acc_fir_int << acc_fir);

    wire [NBITS_ACC-1:0] add_o = add_a + add_b;

    // Accumulator
    initial acc <= 0;

    always @(posedge clock_i or posedge s_reset)
        if (s_reset) acc <= 'h0;
        else begin
            if (load_acc)
                acc <= add_o;
            else
                acc <= acc;
        end

    // Adder/accumulator output selection
    wire [NBITS_ACC-1:0] acc_out = (output_select_i[1]) ? add_o : acc;

    // Round, shift, saturate
    wire signed [NBITS_ACC-1:0] acc_rnd = (rnd && (shift_right_i != 0)) ? (acc_out + ({{(NBITS_ACC-1){1'b0}}, 1'b1} << (shift_right_i - 1))) :
                                                                    acc_out;

    wire [NBITS_ACC-1:0] acc_shr = (unsigned_mode) ? (acc_rnd  >> shift_right_i) :
                                                     (acc_rnd >>> shift_right_i);

    wire [NBITS_ACC-1:0] acc_sat_u = (acc_shr[NBITS_ACC-1:NBITS_Z] != 0) ? {{(NBITS_ACC-NBITS_Z){1'b0}},{NBITS_Z{1'b1}}} :
                                                                           {{(NBITS_ACC-NBITS_Z){1'b0}},{acc_shr[NBITS_Z-1:0]}};

    wire [NBITS_ACC-1:0] acc_sat_s = ((|acc_shr[NBITS_ACC-1:NBITS_Z-1] == 1'b0) ||
                                      (&acc_shr[NBITS_ACC-1:NBITS_Z-1] == 1'b1)) ? {{(NBITS_ACC-NBITS_Z){1'b0}},{acc_shr[NBITS_Z-1:0]}} :
                                                                                   {{(NBITS_ACC-NBITS_Z){1'b0}},{acc_shr[NBITS_ACC-1],{NBITS_Z-1{~acc_shr[NBITS_ACC-1]}}}};

    wire [NBITS_ACC-1:0] acc_sat = (sat) ? ((unsigned_mode) ? acc_sat_u : acc_sat_s) : acc_shr;

    // Output signals
    wire [NBITS_Z-1:0]  z0;
    reg  [NBITS_Z-1:0]  z1;
    wire [NBITS_Z-1:0]  z2;

    assign z0 = mult_xtnd[NBITS_Z-1:0];
    assign z2 = acc_sat[NBITS_Z-1:0];

    initial z1 <= 0;

    always @(posedge clock_i or posedge s_reset)
        if (s_reset)
            z1 <= 0;
        else begin
            z1 <= (output_select_i == 3'b100) ? z0 : z2;
        end

    // Output mux
    assign z_o = (output_select_i == 3'h0) ?   z0 :
                 (output_select_i == 3'h1) ?   z2 :
                 (output_select_i == 3'h2) ?   z2 :
                 (output_select_i == 3'h3) ?   z2 :
                 (output_select_i == 3'h4) ?   z1 :
                 (output_select_i == 3'h5) ?   z1 :
                 (output_select_i == 3'h6) ?   z1 :
                           z1;  // if output_select_i == 3'h7

    // B input delayed passthrough
    initial dly_b_o <= 0;

    always @(posedge clock_i or posedge s_reset)
        if (s_reset)
            dly_b_o <= 0;
        else
            dly_b_o <= b_i;

endmodule