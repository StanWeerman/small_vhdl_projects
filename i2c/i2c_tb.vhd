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
    signal enable: std_logic;

    signal rw: std_logic;
    signal addr: std_logic_vector(6 downto 0);
    signal byte_in: std_logic_vector(7 downto 0);
    signal byte_out: std_logic_vector(7 downto 0);
    signal busy, error: std_logic;
    signal scl, sda: std_logic;

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
    clk <= not clk after 1 ns;

    i2c_controller_inst: entity work.i2c_controller
     generic map(
        ICLK => 10000000,
        BCLK => 400000
    )
     port map(
        clk => clk,
        rst => rst,
        enable => enable,
        rw => rw,
        addr => addr,
        byte_in => byte_in,
        byte_out => byte_out,
        busy => busy,
        error => error,
        scl => scl,
        sda => sda
    );

    testing: process is
    begin
        rst <= '0';
        wait for 500 ns;

        report "Tests Complete";

        finish;
    end process testing;

end i2c_tb;
