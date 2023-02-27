set ns                      [new Simulator]

set trace_file              [open 1805062_wireless.tr w]
$ns trace-all               $trace_file

set nam_file                [open 1805062_wireless.nam w]
$ns namtrace-all-wireless   $nam_file 500 500

set topo                    [new Topography]
$topo load_flatgrid         500 500


set val(nn)                 [lindex $argv 0]  ;# number of mobilenodes
set val(number_flows)       [lindex $argv 1]  ;# number of flows
set val(packetNum)          [lindex $argv 2]  ;# packet number per second
set coefficientOfTX         [lindex $argv 3]

puts "Number of nodes: $val(nn)"
puts "Number of flows: $val(number_flows)"
puts "Number of packets: $val(packetNum)"
puts "coefficientOfTX $coefficientOfTX"


set val(chan)               Channel/WirelessChannel
set val(prop)               Propagation/TwoRayGround
set val(ant)                Antenna/OmniAntenna
set val(ll)                 LL
set val(ifq)                Queue/DropTail/PriQueue
set val(ifqlen)             50
set val(netif)              Phy/WirelessPhy
set val(mac)                Mac/802_11
set val(rp)                 AODV
set val(rate)               5
set val(nodeSize)           15
set val(energymodel)        EnergyModel 
set val(Energyamount)       100
set val(rx)                 0.5
set val(tx)                 1.0
set val(idlepwr)            0.0
set val(sleeppower) 		0.3
set val(transitionpower)    0.2		
set val(transitiontime)     3


set nowValue                [Phy/WirelessPhy set Pt_]            
set newValue_Pt             [expr $coefficientOfTX * $coefficientOfTX * $nowValue]
Phy/WirelessPhy             set Pt_  $newValue_Pt;

create-god $val(nn)

$ns node-config             -adhocRouting       $val(rp)            \
                            -llType             $val(ll)            \
                            -macType            $val(mac)           \
                            -ifqType            $val(ifq)           \
                            -ifqLen             $val(ifqlen)        \
                            -antType            $val(ant)           \
                            -propType           $val(prop)          \
                            -phyType            $val(netif)         \
                            -topoInstance       $topo               \
                            -channelType        $val(chan)          \
                            -agentTrace         ON                  \
                            -routerTrace        ON                  \
                            -macTrace           OFF                 \
                            -movementTrace      OFF                 \
                            -energyModel        $val(energymodel)   \
                            -initialEnergy      $val(Energyamount)  \
                            -rxPower            $val(rx)            \
                            -txPower            $val(tx)            \
                            -idlePower          $val(idlepwr)       \
                            -sleepPower         $val(sleeppower)    \
                            -transitionPower $val(transitionpower)  \
				            -transitionTime $val(transitiontime) 
		
# set grid 1



for {set i 0} {$i < $val(nn)} {incr i} {

    set node($i) [$ns node]
    $node($i) set X_ [expr int(1000 * rand()) % 500 + 0.5]
    $node($i) set Y_ [expr int(1000 * rand()) % 500 + 0.5]

    $node($i) set Z_ 0
    $ns initial_node_pos $node($i) 20
    $ns at 50.0 "$node($i) reset"
}


set src [expr int(100 * rand()) % $val(nn)]
puts "Src $src"

for {set i 0} {$i < $val(number_flows)} {incr i} {

    set dest [expr int(100 * rand()) % $val(nn)]

    while {$src == $dest} {

        set dest [expr int(100 * rand()) % $val(nn)]

        if {$src != $dest} {
            break
        }

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
    # $ftp set packetNum_      $val(packetNum)
    # $ftp set interval_       [expr (1/$val(packetNum))]
    $tcp_cubic set maxseq_   $val(packetNum)

    $ns at 1.0              "$ftp start"
}

proc finish {} {

    global ns trace_file nam_file
    $ns flush-trace
    close $trace_file
    close $nam_file
}

proc halt {} {
    global ns
    puts "Simulation Ended"
    $ns halt
}

$ns at 10.0001 "finish"
$ns at 10.0002 "halt"

puts "Simulation Started"
$ns run
