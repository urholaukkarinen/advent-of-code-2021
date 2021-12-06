namespace import ::tcl::mathfunc::max

# Read input file into a list start and end coordinates
# E.g. [[[0, 0], [5, 5]], ...]
proc readInput {} {
    set fp [open "input.txt" r]
    set file_data [read $fp]
    close $fp

    set lines [split $file_data "\n"]
    set parsed {}

    foreach line $lines {
        set parts [regexp -all -inline {\d+,\d+} $line]
        set start [regexp -all -inline {\d+} [lindex $parts 0]]
        set end [regexp -all -inline {\d+} [lindex $parts 1]]
        lappend parsed [list $start $end]
    }

    return $parsed
}

proc sgn {a} {expr {$a>0 ? 1 : $a<0 ? -1 : 0}}

proc solve {allowDiagonals} {
    set width 0
    set height 0

    set moves [readInput]

    # Get area that encompasses all moves
    foreach move $moves {
        foreach pos $move {
            set width [max [expr [lindex $pos 0] + 1] $width]
            set height [max [expr [lindex $pos 1] + 1] $height]
        }
    }

    # Initialize grid to zeroes
    set grid {}
    for {set i 0} {$i <= $width*$height} {incr i} {
        lappend grid 0
    }

    foreach move $moves {
        set start [lindex $move 0]
        set end [lindex $move 1]
        set x1 [lindex $start 0]
        set y1 [lindex $start 1]
        set x2 [lindex $end 0]
        set y2 [lindex $end 1]

        set dx [expr $x2 - $x1]
        set dy [expr $y2 - $y1]

        if [expr !$allowDiagonals && $dx != 0 && $dy != 0] {
            continue
        }

        set sigx [expr $dx != 0 ? [sgn $dx] : 0]
        set sigy [expr $dy != 0 ? [sgn $dy] : 0]

        set len [max [expr abs($dx)] [expr abs($dy)]]

        for {set i 0} {$i <= $len} {incr i} {
            set x [expr $x1 + ($i * $sigx)]
            set y [expr $y1 + ($i * $sigy)]
            set idx [expr ($y * $width) + $x]
            lset grid $idx [expr [lindex $grid $idx] + 1]
        }
    }

    set count 0
    foreach n $grid {
        if [expr $n > 1] {
            incr count
        }
    }

    return $count
}

# Part one
puts [solve false]
# Part two
puts [solve true]