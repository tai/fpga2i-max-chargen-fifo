project_new -overwrite -revision sample sample

set_global_assignment -name TOP_LEVEL_ENTITY top
set_global_assignment -name VERILOG_FILE top.v

set_global_assignment -name FAMILY MAX10
set_global_assignment -name DEVICE 10M16SCE144C8G

set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files

if {false} {
set_global_assignment -name BDF_FILE sample.bdf
set_global_assignment -name SDC_FILE sample.sdc

set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85

set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256

set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (Verilog)"
set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
}

set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top

######################################################################
# pin map
# @ref 02_FPGA_Shield_v2_Users_Manual_v100_0811.pdf
######################################################################

set_location_assignment PIN_6 -to led[0]
set_location_assignment PIN_7 -to led[1]
set_location_assignment PIN_8 -to led[2]

set_location_assignment PIN_10 -to cpu[0]

set_location_assignment PIN_11 -to pmod[3]
set_location_assignment PIN_12 -to pmod[2]
set_location_assignment PIN_13 -to uart_tx
set_location_assignment PIN_14 -to uart_rx

set_location_assignment PIN_17 -to cpu[1]

set_location_assignment PIN_21 -to ud[12]
set_location_assignment PIN_22 -to ud[13]

set_location_assignment PIN_24 -to ud[10]
set_location_assignment PIN_25 -to ud[11]

set_location_assignment PIN_27 -to clk

set_location_assignment PIN_28 -to ud[8]
set_location_assignment PIN_29 -to ud[9]

set_location_assignment PIN_30 -to dip[2]
set_location_assignment PIN_32 -to dip[1]
set_location_assignment PIN_33 -to dip[0]

set_location_assignment PIN_38 -to u8addr[11]
set_location_assignment PIN_39 -to u8addr[12]

set_location_assignment PIN_41 -to u8addr[6]
set_location_assignment PIN_43 -to u8addr[7]

set_location_assignment PIN_44 -to u8oe_n

set_location_assignment PIN_45 -to u8data[7]
set_location_assignment PIN_46 -to u8data[6]
set_location_assignment PIN_47 -to u8data[5]
set_location_assignment PIN_48 -to u8data[4]

set_location_assignment PIN_50 -to u8addr[13]
set_location_assignment PIN_52 -to u8addr[14]
set_location_assignment PIN_54 -to u8addr[15]
set_location_assignment PIN_55 -to u8addr[16]

set_location_assignment PIN_56 -to u8addr[8]
set_location_assignment PIN_57 -to u8addr[9]
set_location_assignment PIN_58 -to u8addr[2]
set_location_assignment PIN_59 -to u8addr[1]
set_location_assignment PIN_60 -to u8addr[0]

set_location_assignment PIN_62 -to ua[0]
set_location_assignment PIN_64 -to ua[1]
set_location_assignment PIN_65 -to ua[2]
set_location_assignment PIN_66 -to ua[3]
set_location_assignment PIN_69 -to ua[4]
set_location_assignment PIN_70 -to ua[5]

set_location_assignment PIN_74 -to u8we_n

set_location_assignment PIN_75  -to u8data[3]
set_location_assignment PIN_76  -to u8data[2]
set_location_assignment PIN_77  -to u8data[1]
set_location_assignment PIN_78  -to u8data[0]

set_location_assignment PIN_79  -to u8cs_n

set_location_assignment PIN_80  -to u8addr[3]
set_location_assignment PIN_81  -to u8addr[4]
set_location_assignment PIN_84  -to u8addr[5]
set_location_assignment PIN_85  -to u8addr[10]

set_location_assignment PIN_86  -to u7addr[11]
set_location_assignment PIN_87  -to u7addr[12]
set_location_assignment PIN_88  -to u7addr[6]
set_location_assignment PIN_89  -to u7addr[7]

set_location_assignment PIN_90  -to u7oe_n

set_location_assignment PIN_91  -to u7data[7]
set_location_assignment PIN_92  -to u7data[6]
set_location_assignment PIN_93  -to u7data[5]
set_location_assignment PIN_96  -to u7data[4]
set_location_assignment PIN_97  -to u7addr[13]
set_location_assignment PIN_98  -to u7addr[14]
set_location_assignment PIN_99  -to u7addr[15]
set_location_assignment PIN_100 -to u7addr[16]
set_location_assignment PIN_101 -to u7addr[8]
set_location_assignment PIN_102 -to u7addr[9]
set_location_assignment PIN_105 -to u7addr[2]
set_location_assignment PIN_106 -to u7addr[1]

set_location_assignment PIN_110 -to ud[0]
set_location_assignment PIN_111 -to ud[1]
set_location_assignment PIN_112 -to ud[2]
set_location_assignment PIN_113 -to ud[3]
set_location_assignment PIN_114 -to ud[4]
set_location_assignment PIN_118 -to ud[5]
set_location_assignment PIN_119 -to ud[6]
set_location_assignment PIN_120 -to ud[7]

set_location_assignment PIN_121 -to res_n

set_location_assignment PIN_122 -to u7addr[0]

set_location_assignment PIN_123 -to u7we_n

set_location_assignment PIN_124 -to u7data[3]
set_location_assignment PIN_127 -to u7data[2]
set_location_assignment PIN_130 -to u7data[1]
set_location_assignment PIN_131 -to u7data[0]

set_location_assignment PIN_132 -to u7cs_n

set_location_assignment PIN_134 -to u7addr[3]
set_location_assignment PIN_135 -to u7addr[4]
set_location_assignment PIN_140 -to u7addr[5]
set_location_assignment PIN_141 -to u7addr[10]

set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to clk
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to res_n

set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to dip
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to led
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to pmod
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to cpu

set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to uart_rx
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to uart_tx

set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to ua
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to ud

set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to u7cs_n
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to u7we_n
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to u7oe_n
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to u7addr
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to u7data

set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to u8cs_n
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to u8we_n
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to u8oe_n
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to u8addr
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to u8data

set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

project_close
