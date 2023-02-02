#!/bin/bash

echo -e "------------------ run.sh: starting -----------------\n"
touch 1805062.txt
rm    1805062.txt
touch 1805062.txt

baseline_area_size=500
baseline_number_of_nodes=40
baseline_number_of_flowe=20

echo -e "------------- run.sh: varying area size -------------\n"

echo -e "varying area size\n" >> 1805062.txt

for((i=0; i<5; i++)); do
    area_side=`expr 250 + $i \* 250`
    #echo -e $area_side >> 1805062.txt

    echo -e "1805062.tcl: running with $area_side $baseline_number_of_nodes $baseline_number_of_flowe\n"
    ns 1805062.tcl $area_side $baseline_number_of_nodes $baseline_number_of_flowe
    echo -e "\nawk file: running\n"
    awk -f 1805062.awk 1805062.tr 
done


echo -e "---------- run.sh: varying number of nodes ----------\n"

echo -e "\nvarying number of nodes\n" >> 1805062.txt

for((i=0; i<5; i++)); do
    nodes=`expr 20 + $i \* 20`
    #echo -e $nodes >> 1805062.txt
    echo -e "1805062.tcl: running with $baseline_area_size $nodes $baseline_number_of_flowe\n"
    ns 1805062.tcl $baseline_area_size $nodes $baseline_number_of_flowe
    echo -e "\nawk file: running\n"
    awk -f 1805062.awk 1805062.tr
done



echo -e "---------- run.sh: varying number of flows ----------\n"

echo -e "\nvarying number of flows\n" >> 1805062.txt

for((i=0; i<5; i++)); do
    flows=`expr 10 + $i \* 10`
    #echo -e $flows >> 1805062.txt

    echo -e "1805062.tcl: running with $baseline_area_size $baseline_number_of_nodes $flows\n"
    ns 1805062.tcl $baseline_area_size $baseline_number_of_nodes $flows
    echo -e "\nawk file: running\n"
    awk -f 1805062.awk 1805062.tr
done

head -n7 1805062.txt  | tail -n5 > 1805062_area_size.txt
head -n15 1805062.txt | tail -n5 > 1805062_node_number.txt
head -n23 1805062.txt | tail -n5 > 1805062_flow_number.txt

echo -e "---------------- run.sh: terminating ----------------\n"
