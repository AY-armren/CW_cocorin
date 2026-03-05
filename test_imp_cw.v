`timescale 1ns/1ps

module quick_test;
    // Сигналы
    reg clk;
    reg set;
    reg [11:0] ADC;
    wire [11:0] DAC;
    reg run;
    
    // Тестируемый модуль
    finishing dut (
        .clk(clk),
        .set(set),
        .ADC(ADC),
        .DAC(DAC), 
        .run(run)
    );
    
    // Тактовый генератор
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 20ns период, 50 МГц
    end
    
    // Простой тест
    initial begin
        // Включаем запись VCD
        $dumpfile("qt.vcd");
        $dumpvars(0, quick_test);
        
        // Инициализация
        ADC = 12'hFFF;  // 2048
        set = 0;
        
        #100;
        
        // Основной тест
        $display("Начало теста в %t", $time);
        
        // Применяем настройку
        set = 1;
        #20;
        set = 0;
        run = 1; 
        #1;
        
        // Симулируем 2000 нс
        #100000000;
        
        $display("Конец теста в %t", $time);
        $display("DAC = %0d", DAC);
        $finish;
    end
    
endmodule