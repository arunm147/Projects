module dark_channel_5x5 #(
    parameter IMG_WIDTH = 256
)(
    input            clk,
    input            rst,
    input      [7:0] min_rgb,
    input            valid_in,

    output reg [7:0] dark_pixel,
    output reg       valid_out
);

    integer i;

    // Row and column counters
    reg [8:0] col;
    reg [8:0] row;

    // Line buffers (previous 4 rows)
    reg [7:0] line1 [0:IMG_WIDTH-1];
    reg [7:0] line2 [0:IMG_WIDTH-1];
    reg [7:0] line3 [0:IMG_WIDTH-1];
    reg [7:0] line4 [0:IMG_WIDTH-1];

    // Current row shift registers
    reg [7:0] row0 [0:4];

    // 5x5 window
    reg [7:0] w [0:24];
    reg [7:0] min_val;

    always @(posedge clk) begin
        if (rst) begin
            col       <= 0;
            row       <= 0;
            valid_out <= 0;
        end
        else if (valid_in) begin

            // Line buffer shift
            line4[col] <= line3[col];
            line3[col] <= line2[col];
            line2[col] <= line1[col];
            line1[col] <= min_rgb;

            // Current row shift
            row0[4] <= row0[3];
            row0[3] <= row0[2];
            row0[2] <= row0[1];
            row0[1] <= row0[0];
            row0[0] <= min_rgb;

            // Update column & row counters
            if (col == IMG_WIDTH-1) begin
                col <= 0;
                row <= row + 1;
            end else begin
                col <= col + 1;
            end

            // Window valid only after 5 rows & 5 columns
            if (col >= 4 && row >= 4) begin

                // Row -4
                w[0]  <= line4[col-4]; w[1]  <= line4[col-3];
                w[2]  <= line4[col-2]; w[3]  <= line4[col-1]; w[4]  <= line4[col];

                // Row -3
                w[5]  <= line3[col-4]; w[6]  <= line3[col-3];
                w[7]  <= line3[col-2]; w[8]  <= line3[col-1]; w[9]  <= line3[col];

                // Row -2
                w[10] <= line2[col-4]; w[11] <= line2[col-3];
                w[12] <= line2[col-2]; w[13] <= line2[col-1]; w[14] <= line2[col];

                // Row -1
                w[15] <= line1[col-4]; w[16] <= line1[col-3];
                w[17] <= line1[col-2]; w[18] <= line1[col-1]; w[19] <= line1[col];

                // Current row
                w[20] <= row0[4]; w[21] <= row0[3];
                w[22] <= row0[2]; w[23] <= row0[1]; w[24] <= row0[0];

                // Minimum of 25 pixels
                min_val = w[0];
                for (i = 1; i < 25; i = i + 1)
                    if (w[i] < min_val)
                        min_val = w[i];

                dark_pixel <= min_val;
                valid_out  <= 1;
            end
            else begin
                valid_out <= 0;
            end
        end
    end
endmodule