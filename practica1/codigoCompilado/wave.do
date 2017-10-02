onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /processor_tb/clk
add wave -noupdate /processor_tb/reset
add wave -noupdate -expand -group proc /processor_tb/i_processor/IAddr
add wave -noupdate -expand -group proc /processor_tb/i_processor/IDataIn
add wave -noupdate -expand -group proc /processor_tb/i_processor/DAddr
add wave -noupdate -expand -group proc /processor_tb/i_processor/DDataOut
add wave -noupdate -expand -group proc /processor_tb/i_processor/DDataIn
add wave -noupdate -expand -group proc /processor_tb/i_processor/pc
add wave -noupdate -expand -group proc /processor_tb/i_processor/pcmas4
add wave -noupdate -expand -group proc /processor_tb/i_processor/pcbranch
add wave -noupdate -expand -group proc /processor_tb/i_processor/pc_aftermux
add wave -noupdate -expand -group proc /processor_tb/i_processor/pcjump
add wave -noupdate -expand -group proc /processor_tb/i_processor/pcnext
add wave -noupdate -expand -group proc /processor_tb/i_processor/i_dataout
add wave -noupdate -expand -group proc /processor_tb/i_processor/opcode
add wave -noupdate -expand -group proc /processor_tb/i_processor/imm
add wave -noupdate -expand -group proc /processor_tb/i_processor/jumpoffset
add wave -noupdate -expand -group proc /processor_tb/i_processor/a1
add wave -noupdate -expand -group proc /processor_tb/i_processor/a2
add wave -noupdate -expand -group proc /processor_tb/i_processor/a3
add wave -noupdate -expand -group proc /processor_tb/i_processor/rd
add wave -noupdate -expand -group proc /processor_tb/i_processor/wd3
add wave -noupdate -expand -group proc /processor_tb/i_processor/rd1
add wave -noupdate -expand -group proc /processor_tb/i_processor/rd2
add wave -noupdate -expand -group proc /processor_tb/i_processor/we3
add wave -noupdate -expand -group proc /processor_tb/i_processor/opb
add wave -noupdate -expand -group proc /processor_tb/i_processor/immext
add wave -noupdate -expand -group proc /processor_tb/i_processor/control
add wave -noupdate -expand -group proc /processor_tb/i_processor/zflag
add wave -noupdate -expand -group proc /processor_tb/i_processor/result
add wave -noupdate -expand -group proc /processor_tb/i_processor/d_dataout
add wave -noupdate -expand -group proc /processor_tb/i_processor/branch
add wave -noupdate -expand -group proc /processor_tb/i_processor/jump
add wave -noupdate -expand -group proc /processor_tb/i_processor/regdst
add wave -noupdate -expand -group proc /processor_tb/i_processor/memread
add wave -noupdate -expand -group proc /processor_tb/i_processor/memtoreg
add wave -noupdate -expand -group proc /processor_tb/i_processor/aluop
add wave -noupdate -expand -group proc /processor_tb/i_processor/memwrite
add wave -noupdate -expand -group proc /processor_tb/i_processor/alusrc
add wave -noupdate /processor_tb/i_processor/miReg/regs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {50 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 260
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {42 ns} {78 ns}
