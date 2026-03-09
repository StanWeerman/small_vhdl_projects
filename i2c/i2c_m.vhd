library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity i2c_m is
    generic(
        ICLK: natural := 10000000;
        BCLK: natural := 400000
        );
    port (
        clk, rst, enable: in std_logic;
        rw: in std_logic;
        addr: in std_logic_vector(6 downto 0);
        byte_in: in std_logic_vector(7 downto 0);
        byte_out: out std_logic_vector(7 downto 0);
        busy, error: out std_logic;
        sdc, sda: inout std_logic
    );
end i2c_m;

architecture i2c_m of i2c_m is

    type i2c_state is
        (IDLE, START, DATA, STOP);
    signal state: i2c_state := IDLE;
begin
    clock_handling : process(clk) is
    begin
        if rising_edge(clk) then

        end if;
    end process clock_handling;

    state_machine : process(clk) is
    begin
        if rising_edge(clk) then
            case state is

            end case;
        end if;
    end process state_machine;

end i2c_m;
