library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
    port (
        clk, rst, en : in std_logic;
        instruction : in std_logic_vector(15 downto 0);
        d_in : in std_logic_vector(7 downto 0);
        d_out : out std_logic_vector(7 downto 0);
        m_rd, m_wr : out std_logic;
        a, pco : out integer range 0 to 65535
    );
end cpu;

architecture cpu of cpu is
begin
end;
