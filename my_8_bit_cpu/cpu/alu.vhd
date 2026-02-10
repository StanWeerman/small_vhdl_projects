library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    port (
        a,b : in std_logic_vector(7 downto 0);
        c : out std_logic_vector(7 downto 0);
        c_out : out std_logic;
        control: in std_logic_vector(6 downto 0)
        );
end alu;

architecture alu of alu is
    signal mov, sign, add, sub, and_or, c_and, c_or: std_logic;
begin
    -- Control bits
    mov <= control(1);
    sign <= control(2);
    add <= not control(2);
    sub <= control(2);
    and_or <= control(3);
    c_and <= control(2);
    c_or <= not control(2);

    process (all) is
    variable sum : unsigned(8 downto 0);
        begin
            if (and_or) then
                c_out <= '0';
                c <= a and b when c_and else a or b;
            else
                sum := resize(unsigned(a), sum'length) + (resize(unsigned(b), sum'length) xor sign);
                sum := sum + sign;
                c_out <= sum(8);
                c <= std_logic_vector(resize(sum, c'length));
            end if;
        end process;
end alu;
