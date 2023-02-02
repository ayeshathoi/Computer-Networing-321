import matplotlib.pyplot as plotter
file_num                = ["1805062_area_size.txt","1805062_node_number.txt","1805062_flow_number.txt"]
print("x = 0 gives area vs prms, x = 1 gives nn vs prms, x = 2 gives nf vs other prms")
x = input()
x = int (x)

graph_file              = open(file_num[x], "r")
param                   = ["Area Size","Number of Nodes","Number of Flows"]
prm                     = [[250,500,750,1000,1250],[20,40,60,80,100],[10, 20, 30, 40, 50]]

Network_throughput      = []
End_to_end_delay        = []
Packet_delivery_ratio   = []
Packet_drop_ratio       = []

for linecount in graph_file:
        metric_list = linecount.split()
        net_thr     = float(metric_list[0])
        delay_end   = float(metric_list[1])
        del_pkt     = float(metric_list[2])
        drp_pkt     = float(metric_list[3])

        Network_throughput.append(net_thr)
        End_to_end_delay.append(delay_end)
        Packet_delivery_ratio.append(del_pkt)
        Packet_drop_ratio.append(drp_pkt) 

graph_file.close()

plotter.xlabel(param[x])
plotter.ylabel("Network Throughtput (kilobits/sec)")
plotter.plot(prm[x],Network_throughput,marker = "o",color = "b")
plotter.show()

plotter.xlabel(param[x])
plotter.ylabel("End to End Delay (sec)")
plotter.plot(prm[x],End_to_end_delay,marker = "o",color = "b")
plotter.show()

plotter.xlabel(param[x])
plotter.ylabel("Packet Delivery Ratio")
plotter.plot(prm[x],Packet_delivery_ratio,marker = "o",color = "b")
plotter.show()

plotter.xlabel(param[x])
plotter.ylabel("Packet Drop Ratio")
plotter.plot(prm[x],Packet_drop_ratio,marker = "o",color = "b")
plotter.show()


