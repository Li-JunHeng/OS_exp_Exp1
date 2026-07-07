# Run from the repository root after creating/opening the Vivado project.
# The provided src/ip/SCPU.v and SCPU.edf are an unused CPU black-box stub;
# do not add them together with the implemented src/cpu/SCPU.v.

add_files -norecurse {
  src/board/top.v
  src/board/data_ram.v
  src/cpu/ctrl_encode_def.v
  src/cpu/alu.v
  src/cpu/ctrl.v
  src/cpu/EXT.v
  src/cpu/NPC.v
  src/cpu/PC.v
  src/cpu/RF.v
  src/cpu/SCPU.v
  src/cpu/im.v
  src/io/Enter.v
  src/io/clk_div.v
  src/io/Counter_3_IO.v
  src/ip/MIO_BUS.V
  src/ip/MIO_BUS.edf
  src/ip/Multi_8CH32.v
  src/ip/Multi_8CH32.edf
  src/ip/SPIO.v
  src/ip/SPIO.edf
  src/ip/SSeg7.v
  src/ip/SSeg7.edf
  src/ip/dm_controller.v
  src/ip/dm_controller.edf
}

add_files -fileset constrs_1 -norecurse {
  constraints/icf.xdc
}

set_property top top [current_fileset]
update_compile_order -fileset sources_1
