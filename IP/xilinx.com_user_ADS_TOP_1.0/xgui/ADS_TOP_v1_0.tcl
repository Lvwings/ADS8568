# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  #Adding Group
  set AXI_parameters [ipgui::add_group $IPINST -name "AXI parameters" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "C_AXI_ID_WIDTH" -parent ${AXI_parameters}
  ipgui::add_param $IPINST -name "C_AXI_ADDR_WIDTH" -parent ${AXI_parameters}
  ipgui::add_param $IPINST -name "C_AXI_DATA_WIDTH" -parent ${AXI_parameters}
  ipgui::add_param $IPINST -name "WATCH_DOG_WIDTH" -parent ${AXI_parameters}
  ipgui::add_param $IPINST -name "C_AXI_BURST_TYPE" -parent ${AXI_parameters} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_NBURST_SUPPORT" -parent ${AXI_parameters} -widget comboBox

  #Adding Group
  set Channel_parameters [ipgui::add_group $IPINST -name "Channel parameters" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "C_ADDR_AD2ETH" -parent ${Channel_parameters}
  ipgui::add_param $IPINST -name "C_ADDR_SUMOFFSET" -parent ${Channel_parameters}



}

proc update_PARAM_VALUE.C_ADDR_AD2ETH { PARAM_VALUE.C_ADDR_AD2ETH } {
	# Procedure called to update C_ADDR_AD2ETH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_AD2ETH { PARAM_VALUE.C_ADDR_AD2ETH } {
	# Procedure called to validate C_ADDR_AD2ETH
	return true
}

proc update_PARAM_VALUE.C_ADDR_SUMOFFSET { PARAM_VALUE.C_ADDR_SUMOFFSET } {
	# Procedure called to update C_ADDR_SUMOFFSET when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_SUMOFFSET { PARAM_VALUE.C_ADDR_SUMOFFSET } {
	# Procedure called to validate C_ADDR_SUMOFFSET
	return true
}

proc update_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to update C_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_BURST_TYPE { PARAM_VALUE.C_AXI_BURST_TYPE } {
	# Procedure called to update C_AXI_BURST_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_BURST_TYPE { PARAM_VALUE.C_AXI_BURST_TYPE } {
	# Procedure called to validate C_AXI_BURST_TYPE
	return true
}

proc update_PARAM_VALUE.C_AXI_DATA_WIDTH { PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to update C_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_DATA_WIDTH { PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to validate C_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_ID_WIDTH { PARAM_VALUE.C_AXI_ID_WIDTH } {
	# Procedure called to update C_AXI_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_ID_WIDTH { PARAM_VALUE.C_AXI_ID_WIDTH } {
	# Procedure called to validate C_AXI_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_NBURST_SUPPORT { PARAM_VALUE.C_AXI_NBURST_SUPPORT } {
	# Procedure called to update C_AXI_NBURST_SUPPORT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_NBURST_SUPPORT { PARAM_VALUE.C_AXI_NBURST_SUPPORT } {
	# Procedure called to validate C_AXI_NBURST_SUPPORT
	return true
}

proc update_PARAM_VALUE.WATCH_DOG_WIDTH { PARAM_VALUE.WATCH_DOG_WIDTH } {
	# Procedure called to update WATCH_DOG_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WATCH_DOG_WIDTH { PARAM_VALUE.WATCH_DOG_WIDTH } {
	# Procedure called to validate WATCH_DOG_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_AXI_ID_WIDTH { MODELPARAM_VALUE.C_AXI_ID_WIDTH PARAM_VALUE.C_AXI_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ID_WIDTH}] ${MODELPARAM_VALUE.C_AXI_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_ADDR_WIDTH PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_DATA_WIDTH PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_NBURST_SUPPORT { MODELPARAM_VALUE.C_AXI_NBURST_SUPPORT PARAM_VALUE.C_AXI_NBURST_SUPPORT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_NBURST_SUPPORT}] ${MODELPARAM_VALUE.C_AXI_NBURST_SUPPORT}
}

proc update_MODELPARAM_VALUE.C_AXI_BURST_TYPE { MODELPARAM_VALUE.C_AXI_BURST_TYPE PARAM_VALUE.C_AXI_BURST_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_BURST_TYPE}] ${MODELPARAM_VALUE.C_AXI_BURST_TYPE}
}

proc update_MODELPARAM_VALUE.WATCH_DOG_WIDTH { MODELPARAM_VALUE.WATCH_DOG_WIDTH PARAM_VALUE.WATCH_DOG_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WATCH_DOG_WIDTH}] ${MODELPARAM_VALUE.WATCH_DOG_WIDTH}
}

proc update_MODELPARAM_VALUE.C_ADDR_AD2ETH { MODELPARAM_VALUE.C_ADDR_AD2ETH PARAM_VALUE.C_ADDR_AD2ETH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_AD2ETH}] ${MODELPARAM_VALUE.C_ADDR_AD2ETH}
}

proc update_MODELPARAM_VALUE.C_ADDR_SUMOFFSET { MODELPARAM_VALUE.C_ADDR_SUMOFFSET PARAM_VALUE.C_ADDR_SUMOFFSET } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_SUMOFFSET}] ${MODELPARAM_VALUE.C_ADDR_SUMOFFSET}
}

