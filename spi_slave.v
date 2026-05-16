module spi_slave(
    input sclk,
    input ss,
    input mosi,
    output reg [7:0] data_out
);

    reg [7:0] shift_reg;
    reg [2:0] count;

    always @(posedge sclk)
    begin
        if(ss == 0)
        begin
            shift_reg <= {shift_reg[6:0], mosi};
            count <= count + 1;

            if(count == 7)
            begin
                data_out <= {shift_reg[6:0], mosi};
                count <= 0;
            end
        end
    end

endmodule
