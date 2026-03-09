library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity i2c_tb is
end i2c_tb;

architecture i2c_tb of i2c_tb is
    signal clk: std_logic := '0';
    signal rst: std_logic := '1';

    constant ICLK: natural := 10000000;
    constant BCLK: time := 400000 ns;


    procedure test_byte (
        constant byte: in std_logic_vector(7 downto 0);
        signal byte_out: out std_logic_vector(7 downto 0);
        signal go: out std_logic
    ) is
        begin

    end procedure test_byte;
begin
    clk <= not clk after 50 ns;



    testing: process is
    begin


        report "Tests Complete";

        finish;
    end process testing;

end i2c_tb;
