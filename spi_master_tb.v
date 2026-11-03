`timescale 1ns/1ps

module spi_master_tb;

    // ==========================================
    // SPI mode selection
    // ==========================================
    parameter CPOL = 0;
    parameter CPHA = 0;

    // Clock and reset
    reg clk;
    reg rst_n;

    // Control signals
    reg start;
    reg [7:0] tx_data;

    // SPI signals
    wire [7:0] rx_data;
    wire busy;
    wire done;
    wire cs_n;
    wire sclk;
    wire mosi;
    reg  miso;

    // Slave data
    reg [7:0] slave_tx_data;
    reg [7:0] slave_shift_reg;

    // ==========================================
    // SPI Master
    // ==========================================
    spi_master #(
        .CLK_DIV(4),
        .CPOL(CPOL),
        .CPHA(CPHA)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .busy(busy),
        .done(done),
        .cs_n(cs_n),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso)
    );

    // 100 MHz system clock
    always #5 clk = ~clk;

    // ==========================================
    // Slave: transaction start
    // ==========================================
    always @(negedge cs_n) begin

        slave_shift_reg <= slave_tx_data;

        if (CPHA == 0) begin
            // CPHA=0: first data bit is valid
            // before the first sampling edge.
            miso <= slave_tx_data[7];
        end
        else begin
            // CPHA=1: data is presented
            // on the first clock edge.
            miso <= 1'b0;
        end

    end

    // ==========================================
    // Slave SPI timing
    // ==========================================
    always @(posedge sclk or negedge sclk) begin

        // --------------------------------------
        // CPHA = 0
        // Shift data on second edge
        // --------------------------------------
        if (CPHA == 0) begin

            if (sclk == CPOL) begin

                miso <= slave_shift_reg[6];

                slave_shift_reg <= {
                    slave_shift_reg[6:0],
                    1'b0
                };

            end

        end

        // --------------------------------------
        // CPHA = 1
        // Shift data on first edge
        // --------------------------------------
        else begin

            if (sclk != CPOL) begin

                miso <= slave_shift_reg[7];

                slave_shift_reg <= {
                    slave_shift_reg[6:0],
                    1'b0
                };

            end

        end

    end

    // ==========================================
    // Test sequence
    // ==========================================
    initial begin

        // Waveform dump
        $dumpfile("sim/spi_master.vcd");
        $dumpvars(0, spi_master_tb);

        // Initial values
        clk             = 1'b0;
        rst_n           = 1'b0;
        start           = 1'b0;
        tx_data         = 8'h00;
        miso            = 1'b0;
        slave_tx_data   = 8'h00;
        slave_shift_reg = 8'h00;

        // ======================================
        // Reset
        // ======================================
        #20;
        rst_n = 1'b1;

        // ======================================
        // TEST 1
        // TX = A5, RX = 3C
        // ======================================
        tx_data       = 8'hA5;
        slave_tx_data = 8'h3C;

        #20;
        start = 1'b1;
        #10;
        start = 1'b0;

        wait(done);

        $display("----------------------------------------");
        $display("TEST 1");
        $display("TX DATA       = %h", tx_data);
        $display("EXPECTED RX   = %h", slave_tx_data);
        $display("ACTUAL RX     = %h", rx_data);

        if (rx_data == slave_tx_data)
            $display("TEST 1 PASSED!");
        else
            $display("TEST 1 FAILED!");

        #20;

        // ======================================
        // TEST 2
        // TX = 55, RX = 96
        // ======================================
        tx_data       = 8'h55;
        slave_tx_data = 8'h96;

        #20;
        start = 1'b1;
        #10;
        start = 1'b0;

        wait(done);

        $display("----------------------------------------");
        $display("TEST 2");
        $display("TX DATA       = %h", tx_data);
        $display("EXPECTED RX   = %h", slave_tx_data);
        $display("ACTUAL RX     = %h", rx_data);

        if (rx_data == slave_tx_data)
            $display("TEST 2 PASSED!");
        else
            $display("TEST 2 FAILED!");

        #20;

        // ======================================
        // TEST 3
        // TX = F0, RX = 0F
        // ======================================
        tx_data       = 8'hF0;
        slave_tx_data = 8'h0F;

        #20;
        start = 1'b1;
        #10;
        start = 1'b0;

        wait(done);

        $display("----------------------------------------");
        $display("TEST 3");
        $display("TX DATA       = %h", tx_data);
        $display("EXPECTED RX   = %h", slave_tx_data);
        $display("ACTUAL RX     = %h", rx_data);

        if (rx_data == slave_tx_data)
            $display("TEST 3 PASSED!");
        else
            $display("TEST 3 FAILED!");

        #20;

        // ======================================
        // End simulation
        // ======================================
        $display("----------------------------------------");
        $display("ALL SPI TESTS COMPLETE");
        $display("----------------------------------------");

        $finish;

    end

endmodule