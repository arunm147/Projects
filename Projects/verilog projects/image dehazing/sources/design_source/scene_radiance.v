module scene_radiance (
    input             clk,
    input             rst,

    input      [7:0]  r,
    input      [7:0]  g,
    input      [7:0]  b,

    input      [7:0]  A_r,
    input      [7:0]  A_g,
    input      [7:0]  A_b,

    input      [15:0] t_in,      // transmission Q8.8
    input             valid_in,

    output reg [7:0]  J_r,
    output reg [7:0]  J_g,
    output reg [7:0]  J_b,
    output reg        valid_out
);

parameter T0 = 16'd26;   // 0.1 in Q8.8

reg [15:0] t_clamped;

reg signed [15:0] r_diff;
reg signed [15:0] g_diff;
reg signed [15:0] b_diff;

reg signed [23:0] r_scaled;
reg signed [23:0] g_scaled;
reg signed [23:0] b_scaled;

reg signed [31:0] temp_r;
reg signed [31:0] temp_g;
reg signed [31:0] temp_b;

always @(posedge clk) begin
    if (rst) begin
        J_r <= 0;
        J_g <= 0;
        J_b <= 0;
        valid_out <= 0;
    end
    else if (valid_in) begin

        // clamp transmission
        if (t_in < T0)
            t_clamped <= T0;
        else
            t_clamped <= t_in;

        // compute difference
        r_diff <= r - A_r;
        g_diff <= g - A_g;
        b_diff <= b - A_b;

        // scale to Q8.8
        r_scaled <= r_diff <<< 8;
        g_scaled <= g_diff <<< 8;
        b_scaled <= b_diff <<< 8;

        // division
      if (t_clamped != 0) begin

    temp_r = (r_scaled / t_clamped) + A_r;
    temp_g = (g_scaled / t_clamped) + A_g;
    temp_b = (b_scaled / t_clamped) + A_b;

    if (temp_r < 0)
        J_r <= 0;
    else if (temp_r > 255)
        J_r <= 255;
    else
        J_r <= temp_r[7:0];

    if (temp_g < 0)
        J_g <= 0;
    else if (temp_g > 255)
        J_g <= 255;
    else
        J_g <= temp_g[7:0];

    if (temp_b < 0)
        J_b <= 0;
    else if (temp_b > 255)
        J_b <= 255;
    else
        J_b <= temp_b[7:0];

end

        valid_out <= 1;
    end
    else
        valid_out <= 0;
end

endmodule