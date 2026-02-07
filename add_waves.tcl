proc listFromFile {filename} {
    set f [open $filename r]
    set data [split [string trim [read $f]]]
    close $f
    return $data
}

set sig_list [listFromFile build/wave_names.txt]

gtkwave::addSignalsFromList $sig_list
# set start_time 0
# set end_time 10
# gtkwave::setZoomFactor -1
# gtkwave::setZoomRangeTimes $start_time $end_time
gtkwave::/Time/Zoom/Zoom_Best_Fit
