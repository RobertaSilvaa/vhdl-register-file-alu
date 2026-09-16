library ieee;
use ieee.std_logic_1164.all;

entity register_array is
    generic (
        DATA_WIDTH : positive := 32
    );
    port (
        clk                       : in  std_logic;
        reset                     : in  std_logic;
        write_enables             : in  std_logic_vector(31 downto 0);
        data_in                   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        register_5_initial_value  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        register_23_initial_value : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        outputs_flat              : out std_logic_vector((32 * DATA_WIDTH) - 1 downto 0)
    );
end entity register_array;

architecture structural of register_array is
    type register_bus_t is array (0 to 31) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal register_outputs : register_bus_t;
begin
    generate_registers : for index in 0 to 31 generate
        signal initial_value : std_logic_vector(DATA_WIDTH - 1 downto 0);
    begin
        register_5_value : if index = 5 generate
        begin
            initial_value <= register_5_initial_value;
        end generate register_5_value;

        register_23_value : if index = 23 generate
        begin
            initial_value <= register_23_initial_value;
        end generate register_23_value;

        default_value : if index /= 5 and index /= 23 generate
        begin
            initial_value <= (others => '0');
        end generate default_value;

        register_instance : entity work.data_register
            generic map (
                DATA_WIDTH => DATA_WIDTH
            )
            port map (
                clk           => clk,
                reset         => reset,
                enable        => write_enables(index),
                initial_value => initial_value,
                data_in       => data_in,
                data_out      => register_outputs(index)
            );

        outputs_flat((index * DATA_WIDTH) + DATA_WIDTH - 1 downto index * DATA_WIDTH) <= register_outputs(index);
    end generate generate_registers;
end architecture structural;
