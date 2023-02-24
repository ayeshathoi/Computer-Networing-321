BEGIN {
    total_energy_consumption = 0.0 ;
    received_packets = 0;
    sent_packets = 0;
    dropped_packets = 0;
    total_delay = 0;
    received_bytes = 0;
    
    start_time = 1000000;
    end_time = 0;

    # constants
    header_bytes = 20;
}


{
    event = $1;
    time_sec = $2;
    node = $3;
    layer = $4;
    packet_id = $6;
    packet_type = $7;
    packet_bytes = $8;
    energy = $13;			
	total_energy = $14;
	idle_energy = $16;	
	sleep_energy = $18; 
	transmit_energy = $20;	
	receive_energy = $22; 


    sub(/^_*/, "", node);
	sub(/_*$/, "", node);

    if($13=="[energy"){
		node_energy[node] = idle_energy + sleep_energy + transmit_energy + transmit_energy + receive_energy ;
        total_energy_consumption += node_energy[node]
	}	

    # set start time for the first line
    if(start_time > time_sec) {
        start_time = time_sec;
    }


    if (layer == "AGT" && packet_type == "tcp") {
        
        if(event == "s") {
            sent_time[packet_id] = time_sec;
            sent_packets += 1;
        }

        else if(event == "r") {
            delay = time_sec - sent_time[packet_id];
            
            total_delay += delay;


            bytes = (packet_bytes - header_bytes);
            received_bytes += bytes;

            
            received_packets += 1;
        }
    }

    if (packet_type == "tcp" && event == "D") {
        dropped_packets += 1;
    }
}


END {
    end_time = time_sec;
    simulation_time = end_time - start_time;


    print "Sent Packets: ", sent_packets;
    print "Dropped Packets: ", dropped_packets;
    print "Received Packets: ", received_packets;

    print "-------------------------------------------------------------";
    print "Throughput: ", (received_bytes * 8) / simulation_time, "bits/sec";
    print "Average Delay: ", (total_delay / received_packets), "seconds";
    print "Delivery ratio: ", (received_packets / sent_packets);
    print "Drop ratio: ", (dropped_packets / sent_packets);
    print "Total Energy Consumption:", total_energy_consumption ;
    
    print (received_bytes * 8) / simulation_time " " (total_delay / received_packets) " " (received_packets / sent_packets) " " (dropped_packets / sent_packets) " " (total_energy_consumption) >> "1805062_wireless.txt"

    
    
}
