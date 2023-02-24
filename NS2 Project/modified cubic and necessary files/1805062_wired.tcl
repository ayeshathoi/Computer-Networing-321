set ns [new Simulator]

set trace_file              [open 1805062_wired.tr w]
$ns trace-all               $trace_file
set nam_file                [open 1805062_wired.nam w]
$ns namtrace-all            $nam_file

set val(nn)                 [lindex $argv 0]
set val(nf)                 [lindex $argv 1]
set val(np)                 [lindex $argv 2]

puts "Number of nodes: $val(nn)"
puts "Number of flows: $val(nf)"
puts "Number of packets: $val(np)"


# set grid 1;

for {set i 0} {$i < $val(nn)} {incr i} {
    set node($i) [$ns node]
}

set src                     [expr int(rand()*$val(nn))]
puts                        "src $src"

for {set i 0} {$i < $val(nf)} {incr i} {
    
    set dest [expr int(rand()*$val(nn)/2)+$val(nn)/2-1]
    while {$dest == $src} {
        set dest [expr int(rand()*$val(nn)/2)+$val(nn)/2-1]
    }

    $ns duplex-link $node($dest) $node($src) 10Mb 2ms DropTail
    $ns duplex-link $node($src) $node($dest) 2Mb 10ms DropTail
    $ns queue-limit $node($src) $node($dest) 50
    $ns queue-limit $node($dest) $node($src) 50

    set tcp_cubic            [new Agent/TCP/Linux]
    set tcp_sink             [new Agent/TCPSink/Sack1]
    set ftp                  [new Application/FTP]

    $tcp_cubic set timestamps_ true
    $ns at 0 "$tcp_cubic select_ca cubic"
    $tcp_sink set ts_echo_rfc1323_ true

    $ns attach-agent         $node($src)  $tcp_cubic
    $ns attach-agent         $node($dest) $tcp_sink
    $ns connect              $tcp_cubic $tcp_sink
    $tcp_cubic set fid_      $i
    $ftp attach-agent        $tcp_cubic

    $ftp set type_           FTP
    $tcp_cubic set window_   8000
    $ftp set packet_size_    1000
    set packet_num           $val(np)
    set interval             1

    $ns at 1.0              "$ftp start"
    $ns at 50.0             "$ftp stop"
}
$ns at 50.0 "finish"
proc finish {} {
    global ns trace_file nam_file
    $ns flush-trace  
    close $nam_file
    close $trace_file
    exit 0
}

$ns run
