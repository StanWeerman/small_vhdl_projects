library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity ssd is
    generic (
        SSD_NUM: integer := 8;
        CLK_START: integer := 2
    );
    port (
        clk, rst: in std_logic;
        ca : out std_logic_vector(7 downto 0);
        an : out std_logic_vector(SSD_NUM-1 downto 0);
        input: in std_logic_vector(SSD_NUM*4-1 downto 0)
    );
end ssd;

architecture ssd of ssd is
    signal ssd : std_logic_vector(3 downto 0);
    signal div_clk: std_logic_vector(26 downto 0);
    signal ssd_clk: std_logic_vector (integer(ceil(log2(real(SSD_NUM))))-1 downto 0);
begin
    ssd_clk <= div_clk(CLK_START downto CLK_START-(integer(ceil(log2(real(SSD_NUM))))-1));

    inc_clk: process(clk, rst) is
    begin
        if (rst) then
            div_clk <= (others => '0');
        end if;
        if rising_edge(clk) then
            div_clk <= std_logic_vector(unsigned(div_clk) + 1);
        end if;
    end process inc_clk;

    select_input: process(all) begin
        ssd <= (others => '-');
        an <= (others => '1');
        for index in 0 to SSD_NUM-1 loop
            if to_integer(unsigned(ssd_clk)) = index then
                ssd <= input((index+1)*4-1 downto (index+1)*4-4);
                an(index) <= '0';
            end if;
        end loop;
    end process select_input;

    output: process(all) begin
        hex_to_ssd: case ssd is
            when "0000" => ca <= "00000011"; -- 0
            when "0001" => ca <= "10011111"; -- 1
            when "0010" => ca <= "00100101"; -- 2
            when "0011" => ca <= "00001101"; -- 3
            when "0100" => ca <= "10011001"; -- 4
            when "0101" => ca <= "01001001"; -- 5
            when "0110" => ca <= "01000001"; -- 6
            when "0111" => ca <= "00011111"; -- 7
            when "1000" => ca <= "00000001"; -- 8
            when "1001" => ca <= "00001001"; -- 9
            when "1010" => ca <= "00010001"; -- A
            when "1011" => ca <= "11000001"; -- B
            when "1100" => ca <= "01100011"; -- C
            when "1101" => ca <= "10000101"; -- D
            when "1110" => ca <= "01110001"; -- E
            when "1111" => ca <= "00000011"; -- F
            when others => ca <= "XXXXXXXX";
        end case hex_to_ssd;
    end process output;
end ssd;
