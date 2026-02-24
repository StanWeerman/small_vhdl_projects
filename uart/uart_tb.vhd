library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use IEEE.NUMERIC_STD.ALL;


entity uart_tb is
end uart_tb;

architecture uart_tb of uart_tb is
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';

begin
    clk <= not clk after 1 ns;

    setup: process is
    begin
        rst <= '0';


        wait for 100 ns;
        finish;
    end process setup;

    test : process (clk, rst) is
        begin

        end process;
end uart_tb;
