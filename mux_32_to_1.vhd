library ieee;
use ieee.std_logic_1164.all;

entity mux_32_to_1 is
    generic (
        DATA_WIDTH : positive := 32
    );
    port (
        inputs       : in  std_logic_vector((32 * DATA_WIDTH) - 1 downto 0);
        select_lines : in  std_logic_vector(4 downto 0);
        output_data  : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity mux_32_to_1;

architecture structural of mux_32_to_1 is
    signal stage_1 : std_logic_vector((8 * DATA_WIDTH) - 1 downto 0);
    signal stage_2 : std_logic_vector((2 * DATA_WIDTH) - 1 downto 0);
begin
    -- Stage 1: eight 4-to-1 multiplexers select one value from each group of four.
    generate_stage_1 : for index in 0 to 7 generate
    begin
        mux_stage_1 : entity work.mux_4_to_1
            generic map (
                DATA_WIDTH => DATA_WIDTH
            )
            port map (
                input_a      => inputs((index * 4 * DATA_WIDTH) + DATA_WIDTH - 1 downto (index * 4 * DATA_WIDTH)),
                input_b      => inputs((index * 4 * DATA_WIDTH) + (2 * DATA_WIDTH) - 1 downto (index * 4 * DATA_WIDTH) + DATA_WIDTH),
                input_c      => inputs((index * 4 * DATA_WIDTH) + (3 * DATA_WIDTH) - 1 downto (index * 4 * DATA_WIDTH) + (2 * DATA_WIDTH)),
                input_d      => inputs((index * 4 * DATA_WIDTH) + (4 * DATA_WIDTH) - 1 downto (index * 4 * DATA_WIDTH) + (3 * DATA_WIDTH)),
                select_lines => select_lines(1 downto 0),
                output_data  => stage_1((index * DATA_WIDTH) + DATA_WIDTH - 1 downto (index * DATA_WIDTH))
            );
    end generate generate_stage_1;

    -- Stage 2: two 4-to-1 multiplexers reduce eight values to two.
    generate_stage_2 : for index in 0 to 1 generate
    begin
        mux_stage_2 : entity work.mux_4_to_1
            generic map (
                DATA_WIDTH => DATA_WIDTH
            )
            port map (
                input_a      => stage_1((index * 4 * DATA_WIDTH) + DATA_WIDTH - 1 downto (index * 4 * DATA_WIDTH)),
                input_b      => stage_1((index * 4 * DATA_WIDTH) + (2 * DATA_WIDTH) - 1 downto (index * 4 * DATA_WIDTH) + DATA_WIDTH),
                input_c      => stage_1((index * 4 * DATA_WIDTH) + (3 * DATA_WIDTH) - 1 downto (index * 4 * DATA_WIDTH) + (2 * DATA_WIDTH)),
                input_d      => stage_1((index * 4 * DATA_WIDTH) + (4 * DATA_WIDTH) - 1 downto (index * 4 * DATA_WIDTH) + (3 * DATA_WIDTH)),
                select_lines => select_lines(3 downto 2),
                output_data  => stage_2((index * DATA_WIDTH) + DATA_WIDTH - 1 downto (index * DATA_WIDTH))
            );
    end generate generate_stage_2;

    -- Stage 3: one 2-to-1 multiplexer chooses the final value.
    mux_stage_3 : entity work.mux_2_to_1
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            input_a     => stage_2(DATA_WIDTH - 1 downto 0),
            input_b     => stage_2((2 * DATA_WIDTH) - 1 downto DATA_WIDTH),
            select_line => select_lines(4),
            output_data => output_data
        );
end architecture structural;
