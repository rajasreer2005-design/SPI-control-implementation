`timescale 1ns/1ps

// =============================================
// SPI Master Testbench
// =============================================
module spi_master_tb;

    reg clk;
    reg reset;
    reg start;
    reg [7:0] data_in;
    wire mosi;
    wire sclk;
    wire ss;
    wire done;

    spi_master uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_in(data_in),
        .mosi(mosi),
        .sclk(sclk),
        .ss(ss),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task apply_reset;
        begin
            reset = 1;
            @(posedge clk);
            #1;
            reset = 0;
        end
    endtask

    task send_data;
        input [7:0] data;
        begin
            data_in = data;
            start = 1;
            repeat(20) @(posedge clk);
            start = 0;
            @(posedge clk);
        end
    endtask

    initial begin
        reset = 0;
        start = 0;
        data_in = 8'b0;

        $display("=== SPI Master Test 1: Reset ===");
        apply_reset;
        $display("After reset -> ss=%b, sclk=%b, mosi=%b, done=%b (expected ss=1, others=0)", ss, sclk, mosi, done);
        if(ss == 1 && sclk == 0 && mosi == 0 && done == 0)
            $display("PASS: Reset state correct.");
        else
            $display("FAIL: Reset state incorrect.");

        $display("\n=== SPI Master Test 2: Transmit 0xA5 ===");
        apply_reset;
        send_data(8'hA5);
        $display("After transmit 0xA5 -> done=%b (expected 1)", done);
        if(done == 1) $display("PASS"); else $display("FAIL");

        $display("\n=== SPI Master Test 3: Transmit 0xFF ===");
        apply_reset;
        send_data(8'hFF);
        $display("After transmit 0xFF -> done=%b (expected 1)", done);
        if(done == 1) $display("PASS"); else $display("FAIL");

        $display("\n=== SPI Master Test 4: Transmit 0x00 ===");
        apply_reset;
        send_data(8'h00);
        $display("After transmit 0x00 -> done=%b (expected 1)", done);
        if(done == 1) $display("PASS"); else $display("FAIL");

        $display("\n=== SPI Master Test 5: SS Deasserts After Transmission ===");
        apply_reset;
        send_data(8'hA5);
        $display("After done -> ss=%b (expected 1)", ss);
        if(ss == 1) $display("PASS"); else $display("FAIL");

        $display("\n=== SPI Master All Tests Complete ===");
    end

    initial begin
        $dumpfile("spi_master_tb.vcd");
        $dumpvars(0, spi_master_tb);
    end

endmodule


// =============================================
// SPI Slave Testbench
// =============================================
module spi_slave_tb;

    reg sclk;
    reg ss;
    reg mosi;
    wire [7:0] data_out;

    spi_slave uut (
        .sclk(sclk),
        .ss(ss),
        .mosi(mosi),
        .data_out(data_out)
    );

    task send_byte;
        input [7:0] data;
        integer i;
        begin
            ss = 0;
            for(i = 7; i >= 0; i = i - 1)
            begin
                mosi = data[i];
                #10; sclk = 1;
                #10; sclk = 0;
            end
            ss = 1;
            #10;
        end
    endtask

    initial begin
        sclk = 0;
        ss = 1;
        mosi = 0;

        $display("\n=== SPI Slave Test 1: Receive 0xA5 ===");
        #20;
        send_byte(8'hA5);
        #5;
        $display("data_out = 0x%h (expected 0xA5)", data_out);
        if(data_out == 8'hA5) $display("PASS"); else $display("FAIL");

        $display("\n=== SPI Slave Test 2: Receive 0xFF ===");
        #20;
        send_byte(8'hFF);
        #5;
        $display("data_out = 0x%h (expected 0xFF)", data_out);
        if(data_out == 8'hFF) $display("PASS"); else $display("FAIL");

        $display("\n=== SPI Slave Test 3: Receive 0x00 ===");
        #20;
        send_byte(8'h00);
        #5;
        $display("data_out = 0x%h (expected 0x00)", data_out);
        if(data_out == 8'h00) $display("PASS"); else $display("FAIL");

        $display("\n=== SPI Slave Test 4: SS High (Slave Not Selected) ===");
        #20;
        ss = 1;
        mosi = 1;
        repeat(8) begin
            #10; sclk = 1;
            #10; sclk = 0;
        end
        #5;
        $display("data_out = 0x%h (expected 0x00, unchanged)", data_out);
        if(data_out == 8'h00) $display("PASS"); else $display("FAIL");

        $display("\n=== SPI Slave Test 5: Receive 0x3C ===");
        #20;
        send_byte(8'h3C);
        #5;
        $display("data_out = 0x%h (expected 0x3C)", data_out);
        if(data_out == 8'h3C) $display("PASS"); else $display("FAIL");

        $display("\n=== SPI Slave All Tests Complete ===");
        $finish;
    end

    initial begin
        $dumpfile("spi_slave_tb.vcd");
        $dumpvars(0, spi_slave_tb);
    end

endmodule
