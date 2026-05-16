module spi_master(
    input clk,
    input reset,
    input start,
    input [7:0] data_in,
    output reg mosi,
    output reg sclk,
    output reg ss,
    output reg done
);

    reg [7:0] shift_reg;
    reg [2:0] count;

    always @(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            ss <= 1;
            sclk <= 0;
            mosi <= 0;
            done <= 0;
            count <= 0;
        end

        else if(start)
        begin
            ss <= 0;
            shift_reg <= data_in;
            done <= 0;

            if(count < 8)
            begin
                sclk <= ~sclk;

                if(sclk == 0)
                begin
                    mosi <= shift_reg[7];
                    shift_reg <= shift_reg << 1;
                    count <= count + 1;
                end
            end

            else
            begin
                ss <= 1;
                done <= 1;
                count <= 0;
            end
        end
    end

endmodule
