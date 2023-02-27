if {$argc != 3} {
	puts "Please input in correct order <file_name> <n_nodes> <n_flow> <n_pkts_p_sec>"
	exit 1;
}
set ns [new Simulator]
$ns rtproto DV
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

for {set i 0} {$i < $val(nn)} {incr i} {
    set node($i) [$ns node]

}


for {set i 0} {$i < $val(nn)} {incr i} {
    set source_end $i 
	set dest_end [expr ($i+1)%$val(nn)]
	$ns duplex-link $node($source_end) $node($dest_end) 2Mb 10ms DropTail
	$ns queue-limit $node($source_end) $node($dest_end) 30
	
}


set src                     [expr int(rand()*$val(nn))]
puts                        "src $src"

for {set i 0} {$i < $val(nf)} {incr i} {
    
    set dest [expr int(rand()*$val(nn))]
    while {$dest == $src} {
        set dest [expr int(rand()*$val(nn))]
    }

    if {[expr $i%2 == 0]} {
		$ns color $i blue
	} else {
		$ns color $i red
	}


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
    #to set packet rate
    $ftp set packetSize_     1024
    $ftp set packetNum_      $val(np)
    # $ftp set interval_       [expr (1/$val(np))]
    $tcp_cubic set maxseq_   $val(np)

    $ns at 1.0              "$ftp start"
    $ns at 10               "$ftp stop"
}

$ns at 10.1 "finish"


proc finish {} {
    global ns trace_file nam_file
    $ns flush-trace  
    close $nam_file
    close $trace_file
    exit 0
}

$ns run
