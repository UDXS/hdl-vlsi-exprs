create_clock -name CLK12M -period 83.333 [get_ports {CLK12M}]
create_clock -name DISP_SCK -period 1000 [get_ports {DISP_SCK}]
derive_pll_clocks
derive_clock_uncertainty