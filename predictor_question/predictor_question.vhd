-- half_adder.vhd

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity predictor is
  port (
        clk: in std_logic;
        actual: in std_logic;
        predicted_a, predicted_b: out std_logic;
        branch: in std_logic;
        global_b: out std_logic := '0'
    );
end predictor;

architecture predictor of predictor is
    type a is array (0 to 1) of std_logic;
    type b is array (0 to 3) of std_logic;

    signal bpb_a: a := (others => '0');

    signal bpb_b: b := (others => '0');
begin

    predicted_a <= bpb_a(to_integer(unsigned(std_logic_vector'(""&branch))));

    predicted_b <= bpb_b(to_integer(unsigned(std_logic_vector'(global_b & branch))));

    predict : process(clk) is
        begin
            if rising_edge(clk) then
                if (predicted_a /= actual) then
                    bpb_a(to_integer(unsigned(std_logic_vector'(""&branch)))) <= bpb_a(to_integer(unsigned(std_logic_vector'(""&branch)))) xor '1';
                end if;
                if (predicted_b /= actual) then
                    bpb_b(to_integer(unsigned(std_logic_vector'(global_b & branch)))) <= bpb_b(to_integer(unsigned(std_logic_vector'(global_b & branch)))) xor '1';
                end if;
                global_b <= actual;
            end if;
        end process;
end predictor;
