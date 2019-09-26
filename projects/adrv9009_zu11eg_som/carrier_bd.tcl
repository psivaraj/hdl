
add_files -fileset constrs_1 -norecurse ./carrier_constr.xdc

create_bd_port -dir O -type clk i2s_mclk
create_bd_intf_port -mode Master -vlnv analog.com:interface:i2s_rtl:1.0 i2s

create_bd_port -dir I axi_fan_tacho_i
create_bd_port -dir O axi_fan_pwm_o

create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sfp_ref_clk_0
create_bd_intf_port -mode Slave -vlnv xilinx.com:display_xxv_ethernet:gt_ports:2.0 sfp_rx_0
create_bd_intf_port -mode Master -vlnv xilinx.com:display_xxv_ethernet:gt_ports:2.0 sfp_tx_0
set_property CONFIG.FREQ_HZ 156250000 [get_bd_intf_ports /sfp_ref_clk_0]

# 12.288MHz clk
ad_ip_instance axi_clkgen sys_audio_clkgen
ad_ip_parameter sys_audio_clkgen CONFIG.ID 6
ad_ip_parameter sys_audio_clkgen CONFIG.CLKIN_PERIOD 10
ad_ip_parameter sys_audio_clkgen CONFIG.VCO_DIV 2
ad_ip_parameter sys_audio_clkgen CONFIG.VCO_MUL 21
ad_ip_parameter sys_audio_clkgen CONFIG.CLK0_DIV 85.5

ad_connect sys_cpu_clk sys_audio_clkgen/clk
ad_connect sys_i2s_mclk sys_audio_clkgen/clk_0

# i2s ip
ad_ip_instance axi_i2s_adi axi_i2s_adi
ad_ip_parameter axi_i2s_adi CONFIG.DMA_TYPE 0
ad_ip_parameter axi_i2s_adi CONFIG.S_AXI_ADDRESS_WIDTH 32

# i2s dma
ad_ip_instance axi_dmac i2s_tx_dma
ad_ip_parameter i2s_tx_dma CONFIG.DMA_TYPE_SRC 0
ad_ip_parameter i2s_tx_dma CONFIG.DMA_TYPE_DEST 1
ad_ip_parameter i2s_tx_dma CONFIG.CYCLIC 1
ad_ip_parameter i2s_tx_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter i2s_tx_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter i2s_tx_dma CONFIG.ASYNC_CLK_DEST_REQ 0
ad_ip_parameter i2s_tx_dma CONFIG.ASYNC_CLK_SRC_DEST 0
ad_ip_parameter i2s_tx_dma CONFIG.ASYNC_CLK_REQ_SRC 0
ad_ip_parameter i2s_tx_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter i2s_tx_dma CONFIG.DMA_DATA_WIDTH_DEST 32
ad_ip_parameter i2s_tx_dma CONFIG.DMA_DATA_WIDTH_SRC 64

ad_ip_instance axi_dmac i2s_rx_dma
ad_ip_parameter i2s_rx_dma CONFIG.DMA_TYPE_SRC 1
ad_ip_parameter i2s_rx_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter i2s_rx_dma CONFIG.CYCLIC 1
ad_ip_parameter i2s_rx_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter i2s_rx_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter i2s_rx_dma CONFIG.ASYNC_CLK_DEST_REQ 0
ad_ip_parameter i2s_rx_dma CONFIG.ASYNC_CLK_SRC_DEST 0
ad_ip_parameter i2s_rx_dma CONFIG.ASYNC_CLK_REQ_SRC 0
ad_ip_parameter i2s_rx_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter i2s_rx_dma CONFIG.DMA_DATA_WIDTH_DEST 64
ad_ip_parameter i2s_rx_dma CONFIG.DMA_DATA_WIDTH_SRC 32

# i2s connections
ad_connect sys_cpu_clk axi_i2s_adi/s_axi_aclk
ad_connect sys_cpu_clk axi_i2s_adi/s_axis_aclk
ad_connect sys_cpu_clk axi_i2s_adi/m_axis_aclk
ad_connect sys_cpu_resetn axi_i2s_adi/s_axi_aresetn
ad_connect sys_cpu_resetn axi_i2s_adi/s_axis_aresetn
ad_connect i2s_tx_dma/m_axis axi_i2s_adi/s_axis

# i2s - not connecting tlast
ad_connect i2s_rx_dma/s_axis_data axi_i2s_adi/m_axis_tdata
ad_connect i2s_rx_dma/s_axis_valid axi_i2s_adi/m_axis_tvalid
ad_connect i2s_rx_dma/s_axis_ready axi_i2s_adi/m_axis_tready
ad_connect i2s axi_i2s_adi/I2S
ad_connect sys_i2s_mclk axi_i2s_adi/data_clk_i
ad_connect sys_i2s_mclk i2s_mclk

ad_connect sys_cpu_clk i2s_tx_dma/s_axi_aclk
ad_connect sys_cpu_clk i2s_tx_dma/m_src_axi_aclk
ad_connect sys_cpu_clk i2s_tx_dma/m_axis_aclk
ad_connect sys_cpu_resetn i2s_tx_dma/s_axi_aresetn
ad_connect sys_cpu_resetn i2s_tx_dma/m_src_axi_aresetn

ad_connect sys_cpu_clk i2s_rx_dma/s_axi_aclk
ad_connect sys_cpu_clk i2s_rx_dma/m_dest_axi_aclk
ad_connect sys_cpu_clk i2s_rx_dma/s_axis_aclk
ad_connect sys_cpu_resetn i2s_rx_dma/s_axi_aresetn
ad_connect sys_cpu_resetn i2s_rx_dma/m_dest_axi_aresetn

# sfp ip

ad_ip_instance xxv_ethernet ethernet_sfp
ad_ip_parameter ethernet_sfp CONFIG.ADD_GT_CNTRL_STS_PORTS {0}
ad_ip_parameter ethernet_sfp CONFIG.BASE_R_KR {BASE-R}
ad_ip_parameter ethernet_sfp CONFIG.CORE {Ethernet MAC+PCS/PMA 64-bit}
ad_ip_parameter ethernet_sfp CONFIG.DATA_PATH_INTERFACE {AXI Stream}
ad_ip_parameter ethernet_sfp CONFIG.ENABLE_PREEMPTION {0}
ad_ip_parameter ethernet_sfp CONFIG.ENABLE_TIME_STAMPING {0}
ad_ip_parameter ethernet_sfp CONFIG.GT_GROUP_SELECT {Quad_X0Y5}
ad_ip_parameter ethernet_sfp CONFIG.GT_LOCATION {1}
ad_ip_parameter ethernet_sfp CONFIG.INCLUDE_AXI4_INTERFACE {1}
ad_ip_parameter ethernet_sfp CONFIG.INCLUDE_USER_FIFO {1}
ad_ip_parameter ethernet_sfp CONFIG.LANE1_GT_LOC {X0Y23}

ad_ip_instance axi_dma dma_sfp
ad_ip_parameter dma_sfp CONFIG.c_include_sg 1
ad_ip_parameter dma_sfp CONFIG.c_include_mm2s 1
ad_ip_parameter dma_sfp CONFIG.c_m_axi_mm2s_data_width 64
ad_ip_parameter dma_sfp CONFIG.c_m_axis_mm2s_tdata_width 64
ad_ip_parameter dma_sfp CONFIG.c_include_mm2s_dre 1
ad_ip_parameter dma_sfp CONFIG.c_mm2s_burst_size 16
ad_ip_parameter dma_sfp CONFIG.c_include_s2mm 1
ad_ip_parameter dma_sfp CONFIG.c_include_s2mm_dre 1
ad_ip_parameter dma_sfp CONFIG.c_s2mm_burst_size 16
ad_ip_parameter dma_sfp CONFIG.c_sg_include_stscntrl_strm 0

ad_ip_instance axis_data_fifo rx_stream_fifo
ad_ip_parameter rx_stream_fifo CONFIG.FIFO_DEPTH 32768
ad_ip_parameter rx_stream_fifo CONFIG.FIFO_MODE 2
ad_ip_parameter rx_stream_fifo CONFIG.IS_ACLK_ASYNC 0
ad_ip_parameter rx_stream_fifo CONFIG.FIFO_MEMORY_TYPE auto

ad_ip_instance axis_data_fifo tx_stream_fifo
ad_ip_parameter tx_stream_fifo CONFIG.FIFO_DEPTH 32768
ad_ip_parameter tx_stream_fifo CONFIG.FIFO_MODE 2
ad_ip_parameter tx_stream_fifo CONFIG.IS_ACLK_ASYNC 0
ad_ip_parameter tx_stream_fifo CONFIG.FIFO_MEMORY_TYPE auto

ad_ip_instance util_vector_logic util_not_0
ad_ip_parameter util_not_0 CONFIG.C_SIZE 1
ad_ip_parameter util_not_0 CONFIG.C_OPERATION not

ad_ip_instance util_vector_logic util_not_1
ad_ip_parameter util_not_1 CONFIG.C_SIZE 1
ad_ip_parameter util_not_1 CONFIG.C_OPERATION not

ad_ip_instance util_vector_logic util_not_2
ad_ip_parameter util_not_2 CONFIG.C_SIZE 1
ad_ip_parameter util_not_2 CONFIG.C_OPERATION not

ad_ip_instance util_vector_logic util_not_3
ad_ip_parameter util_not_3 CONFIG.C_SIZE 1
ad_ip_parameter util_not_3 CONFIG.C_OPERATION not

ad_ip_instance util_vector_logic util_not_4
ad_ip_parameter util_not_4 CONFIG.C_SIZE 1
ad_ip_parameter util_not_4 CONFIG.C_OPERATION not

ad_ip_instance xlconstant constant_101b
ad_ip_parameter constant_101b CONFIG.CONST_WIDTH {3}
ad_ip_parameter constant_101b CONFIG.CONST_VAL {5}

ad_ip_instance xlconstant const_2
ad_ip_parameter const_2 CONFIG.CONST_WIDTH 56
ad_ip_parameter const_2 CONFIG.CONST_VAL 0

# sfp connections

ad_connect tx_stream_fifo/m_axis ethernet_sfp/axis_tx_0
ad_connect tx_stream_fifo/s_axis dma_sfp/M_AXIS_MM2S
ad_connect rx_stream_fifo/m_axis dma_sfp/S_AXIS_S2MM
ad_connect rx_stream_fifo/s_axis ethernet_sfp/axis_rx_0

ad_connect ethernet_sfp/tx_clk_out_0 tx_stream_fifo/s_axis_aclk
ad_connect ethernet_sfp/rx_clk_out_0 rx_stream_fifo/s_axis_aclk
ad_connect ethernet_sfp/tx_clk_out_0 dma_sfp/m_axi_mm2s_aclk
ad_connect ethernet_sfp/rx_clk_out_0 dma_sfp/m_axi_s2mm_aclk
ad_connect sys_cpu_clk dma_sfp/m_axi_sg_aclk

ad_connect util_not_1/op1 ethernet_sfp/user_tx_reset_0
ad_connect util_not_1/res tx_stream_fifo/s_axis_aresetn
ad_connect util_not_2/op1 ethernet_sfp/user_rx_reset_0
ad_connect util_not_2/res rx_stream_fifo/s_axis_aresetn
 
ad_connect sfp_ref_clk_0 ethernet_sfp/gt_ref_clk
ad_connect sfp_rx_0 ethernet_sfp/gt_rx
ad_connect sfp_tx_0 ethernet_sfp/gt_tx
ad_connect const_2/dout ethernet_sfp/tx_preamblein_0

ad_connect sys_ps8/pl_resetn0 util_not_0/op1
ad_connect util_not_0/res ethernet_sfp/gtwiz_reset_tx_datapath_0
ad_connect util_not_0/res ethernet_sfp/gtwiz_reset_rx_datapath_0

ad_connect dma_sfp/s2mm_prmry_reset_out_n util_not_3/Op1
ad_connect util_not_3/Res ethernet_sfp/rx_reset_0
ad_connect dma_sfp/mm2s_prmry_reset_out_n util_not_4/Op1
ad_connect util_not_4/Res ethernet_sfp/tx_reset_0

ad_connect sys_cpu_clk  ethernet_sfp/dclk
ad_connect sys_cpu_reset  ethernet_sfp/sys_reset
ad_connect constant_101b/dout ethernet_sfp/rxoutclksel_in_0
ad_connect constant_101b/dout ethernet_sfp/txoutclksel_in_0
ad_connect ethernet_sfp/rx_core_clk_0 ethernet_sfp/rx_clk_out_0

# fan control

ad_ip_instance axi_fan_control axi_fan_control_0
ad_ip_parameter axi_fan_control_0 CONFIG.ID 1
ad_ip_parameter axi_fan_control_0 CONFIG.PWM_FREQUENCY_HZ 1000

ad_connect axi_fan_tacho_i axi_fan_control_0/tacho
ad_connect axi_fan_pwm_o axi_fan_control_0/pwm

# interconnect

ad_cpu_interconnect 0x40000000 axi_fan_control_0
ad_cpu_interconnect 0x41000000 i2s_rx_dma
ad_cpu_interconnect 0x41001000 i2s_tx_dma
ad_cpu_interconnect 0x41010000 sys_audio_clkgen
ad_cpu_interconnect 0x42000000 axi_i2s_adi
ad_cpu_interconnect 0x43000000 ethernet_sfp
ad_cpu_interconnect 0x44000000 dma_sfp

ad_mem_hp0_interconnect sys_cpu_clk i2s_tx_dma/m_src_axi
ad_mem_hp0_interconnect sys_cpu_clk i2s_rx_dma/m_dest_axi

# interrupts

ad_cpu_interrupt ps-6 mb-6 i2s_tx_dma/irq
ad_cpu_interrupt ps-7 mb-7 i2s_rx_dma/irq
ad_cpu_interrupt ps-0 mb-0 dma_sfp/mm2s_introut
ad_cpu_interrupt ps-1 mb-1 dma_sfp/s2mm_introut
ad_cpu_interrupt ps-14 mb-14 axi_fan_control_0/irq

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/sys_ps8/pl_clk0 (99 MHz)} Clk_slave {/sys_ps8/pl_clk0 (99 MHz)} Clk_xbar {/sys_ps8/pl_clk0 (99 MHz)} Master {/dma_sfp/M_AXI_SG} Slave {/sys_ps8/S_AXI_HP0_FPD} intc_ip {/axi_hp0_interconnect} master_apm {0}}  [get_bd_intf_pins dma_sfp/M_AXI_SG]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/ethernet_sfp/tx_clk_out_0 (156 MHz)} Clk_slave {/sys_ps8/pl_clk0 (99 MHz)} Clk_xbar {/sys_ps8/pl_clk0 (99 MHz)} Master {/dma_sfp/M_AXI_MM2S} Slave {/sys_ps8/S_AXI_HP0_FPD} intc_ip {/axi_hp0_interconnect} master_apm {0}}  [get_bd_intf_pins dma_sfp/M_AXI_MM2S]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/ethernet_sfp/rx_clk_out_0 (156 MHz)} Clk_slave {/sys_ps8/pl_clk0 (99 MHz)} Clk_xbar {/sys_ps8/pl_clk0 (99 MHz)} Master {/dma_sfp/M_AXI_S2MM} Slave {/sys_ps8/S_AXI_HP0_FPD} intc_ip {/axi_hp0_interconnect} master_apm {0}}  [get_bd_intf_pins dma_sfp/M_AXI_S2MM]
endgroup
