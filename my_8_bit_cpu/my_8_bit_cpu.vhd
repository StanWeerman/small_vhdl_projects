library ieee;
use ieee.std_logic_1164.all;

entity cpu is
    port (clk, rst, en : in std_logic;
        instruction : in std_logic_vector(15 downto 0);
        d_in : in std_logic_vector(7 downto 0);
        d_out : out std_logic_vector(7 downto 0);
        m_rd, m_wr : out std_logic
    );
end cpu;

architecture cpu of cpu is
begin
end cpu;
