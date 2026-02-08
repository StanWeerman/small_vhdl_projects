-- half_adder.vhd

library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
  port (a, b, c_in : in std_logic;
        sum, c_out : out std_logic
    );
end full_adder;

architecture rtl of full_adder is
    --signal a_xor_b : std_logic;
begin
    ADD: process(a, b, c_in)
        variable a_xor_b: std_logic;
    begin
        a_xor_b := a xor b;
        sum <= a_xor_b xor c_in;
        c_out <= (a_xor_b and c_in) or (a and b);
    end process;

end rtl;
