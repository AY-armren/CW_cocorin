module div_freq_12bit_input_up(
    input  wire clk,
    input  wire [11:0] adc_data,
    input  wire apply,
    input  wire run,
    output reg out_clk = 1'b0
);
    reg [11:0] SP_counter = 12;
    reg [11:0] counter = 0;
    always @(posedge apply) begin 
        SP_counter <= ((588 * adc_data) >> 12) + 12;
    end

    always @(posedge clk) begin
        if (run & ~apply) begin
            if (counter < SP_counter) begin
                counter <= counter + 1;
            end else begin
                out_clk <= ~out_clk;
                counter <= 0;
            end
        end else begin 
            counter <= 0;
            out_clk <= 1'b0;
        end
    end
endmodule

module div_freq_12bit_input_down(
    input  wire clk,
    input  wire [11:0] adc_data,
    input  wire apply,
    input  wire run,
    output reg out_clk = 1'b0
);
    reg [11:0] SP_counter = 12;
    reg [11:0] counter = 0;
    always @(posedge apply) begin 
        SP_counter <= ((61 * adc_data) >> 12) + 1;
    end

    always @(posedge clk) begin
        if (run & ~apply) begin
            if (counter < SP_counter) begin
                counter <= counter + 1;
            end else begin
                out_clk <= ~out_clk;
                counter <= 0;
            end
        end else begin 
            counter <= 0;
            out_clk <= 1'b0;
        end
    end
endmodule

module finishing(
    input wire clk, 
    input wire set,
    input wire run,
    input  wire [11:0] ADC,
    output reg  [11:0] DAC = 0, 
    output reg out_change = 0
);
    reg direction = 0, run_up = 0, run_down = 0, inc_check, dec_check;
    wire inc, dec;
    div_freq_12bit_input_up up(.clk(clk), .apply(set), .adc_data(ADC), .out_clk(inc), .run(run_up));
    div_freq_12bit_input_down down(.clk(clk), .apply(set), .adc_data(ADC), .out_clk(dec), .run(run_down));

    always @(posedge (inc || dec)) begin 
        if (direction == 1'b1) begin 
            DAC <= DAC + 1;
        end
        if (direction == 1'b0) begin 
            DAC <= DAC - 1;
        end
    end

    always @(posedge clk) begin
        if (run) begin
            if (DAC == 4095) begin 
                direction <= 1'b0;
                run_down <= 1'b1;
                run_up <= 1'b0;
            end
            if (DAC == 0) begin 
                direction <= 1'b1;
                run_down <= 1'b0;
                run_up <= 1'b1;
            end
        end 
        if (inc || dec) begin 
            out_change <= 1'b1;
        end else begin 
            out_change <= 1'b1;
        end 
    end
endmodule