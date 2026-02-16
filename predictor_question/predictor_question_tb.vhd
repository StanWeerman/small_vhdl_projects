-- half_adder_process_tb.vhd

library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use STD.TEXTIO.all;

--library work;

entity predictor_question_tb is
end predictor_question_tb;

architecture predictor_question_tb of predictor_question_tb is
    signal clk: std_logic := '0';
    signal actual: std_logic;
    signal predicted_a, predicted_b: std_logic;
    signal global_b: std_logic;
    signal branch: std_logic := '0';

    type list is array(0 to 17) of std_logic;
    signal actuals: list := (
                            '0', '1', -- 8
                            '1', '0', -- 9
                            '0', '1', -- 10
                            '1', '1', -- 11
                            '1', '1', -- 7
                            '0', '1', -- 20
                            '1', '1', -- 29
                            '0', '0', -- 30
                            '1', '1' -- 31
                            );

    signal index: natural range 0 to 17 := 0;
    signal value: integer;

begin
    predictor_inst: entity work.predictor
    port map(
        clk => clk,
        actual => actual,
        predicted_a => predicted_a,
        predicted_b => predicted_b,
        branch => branch,
        global_b => global_b
    );

    clk <= not clk after 10 ns;

    actual <= actuals(index);

    iter: process(clk) is
    variable p_a, a_a, g_b, p_b, a_b: string(1 to 1);
    variable total: string(1 to 12);
    variable line: line;
    begin
        if rising_edge(clk) then
            index <= index+1;
            branch <= branch xor '1';
            p_a := "1" when predicted_a else "0";
            a_a := "1" when actual else "0";
            g_b := "1" when global_b else "0";
            p_b := "1" when predicted_b else "0";
            a_b := "1" when actual else "0";
            total := p_a & "|" & a_a & "    " & g_b & "|" & p_b & "|" & p_a;
            --write(line, p_a);
            --write(line, string'("|"));
            --write(line, a_a);
            --write(line, string'("    "));
            --write(line, g_b);
            --write(line, string'("|"));
            --write(line, p_b);
            --write(line, string'("|"));
            --write(line, a_b);
            write(line, total);
            writeline(output, line);

            if index = 16 then
                finish;
            end if;
        end if;
    end process;

end predictor_question_tb;
