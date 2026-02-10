library ieee;
use ieee.std_logic_1164.all;

package cpu_package is
    component cpu is
        port (
            clk, rst, en : in std_logic;
            instruction : in std_logic_vector(15 downto 0);
            d_in : in std_logic_vector(7 downto 0);
            d_out : out std_logic_vector(7 downto 0);
            m_rd, m_wr : out std_logic;
            a, pco : out integer range 0 to 65535
        );
    end component cpu;

    component memory is
        generic (data_width : integer := 8);
        port (
            clk, rd, wr : in std_logic;
            a : in integer range 0 to 65535;
            d_in : in std_logic_vector(data_width-1 downto 0);
            d_out : out std_logic_vector(data_width-1 downto 0)
        );
    end component memory;

end package cpu_package;
