#!/bin/bash

# baseline_area_size=500

baseline_number_of_nodes=40
baseline_number_of_flow=20
baseline_number_of_packets=100
baseline_txRange=40
filename=1805062_wireless.tcl
secFile=1805062_wired.tcl


touch 1805062_wireless.txt
rm    1805062_wireless.txt
touch 1805062_wireless.txt


touch 1805062_wired.txt
rm    1805062_wired.txt
touch 1805062_wired.txt

echo -e "------------------ run.sh: starting -----------------\n"
echo -e "------------- run.sh: varying tx_Range -------------\n"
echo -e "varying tx_Range\n" >> 1805062_wireless.txt

for((i=0; i<5; i++)); do
    txRange=`expr 40 + $i \* 40`

    echo -e "$filename: running with $baseline_number_of_nodes $baseline_number_of_flow $baseline_number_of_packets $txRange\n"
    ns $filename $baseline_number_of_nodes $baseline_number_of_flow $baseline_number_of_packets $txRange
    echo -e "\nawk file: running\n"
    awk -f 1805062_wireless.awk 1805062_wireless.tr 
done

echo -e "---------- run.sh: varying number of nodes ----------\n"
echo -e "\nvarying number of nodes\n" >> 1805062_wireless.txt

for((i=0; i<5; i++)); do
    nodes=`expr 20 + $i \* 20`
    echo -e "$filename: running with $nodes $baseline_number_of_flow $baseline_number_of_packets $baseline_txRange\n"
    ns $filename $nodes $baseline_number_of_flow $baseline_number_of_packets $baseline_txRange
    echo -e "\nawk file: running\n"
    awk -f 1805062_wireless.awk 1805062_wireless.tr
done

echo -e "---------- run.sh: varying number of flows ----------\n"
echo -e "\nvarying number of flows\n" >> 1805062_wireless.txt

for((i=0; i<5; i++)); do
    flows=`expr 10 + $i \* 10`
    echo -e "$filename: running with $baseline_number_of_nodes $flows $baseline_number_of_packets $baseline_txRange\n"
    ns $filename $baseline_number_of_nodes $flows $baseline_number_of_packets $baseline_txRange
    echo -e "\nawk file: running\n"
    awk -f 1805062_wireless.awk 1805062_wireless.tr
done

echo -e "---------- run.sh: varying number of packets ----------\n"
echo -e "\nvarying number of packets\n"
echo -e "varying packets_Range\n" >> 1805062_wireless.txt
for((i=0; i<5; i++)); do
    pkts=`expr 100 + $i \* 100`
    echo -e "$filename: running with $baseline_number_of_nodes $baseline_number_of_flow $pkts $baseline_txRange\n"
    ns $filename $baseline_number_of_nodes $baseline_number_of_flow $pkts $baseline_txRange
    echo -e "\nawk file: running\n"
    awk -f 1805062_wireless.awk 1805062_wireless.tr
done


head -n7 1805062_wireless.txt  | tail -n5 > 1805062_wireless_txRange.txt
head -n15 1805062_wireless.txt | tail -n5 > 1805062_wireless_node_number.txt
head -n23 1805062_wireless.txt | tail -n5 > 1805062_wireless_flow_number.txt
head -n31 1805062_wireless.txt | tail -n5 > 1805062_wireless_pkts_number.txt



echo -e "------------------ run.sh: starting -----------------\n"
echo -e "------------- run.sh: varying packets_Range -------------\n"
echo -e "varying packets_Range\n" >> 1805062_wired.txt

for((i=0; i<5; i++)); do
    pkts=`expr 100 + $i \* 100`

    echo -e "$secFile: running with $baseline_number_of_nodes $baseline_number_of_flow $pkts\n"
    ns $secFile $baseline_number_of_nodes $baseline_number_of_flow $pkts
    echo -e "\nawk file: running\n"
    awk -f 1805062_wired.awk 1805062_wired.tr 
done


echo -e "---------- run.sh: varying number of nodes ----------\n"

echo -e "\nvarying number of nodes\n" >> 1805062_wired.txt

for((i=0; i<5; i++)); do
    nodes=`expr 20 + $i \* 20`
    echo -e "$secFile: running with $nodes $baseline_number_of_flow $baseline_number_of_packets\n"
    ns $secFile $nodes $baseline_number_of_flow $baseline_number_of_packets
    echo -e "\nawk file: running\n"
    awk -f 1805062_wired.awk 1805062_wired.tr
done



echo -e "---------- run.sh: varying number of flows ----------\n"

echo -e "\nvarying number of flows\n" >> 1805062_wired.txt

for((i=0; i<5; i++)); do
    flows=`expr 10 + $i \* 10`
    echo -e "$secFile: running with $baseline_number_of_nodes $flows $baseline_number_of_packets\n"
    ns $secFile $baseline_number_of_nodes $flows $baseline_number_of_packets
    echo -e "\nawk file: running\n"
    awk -f 1805062_wired.awk 1805062_wired.tr
done

head -n7 1805062_wired.txt  | tail -n5 > 1805062_wired_pkts.txt
head -n15 1805062_wired.txt | tail -n5 > 1805062_wired_node_number.txt
head -n23 1805062_wired.txt | tail -n5 > 1805062_wired_flow_number.txt


echo -e "---------------- run.sh: terminating ----------------\n"
