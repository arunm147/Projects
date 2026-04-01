module top_dehaze (
    input clk,
    input rst,

    input  [7:0] r_in,
    input  [7:0] g_in,
    input  [7:0] b_in,
    input        valid_in,

    output [7:0] r_out,
    output [7:0] g_out,
    output [7:0] b_out,
    output       valid_out
);

    // -----------------------------
    // Internal signals
    // -----------------------------
    wire [7:0] min_rgb;

    wire [7:0] dark_pixel;
    wire       valid_dark;

    wire [7:0] A_r, A_g, A_b;

    wire [15:0] t_out;
    wire        valid_trans;

    wire [7:0] J_r, J_g, J_b;
    wire       valid_scene;

    wire        frame_end;

    // -----------------------------
    // RGB MIN
    // -----------------------------
    rgb_min u_min (
        .r(r_in),
        .g(g_in),
        .b(b_in),
        .min_rgb(min_rgb)
    );

    // -----------------------------
    // DARK CHANNEL
    // -----------------------------
    dark_channel_5x5 #(.IMG_WIDTH(256)) u_dcp (
        .clk(clk),
        .rst(rst),
        .min_rgb(min_rgb),
        .valid_in(valid_in),
        .dark_pixel(dark_pixel),
        .valid_out(valid_dark)
    );

    // -----------------------------
    // FRAME COUNTER
    // -----------------------------
    reg [31:0] pixel_count;

    always @(posedge clk) begin
        if (rst)
            pixel_count <= 0;
        else if (valid_in && pixel_count < 65536)
            pixel_count <= pixel_count + 1;
    end

    assign frame_end = (pixel_count == 65536);

    // -----------------------------
    // ATMOSPHERIC LIGHT
    // -----------------------------
    atmospheric_light u_atm (
        .clk(clk),
        .rst(rst),

        .dark_pixel(dark_pixel),
        .r(r_in),
        .g(g_in),
        .b(b_in),
        .valid_dark(valid_dark),

        .frame_end(frame_end),

        .A_r(A_r),
        .A_g(A_g),
        .A_b(A_b)
    );

    // -----------------------------
    // TRANSMISSION MAP
    // -----------------------------
    transmission_map u_trans (
        .clk(clk),
        .rst(rst),

        .dark_pixel(dark_pixel),
        .A_r(A_r),
        .A_g(A_g),
        .A_b(A_b),

        .valid_in(valid_dark),

        .t_out(t_out),
        .valid_out(valid_trans)
    );

    // -----------------------------
    // SCENE RADIANCE
    // -----------------------------
    scene_radiance u_scene (
        .clk(clk),
        .rst(rst),

        .r(r_in),
        .g(g_in),
        .b(b_in),

        .A_r(A_r),
        .A_g(A_g),
        .A_b(A_b),

        .t_in(t_out),
        .valid_in(valid_trans),

        .J_r(J_r),
        .J_g(J_g),
        .J_b(J_b),
        .valid_out(valid_scene)
    );

    // -----------------------------
    // OUTPUT
    // -----------------------------
    assign r_out = J_r;
    assign g_out = J_g;
    assign b_out = J_b;
    assign valid_out = valid_scene;

endmodule