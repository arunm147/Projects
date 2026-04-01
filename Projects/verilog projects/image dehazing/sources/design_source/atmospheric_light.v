module atmospheric_light (
    input            clk,
    input            rst,

    input      [7:0] dark_pixel,
    input      [7:0] r,
    input      [7:0] g,
    input      [7:0] b,
    input            valid_dark,

    input            frame_end,   // 1-clock pulse at end of frame

    output reg [7:0] A_r,
    output reg [7:0] A_g,
    output reg [7:0] A_b
);

    reg [7:0] dark_max;

    always @(posedge clk) begin
        if (rst) begin
            dark_max <= 0;
            A_r <= 0;
            A_g <= 0;
            A_b <= 0;
        end
        else begin
            // Track brightest dark channel pixel
            if (valid_dark) begin
                if (dark_pixel > dark_max) begin
                    dark_max <= dark_pixel;
                    A_r <= r;
                    A_g <= g;
                    A_b <= b;
                end
            end

            // Reset for next frame
            if (frame_end) begin
                dark_max <= 0;
            end
        end
    end
endmodule
