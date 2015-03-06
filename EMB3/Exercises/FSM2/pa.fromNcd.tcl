
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name FSM2 -dir "/home/moro/Apuntes/EMB3/Exercises/FSM2/planAhead_run_1" -part xc6slx45fgg484-3
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "/home/moro/Apuntes/EMB3/Exercises/FSM2/FSM.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/moro/Apuntes/EMB3/Exercises/FSM2} }
set_property target_constrs_file "rmemb3_xc6slx45_master.ucf" [current_fileset -constrset]
add_files [list {rmemb3_xc6slx45_master.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "/home/moro/Apuntes/EMB3/Exercises/FSM2/FSM.ncd"
if {[catch {read_twx -name results_1 -file "/home/moro/Apuntes/EMB3/Exercises/FSM2/FSM.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"/home/moro/Apuntes/EMB3/Exercises/FSM2/FSM.twx\": $eInfo"
}
