module rgb_min(
    input  [7:0] r, g, b,
    output [7:0] min_rgb
);
    wire [7:0] rg_min;
    assign rg_min  = (r < g) ? r : g;
    assign min_rgb = (rg_min < b) ? rg_min : b;
endmodule