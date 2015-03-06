
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name SlidingAverage -dir "/home/moro/Apuntes/EMB3/Project/GenericSlidingAverage/planAhead_run_3" -part xc6slx45fgg484-3
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "/home/moro/Apuntes/EMB3/Project/GenericSlidingAverage/sliding_average.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/moro/Apuntes/EMB3/Project/GenericSlidingAverage} {ipcore_dir} }
add_files [list {ipcore_dir/divider.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "sliding_average.ucf" [current_fileset -constrset]
add_files [list {sliding_average.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "/home/moro/Apuntes/EMB3/Project/GenericSlidingAverage/sliding_average.ncd"
if {[catch {read_twx -name results_1 -file "/home/moro/Apuntes/EMB3/Project/GenericSlidingAverage/sliding_average.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"/home/moro/Apuntes/EMB3/Project/GenericSlidingAverage/sliding_average.twx\": $eInfo"
}
