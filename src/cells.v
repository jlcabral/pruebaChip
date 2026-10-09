/*
This file provides the mapping from the Wokwi modules to Verilog HDL.

It's only needed for Wokwi designs.
*/

`define default_netname none

(* keep_hierarchy *)
module buffer_cell (
    input wire in,
    output wire out
    );
    assign out = in;
endmodule

(* keep_hierarchy *)
module and_cell (
    input wire a,
    input wire b,
    output wire out
    );

    assign out = a & b;
endmodule

(* keep_hierarchy *)
module or_cell (
    input wire a,
    input wire b,
    output wire out
    );

    assign out = a | b;
endmodule

(* keep_hierarchy *)
module xor_cell (
    input wire a,
    input wire b,
    output wire out
    );

    assign out = a ^ b;
endmodule

(* keep_hierarchy *)
module nand_cell (
    input wire a,
    input wire b,
    output wire out
    );

    assign out = !(a&b);
endmodule

(* keep_hierarchy *)
module nor_cell (
    input wire a,
    input wire b,
    output wire out
    );

    assign out = !(a | b);
endmodule

(* keep_hierarchy *)
module xnor_cell (
    input wire a,
    input wire b,
    output wire out
    );

    assign out = !(a ^ b);
endmodule

(* keep_hierarchy *)
module not_cell (
    input wire in,
    output wire out
    );

    assign out = !in;
endmodule

(* keep_hierarchy *)
module mux_cell (
    input wire a,
    input wire b,
    input wire sel,
    output wire out
    );

    assign out = sel ? b : a;
endmodule

(* keep_hierarchy *)
module dff_cell (
    input wire clk,
    input wire d,
    output reg q,
    output wire notq
    );

    assign notq = !q;
    always @(posedge clk)
        q <= d;

endmodule

(* keep_hierarchy *)
module dffr_cell (
    input wire clk,
    input wire d,
    input wire r,
    output reg q,
    output wire notq
    );

    assign notq = !q;

    always @(posedge clk or posedge r) begin
        if (r)
            q <= 0;
        else
            q <= d;
    end
endmodule

(* keep_hierarchy *)
module dffsr_cell (
    input wire clk,
    input wire d,
    input wire s,
    input wire r,
    output reg q,
    output wire notq
    );

    assign notq = !q;

    always @(posedge clk or posedge s or posedge r) begin
        if (r)
            q <= 0;
        else if (s)
            q <= 1;
        else
            q <= d;
    end
endmodule

module wokwi (
    input  wire IN0,
    input  wire IN1,
    input  wire IN2,
    input  wire IN3,
    input  wire IN4,
    input  wire IN5,
    input  wire IN6,
    input  wire IN7,
    output wire OUT0,
    output wire OUT1,
    output wire OUT2,
    output wire OUT3,
    output wire OUT4,
    output wire OUT5,
    output wire OUT6,
    output wire OUT7
);
    wire [7:0] in_a= {IN7,IN6,IN5,IN4,IN3,IN2,IN1,IN0};
    wire [7:0] out_x;
    // Intermediate round values
    wire [7:0] r1_xor, r1_add, r1_out;
    wire [7:0] r2_xor, r2_add, r2_out;
    wire [7:0] r3_xor, r3_add, r3_out;
    wire [7:0] r4_xor, r4_add, r4_out;

    // ---------------------------------------------------------
    // Round 1
    // x = xorshift_left(x, 1) -> x ^ (x << 1)
    // x = x + 0xA7
    // x = rol8(x, 3)
    // ---------------------------------------------------------
    assign r1_xor = in_a ^ (in_a << 1);
    assign r1_add = r1_xor + 8'hA7;
    assign r1_out = {r1_add[4:0], r1_add[7:5]};

    // ---------------------------------------------------------
    // Round 2
    // x = xorshift_right(x, 2) -> x ^ (x >> 2)
    // x = x + 0x3D
    // x = ror8(x, 5)
    // ---------------------------------------------------------
    assign r2_xor = r1_out ^ (r1_out >> 2);
    assign r2_add = r2_xor + 8'h3D;
    assign r2_out = {r2_add[4:0], r2_add[7:5]}; // ROR 5 is equivalent to ROL 3

    // ---------------------------------------------------------
    // Round 3
    // x = xorshift_left(x, 3) -> x ^ (x << 3)
    // x = x + 0x6B
    // x = rol8(x, 2)
    // ---------------------------------------------------------
    assign r3_xor = r2_out ^ (r2_out << 3);
    assign r3_add = r3_xor + 8'h6B;
    assign r3_out = {r3_add[5:0], r3_add[7:6]};

    // ---------------------------------------------------------
    // Round 4
    // x = xorshift_right(x, 1) -> x ^ (x >> 1)
    // x = x + 0xD5
    // x = ror8(x, 3)
    // ---------------------------------------------------------
    assign r4_xor = r3_out ^ (r3_out >> 1);
    assign r4_add = r4_xor + 8'hD5;
    assign r4_out = {r4_add[2:0], r4_add[7:3]}; // ROR 3

    assign out_x = r4_out;
    assign {OUT7,OUT6,OUT5,OUT4,OUT3,OUT2,OUT1,OUT0} = out_x[7:0];

endmodule
