set ns                      [new Simulator]

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
# set val(energymodel)        EnergyModel 
# set val(Energyamount)       10
# set val(rx)                 0.5
# set val(tx)                 1.0
# set val(idlepwr)            0.0
# set val(snspwr)             0.3


set val(area_size)          [lindex $argv 0]  ;# area side
set val(nn)                 [lindex $argv 1]  ;# number of mobilenodes
set val(number_flows)       [lindex $argv 2]  ;# number of flows

set trace_file              [open 1805062.tr w]
$ns trace-all               $trace_file

set nam_file                [open 1805062.nam w]
$ns namtrace-all-wireless   $nam_file $val(area_size) $val(area_size)

set topo                    [new Topography]
$topo load_flatgrid         $val(area_size) $val(area_size)

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
                            -movementTrace      OFF

# -energyModel        $val(energymodel)   \
                            # -initialEnergy      $val(Energyamount)  \
                            # -rxPower            $val(rx)            \
                            # -txPower            $val(tx)            \
                            # -idlePower          $val(idlepwr)       \
                            # -sensePower         $val(snspwr)        


for {set i 0} {$i < $val(nn)} {incr i} {

    set node($i) [$ns node]
    $node($i) random-motion 0

    $node($i) set X_ [expr int(1000 * rand()) % $val(area_size) + 0.5]
    $node($i) set Y_ [expr int(1000 * rand()) % $val(area_size) + 0.5]
    $node($i) set Z_ 0

    $ns initial_node_pos $node($i) $val(nodeSize)

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


    set tcp_tahoe            [new Agent/TCP]
    set tcp_sink             [new Agent/TCPSink]
    set telnet               [new Application/Telnet]

    $ns attach-agent         $node($src)  $tcp_tahoe
    $ns attach-agent         $node($dest) $tcp_sink
    $ns connect              $tcp_tahoe $tcp_sink
    $tcp_tahoe set fid_      $i
    $telnet attach-agent     $tcp_tahoe

    $telnet set type_        Telnet
    $telnet set packet_size_ 1000
    $telnet set random_      false

    $ns at 1.0              "$telnet start"
}

for {set i 0} {$i < $val(nn)} {incr i} {

    set Time  [expr int(20 * rand()) + 10] 
    set randx [expr int(1000 * rand()) % $val(area_size) + 0.5]
    set randy [expr int(1000 * rand()) % $val(area_size) + 0.5] 
    set randz [expr int(100 * rand()) %  $val(rate) + 1]
    $ns at $Time "$node($i) setdest $randx $randy $randz"

}

for {set i 0} {$i < $val(nn)} {incr i} {

    $ns at 50.0 "$node($i) reset"

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

$ns at 50.0001 "finish"
$ns at 50.0002 "halt"

puts "Simulation Started"
$ns run
