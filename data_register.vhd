library ieee;
use ieee.std_logic_1164.all;

entity data_register is
    generic (
        DATA_WIDTH : positive := 32
    );
    port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        enable        : in  std_logic;
        initial_value : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        data_in       : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        data_out      : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity data_register;

architecture rtl of data_register is
begin
    process (clk, reset)
    begin
        if reset = '1' then
            data_out <= initial_value;
        elsif rising_edge(clk) then
            if enable = '1' then
                data_out <= data_in;
            end if;
        end if;
    end process;
end architecture rtl;
