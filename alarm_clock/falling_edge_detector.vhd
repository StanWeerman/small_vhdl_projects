library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

entity falling_edge_detector is
    generic (
        PORT_WIDTH : INTEGER range 1 to (INTEGER'high) := 5
    );
    port (
        clk: in STD_LOGIC;
        signal_in: in STD_LOGIC_VECTOR ((PORT_WIDTH - 1) downto 0);
        signal_fall: out STD_LOGIC_VECTOR ((PORT_WIDTH - 1) downto 0)
    );
end falling_edge_detector;

architecture falling_edge_detector of falling_edge_detector is

signal signal_prev: STD_LOGIC_VECTOR(PORT_WIDTH-1 downto 0);

begin

    detect: process (clk) is
    begin
        if rising_edge(clk) then
            signal_prev <= signal_in;
            signal_fall <= (others => '0');
            for index in 0 to (PORT_WIDTH - 1) loop
                if signal_prev(index) = '1' and signal_in(index) = '0' then
                    signal_fall(index) <= '1';
                --else signal_fall(index) <= '0';
                end if;
            end loop;
        end if;
    end process detect;

end falling_edge_detector;
