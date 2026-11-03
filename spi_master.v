`timescale 1ns/1ps

module spi_master #(
    parameter CLK_DIV = 4,
    parameter CPOL    = 0,
    parameter CPHA    = 0
)(
    input  wire       clk,
    input  wire       rst_n,

    input  wire       start,
    input  wire [7:0] tx_data,
    output reg  [7:0] rx_data,

    output reg        busy,
    output reg        done,

    output reg        cs_n,
    output reg        sclk,
    output reg        mosi,
    input  wire        miso
);

    // FSM states
    localparam IDLE     = 2'b00;
    localparam TRANSFER = 2'b01;
    localparam FINISH   = 2'b10;

    reg [1:0] state;

    // Transmit shift register
    reg [7:0] shift_reg;

    // Receive shift register
    reg [7:0] rx_shift_reg;

    // Bit counter
    reg [3:0] bit_count;

    // Clock divider
    reg [15:0] clk_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            shift_reg    <= 8'b0;
            rx_shift_reg <= 8'b0;
            rx_data      <= 8'b0;
            bit_count    <= 4'b0;
            clk_count    <= 16'b0;

            busy         <= 1'b0;
            done         <= 1'b0;

            cs_n         <= 1'b1;
            sclk         <= CPOL;
            mosi         <= 1'b0;
        end
        else begin

            // done is a one-cycle pulse
            done <= 1'b0;

            case (state)

                // --------------------------------
                // IDLE
                // --------------------------------
                IDLE: begin
                    busy      <= 1'b0;
                    cs_n      <= 1'b1;
                    sclk      <= CPOL;
                    clk_count <= 16'b0;

                    if (start) begin
                        busy         <= 1'b1;
                        cs_n         <= 1'b0;

                        shift_reg    <= tx_data;
                        rx_shift_reg <= 8'b0;
                        bit_count    <= 4'd0;

                        // MSB first
                        mosi         <= tx_data[7];

                        state        <= TRANSFER;
                    end
                end

                // --------------------------------
                // TRANSFER
                // --------------------------------
                TRANSFER: begin

                    if (clk_count == CLK_DIV - 1) begin
                        clk_count <= 16'b0;

                        // ==========================================
                        // CPHA = 0
                        //
                        // First edge  = SAMPLE
                        // Second edge = SHIFT
                        // ==========================================
                        if (CPHA == 0) begin

                            if (sclk == CPOL) begin
                                // Sample edge
                                sclk <= ~sclk;

                                rx_shift_reg <= {
                                    rx_shift_reg[6:0],
                                    miso
                                };
                            end
                            else begin
                                // Shift edge
                                sclk <= ~sclk;

                                if (bit_count == 4'd7) begin
                                    state <= FINISH;
                                end
                                else begin
                                    bit_count <= bit_count + 1'b1;

                                    shift_reg <= {
                                        shift_reg[6:0],
                                        1'b0
                                    };

                                    mosi <= shift_reg[6];
                                end
                            end

                        end

                        // ==========================================
                        // CPHA = 1
                        //
                        // First edge  = SHIFT
                        // Second edge = SAMPLE
                        // ==========================================
                        else begin

                            if (sclk != CPOL) begin
                                // Sample edge
                                sclk <= ~sclk;

                                rx_shift_reg <= {
                                    rx_shift_reg[6:0],
                                    miso
                                };

                                if (bit_count == 4'd7) begin
                                    state <= FINISH;
                                end
                                else begin
                                    bit_count <= bit_count + 1'b1;
                                end
                            end
                            else begin
                                // Shift edge
                                sclk <= ~sclk;

                                if (bit_count == 4'd0) begin
                                    // First CPHA=1 edge.
                                    // MSB is already present on MOSI.
                                    mosi <= shift_reg[7];
                                end
                                else begin
                                    shift_reg <= {
                                        shift_reg[6:0],
                                        1'b0
                                    };

                                    mosi <= shift_reg[6];
                                end
                            end

                        end
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end

                end

                // --------------------------------
                // FINISH
                // --------------------------------
                FINISH: begin
                    busy    <= 1'b0;
                    cs_n    <= 1'b1;
                    sclk    <= CPOL;

                    rx_data <= rx_shift_reg;
                    done    <= 1'b1;

                    state   <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule