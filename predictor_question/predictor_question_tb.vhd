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

    type value_list is array(0 to 8) of integer;
    signal values: value_list := (8,9,10,11,7,20,29,30,31);

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
        variable val: string(1 to 5);
    begin
        if rising_edge(clk) then
            branch <= branch xor '1';

            if branch then write(line, string'("b2    "));
            else write(line, string'("b1    "));
            end if;

            p_a := "1" when predicted_a else "0";
            a_a := "1" when actual else "0";
            g_b := "1" when global_b else "0";
            p_b := "1" when predicted_b else "0";
            a_b := "1" when actual else "0";
            total := p_a & "|" & a_a & "    " & g_b & "|" & p_b & "|" & a_b;
            write(line, total);

            val := "    " & to_string(index/2);
            write(line, val);
            write(line, string'(": "));
            write(line, to_string(values(index/2)));

            writeline(output, line);

            if index = 17 then
                finish;
            end if;
            index <= index+1;
        end if;
    end process iter;

    start: process
        variable line: line;
    begin
        write(line, string'("      |A|    | B |"));
        writeline(output, line);
        write(line, string'("b#    p|a    g|p|a    i: v"));
        writeline(output, line);
        wait;
    end process start;

end predictor_question_tb;
