module transmission_map (
    input             clk,
    input             rst,

    input      [7:0]  dark_pixel,
    input      [7:0]  A_r,
    input      [7:0]  A_g,
    input      [7:0]  A_b,
    input             valid_in,

    output reg [15:0] t_out,      // Q8.8 fixed-point
    output reg        valid_out
);

    // omega = 0.95 in Q8.8 format (0.95 * 256 ? 243)
    parameter OMEGA = 8'd243;

    // Stage-1 registers
    reg [7:0]  A_max;
    reg [15:0] omega_mult;
    reg        valid_d;

    // -----------------------------
    // Stage 1: A_max + multiplication
    // -----------------------------
    always @(posedge clk) begin
        if (rst) begin
            A_max      <= 8'd0;
            omega_mult <= 16'd0;
            valid_d    <= 1'b0;
        end
        else begin
            valid_d <= valid_in;

            if (valid_in) begin
                // Find max of atmospheric light channels
                if (A_r >= A_g && A_r >= A_b)
                    A_max <= A_r;
                else if (A_g >= A_r && A_g >= A_b)
                    A_max <= A_g;
                else
                    A_max <= A_b;

                // omega * dark_pixel
                omega_mult <= OMEGA * dark_pixel;
            end
        end
    end

    // -----------------------------
    // Stage 2: Division + final t
    // -----------------------------
    always @(posedge clk) begin
        if (rst) begin
            t_out     <= 16'd0;
            valid_out <= 1'b0;
        end
        else if (valid_d) begin
            if (A_max != 0)
                t_out <= 16'd256 - ((omega_mult << 8) / A_max);
            else
                t_out <= 16'd0;

            valid_out <= 1'b1;
        end
        else begin
            valid_out <= 1'b0;
        end
    end

endmodule