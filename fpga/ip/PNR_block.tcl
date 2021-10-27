
################################################################
# This is a generated script based on design: PNR_block
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source PNR_block_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# PNR_main, PNR_register, PNR_signal_selector

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name PNR_block

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
PNR_main\
PNR_register\
PNR_signal_selector\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set ADC_A [ create_bd_port -dir I -from 13 -to 0 -type data ADC_A ]
  set ADC_B [ create_bd_port -dir I -from 13 -to 0 -type data ADC_B ]
  set aux_i [ create_bd_port -dir I -from 31 -to 0 -type data aux_i ]
  set aux_o [ create_bd_port -dir O -from 31 -to 0 -type data aux_o ]
  set clk_i [ create_bd_port -dir I clk_i ]
  set extension_GPIO_n [ create_bd_port -dir O -from 7 -to 0 extension_GPIO_n ]
  set extension_GPIO_p [ create_bd_port -dir O -from 7 -to 0 extension_GPIO_p ]
  set led_o [ create_bd_port -dir O -from 7 -to 0 led_o ]
  set rstn_i [ create_bd_port -dir I -type data rstn_i ]
  set sys_ack [ create_bd_port -dir O -type data sys_ack ]
  set sys_addr [ create_bd_port -dir I -from 31 -to 0 -type data sys_addr ]
  set sys_err [ create_bd_port -dir O sys_err ]
  set sys_rdata [ create_bd_port -dir O -from 31 -to 0 -type data sys_rdata ]
  set sys_ren [ create_bd_port -dir I -type data sys_ren ]
  set sys_wdata [ create_bd_port -dir I -from 31 -to 0 -type data sys_wdata ]
  set sys_wen [ create_bd_port -dir I -type data sys_wen ]

  # Create instance: PNR_main_0, and set properties
  set block_name PNR_main
  set block_cell_name PNR_main_0
  if { [catch {set PNR_main_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $PNR_main_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: PNR_register_0, and set properties
  set block_name PNR_register
  set block_cell_name PNR_register_0
  if { [catch {set PNR_register_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $PNR_register_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: PNR_signal_selector_0, and set properties
  set block_name PNR_signal_selector
  set block_cell_name PNR_signal_selector_0
  if { [catch {set PNR_signal_selector_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $PNR_signal_selector_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create port connections
  connect_bd_net -net ADC_A_1 [get_bd_ports ADC_A] [get_bd_pins PNR_signal_selector_0/ADC_A]
  connect_bd_net -net ADC_B_1 [get_bd_ports ADC_B] [get_bd_pins PNR_signal_selector_0/ADC_B]
  connect_bd_net -net PNR_main_0_extension_GPIO_n [get_bd_ports extension_GPIO_n] [get_bd_pins PNR_main_0/extension_GPIO_n]
  connect_bd_net -net PNR_main_0_extension_GPIO_p [get_bd_ports extension_GPIO_p] [get_bd_pins PNR_main_0/extension_GPIO_p]
  connect_bd_net -net PNR_register_0_aux_o [get_bd_ports aux_o] [get_bd_pins PNR_register_0/aux_o]
  connect_bd_net -net PNR_register_0_led_o [get_bd_ports led_o] [get_bd_pins PNR_register_0/led_o]
  connect_bd_net -net PNR_register_0_pnr_delay [get_bd_pins PNR_main_0/pnr_delay] [get_bd_pins PNR_register_0/pnr_delay]
  connect_bd_net -net PNR_register_0_sys_ack [get_bd_ports sys_ack] [get_bd_pins PNR_register_0/sys_ack]
  connect_bd_net -net PNR_register_0_sys_err [get_bd_ports sys_err] [get_bd_pins PNR_register_0/sys_err]
  connect_bd_net -net PNR_register_0_sys_rdata [get_bd_ports sys_rdata] [get_bd_pins PNR_register_0/sys_rdata]
  connect_bd_net -net PNR_register_0_trig_clearance [get_bd_pins PNR_main_0/trig_clearance] [get_bd_pins PNR_register_0/trig_clearance]
  connect_bd_net -net PNR_register_0_trig_hysteresis [get_bd_pins PNR_main_0/trig_hysteresis] [get_bd_pins PNR_register_0/trig_hysteresis]
  connect_bd_net -net PNR_register_0_trig_is_adc_a [get_bd_pins PNR_register_0/trig_is_adc_a] [get_bd_pins PNR_signal_selector_0/trig_is_adc_a]
  connect_bd_net -net PNR_register_0_trig_is_posedge [get_bd_pins PNR_main_0/trig_is_posedge] [get_bd_pins PNR_register_0/trig_is_posedge]
  connect_bd_net -net PNR_register_0_trig_threshold [get_bd_pins PNR_main_0/trig_threshold] [get_bd_pins PNR_register_0/trig_threshold]
  connect_bd_net -net PNR_signal_selector_0_pnr_source_sig [get_bd_pins PNR_main_0/pnr_source_sig] [get_bd_pins PNR_signal_selector_0/pnr_source_sig]
  connect_bd_net -net PNR_signal_selector_0_trig_source_sig [get_bd_pins PNR_main_0/trig_source_sig] [get_bd_pins PNR_signal_selector_0/trig_source_sig]
  connect_bd_net -net aux_i_1 [get_bd_ports aux_i] [get_bd_pins PNR_register_0/aux_i]
  connect_bd_net -net clk_i_1 [get_bd_ports clk_i] [get_bd_pins PNR_main_0/ADC_CLK] [get_bd_pins PNR_register_0/clk_i]
  connect_bd_net -net rstn_i_1 [get_bd_ports rstn_i] [get_bd_pins PNR_main_0/rstn_i] [get_bd_pins PNR_register_0/rstn_i]
  connect_bd_net -net sys_addr_1 [get_bd_ports sys_addr] [get_bd_pins PNR_register_0/sys_addr]
  connect_bd_net -net sys_ren_1 [get_bd_ports sys_ren] [get_bd_pins PNR_register_0/sys_ren]
  connect_bd_net -net sys_wdata_1 [get_bd_ports sys_wdata] [get_bd_pins PNR_register_0/sys_wdata]
  connect_bd_net -net sys_wen_1 [get_bd_ports sys_wen] [get_bd_pins PNR_register_0/sys_wen]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_gid_msg -ssname BD::TCL -id 2053 -severity "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

