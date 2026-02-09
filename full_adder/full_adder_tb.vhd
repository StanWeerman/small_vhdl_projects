-- half_adder_process_tb.vhd

library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;

--library work;

entity full_adder_tb is
end full_adder_tb;

architecture full_adder_tb of full_adder_tb is
    signal a, b, c_in : std_logic;
    signal sum, c_out : std_logic;

    component full_adder is
        port (
        a : in  std_logic;
        b : in  std_logic;
        c_in : in  std_logic;
        sum : in  std_logic;
        c_out : out  std_logic);
    end component full_adder;

begin
    -- connecting testbench signals with half_adder.vhd
    UUT : full_adder port map (a => a, b => b, c_in => c_in, sum => sum, c_out => c_out);
    -- Can do direct instantiation
    --UUT : entity work.full_adder port map (a => a, b => b, c_in => c_in, sum => sum, c_out => c_out);


    tb1 : process
        constant period: time := 20 ns;
        begin
            a <= '0';
            b <= '0';
            c_in <= '0';
            wait for period;
            assert ((sum = '0') and (c_out = '0'))  -- expected output
            -- error will be reported if sum or carry is not 0
            report "test failed for input combination 00 0" severity failure;

            a <= '0';
            b <= '1';
            c_in <= '0';
            wait for period;
            assert ((sum = '1') and (c_out = '0'))
            report "test failed for input combination 01 0" severity failure;

            a <= '1';
            b <= '0';
            c_in <= '0';
            wait for period;
            assert ((sum = '1') and (c_out = '0'))
            report "test failed for input combination 10 0" severity failure;

            a <= '1';
            b <= '1';
            c_in <= '0';
            wait for period;
            assert ((sum = '0') and (c_out = '1'))
            report "test failed for input combination 11 0" severity failure;

            a <= '1';
            b <= '1';
            c_in <= '1';
            wait for period;
            assert ((sum = '1') and (c_out = '1'))
            report "test failed for input combination 11 1" severity failure;

            a <= '0';
            b <= '0';
            c_in <= '1';
            wait for period;
            assert ((sum = '1') and (c_out = '0'))
            report "test failed for input combination 00 1" severity failure;

            finish;
        end process;
end full_adder_tb;
