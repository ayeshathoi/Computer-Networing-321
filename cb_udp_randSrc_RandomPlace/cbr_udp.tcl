set ns [new Simulator]

set val(chan)                   Channel/WirelessChannel
set val(prop)                   Propagation/TwoRayGround
set val(ant)                    Antenna/OmniAntenna
set val(ll)                     LL
set val(ifq)                    Queue/DropTail/PriQueue
set val(ifqlen)                 50
set val(netif)                  Phy/WirelessPhy
set val(mac)                    Mac/802_11
set val(rp)                     DSDV
set val(energymodel)            EnergyModel 
set val(Energyamount)           100
set val(rx)                     0.5
set val(tx)                     1.0
set val(idlepwr)                0.0
set val(snspwr)                 0.3
set val(rate)                   5
set val(node_size)              15

set val(area)                   [lindex $argv 0]  
set val(nn)                     [lindex $argv 1]  
set val(nf)                     [lindex $argv 2]  

set trace_file                  [open trace.tr w]
$ns trace-all                   $trace_file

set nam_file                    [open animation.nam w]
$ns namtrace-all-wireless       $nam_file $val(area) $val(area)

set topo                        [new Topography]
$topo load_flatgrid             $val(area) $val(area)

create-god $val(nn)

$ns node-config                 -adhocRouting  $val(rp)          \
                                -llType        $val(ll)          \
                                -macType       $val(mac)         \
                                -ifqType       $val(ifq)         \
                                -ifqLen        $val(ifqlen)      \
                                -antType       $val(ant)         \
                                -propType      $val(prop)        \
                                -phyType       $val(netif)       \
                                -topoInstance  $topo             \
                                -channelType   $val(chan)        \
                                -energyModel   $val(energymodel) \
                                -initialEnergy $val(Energyamount)\
                                -rxPower       $val(rx)          \
                                -txPower       $val(tx)          \
                                -idlePower     $val(idlepwr)     \
                                -sensePower    $val(snspwr)      \
                                -agentTrace    ON                \
                                -routerTrace   ON                \
                                -macTrace      OFF               \
                                -movementTrace OFF


for {set i 0} {$i < $val(nn)} {incr i} {

    set node($i) [$ns node]
    $node($i) random-motion 0

    set positionX [expr int(1000 * rand()) % $val(area) + 0.5]
    set positionY [expr int(1000 * rand()) % $val(area) + 0.5]
    set positionZ 0

    $node($i) set X_ $positionX
    $node($i) set Y_ $positionY
    $node($i) set Z_ $positionZ

    $ns initial_node_pos $node($i) $val(node_size)
}

for {set i 0} {$i < $val(nn)} {incr i} {

    set Time      [expr int(20 * rand()) + 10] 

    set setX      [expr int(10000 * rand()) % $val(area) + 0.5]
    set setY      [expr int(10000 * rand()) % $val(area) + 0.5] 
    set setZ      [expr int(100 * rand()) % $val(rate) + 1]

    $ns at $Time "$node($i) setdest $setX $setY $setZ"

}


set dest [expr int(100 * rand()) % $val(nn)]
puts     "Destination $dest"

for {set i 0} {$i < $val(nf)} {incr i} {

    set src [expr int(100 * rand()) % $val(nn)]

    while {$src == $dest} {
        set src [expr int(100 * rand()) % $val(nn)]
        if {$src != $dest} {
            break
        }
    }


    set udp     [new Agent/UDP]
    set null    [new Agent/Null]
    set cbr     [new Application/Traffic/CBR]

    $ns attach-agent $node($src) $udp
    $ns attach-agent $node($dest) $null
    $ns connect $udp $null
    $udp set fid_ $i
    $cbr attach-agent $udp

    $cbr set type_ CBR
    $cbr set packet_size_ 1000
    $cbr set rate_ 5mb
    $cbr set random_ false

    $ns at 1.0 "$cbr start"
}

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at 50.0 "$node($i) reset"
}

proc finish_simulation {} {
    global ns trace_file nam_file
    $ns flush-trace
    close $trace_file
    close $nam_file
}

proc halt_simulation {} {
    global ns
    puts "Simulation ends"
    $ns halt
}

$ns at 50.0001 "finish_simulation"
$ns at 50.0002 "halt_simulation"

puts "Simulation starts"
$ns run
