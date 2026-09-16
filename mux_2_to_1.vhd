library ieee;
use ieee.std_logic_1164.all;

entity mux_2_to_1 is
    generic (
        DATA_WIDTH : positive := 32
    );
    port (
        input_a     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        input_b     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        select_line : in  std_logic;
        output_data : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity mux_2_to_1;

architecture rtl of mux_2_to_1 is
begin
    with select_line select
        output_data <= input_a when '0',
                       input_b when '1',
                       (others => '0') when others;
end architecture rtl;
