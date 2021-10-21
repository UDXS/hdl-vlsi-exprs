project_new screenport -overwrite
# Assign family, device, and top-level file
set_global_assignment -name FAMILY MAX10
set_global_assignment -name DEVICE 10M08SAU169C8G
# Assign pins
set_location_assignment -to clk Pin_28
set_location_assignment -to clkx2 Pin_29
set_location_assignment -to d[0] Pin_139
set_location_assignment -to d[1] Pin_140
#
project_close