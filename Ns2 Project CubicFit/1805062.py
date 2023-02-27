import matplotlib.pyplot as plotter
file_num                = ["1805062_wireless_txRange.txt","1805062_wireless_node_number.txt",
                           "1805062_wireless_flow_number.txt","1805062_wireless_pkts_number.txt",]
print("x = 0 gives tx_Range vs prms, x = 1 gives nn vs prms, x = 2 gives nf vs other prms", "x = 3 gives pkts vs prms")
x = input()
x = int (x)

graph_file              = open(file_num[x], "r")
param                   = ["TX_Range","Number of Nodes","Number of Flows","No of packets"]
prm                     = [[40,80,120,160,200],[20,40,60,80,100],[10, 20, 30, 40, 50],[100,200,300,400,500]]
figs                    = []
Network_throughput      = []
End_to_end_delay        = []
Packet_delivery_ratio   = []
Packet_drop_ratio       = []
Total_Energy_Consumption=[]
for linecount in graph_file:
        metric_list = linecount.split()
        net_thr     = float(metric_list[0])
        delay_end   = float(metric_list[1])
        del_pkt     = float(metric_list[2])
        drp_pkt     = float(metric_list[3])
        tot         = float(metric_list[4])
        Network_throughput.append(net_thr)
        End_to_end_delay.append(delay_end)
        Packet_delivery_ratio.append(del_pkt)
        Packet_drop_ratio.append(drp_pkt) 
        Total_Energy_Consumption.append(tot)

graph_file.close()
figs.append(plotter.figure(x * 4 + 1))
plotter.xlabel(param[x])
plotter.ylabel("Network Throughtput (kilobits/sec)")
plotter.plot(prm[x],Network_throughput,marker = "o",color = "b")
#plotter.show();
plotter.savefig(param[x] +"result_{x*4+1}.png")

figs.append(plotter.figure(x * 4 + 2))
plotter.xlabel(param[x])
plotter.ylabel("End to End Delay (sec)")
plotter.plot(prm[x],End_to_end_delay,marker = "o",color = "b")
#plotter.show();
plotter.savefig(param[x] +"result_{x*4+2}.png")

figs.append(plotter.figure(x * 4 + 3))
plotter.xlabel(param[x])
plotter.ylabel("Packet Delivery Ratio")
plotter.plot(prm[x],Packet_delivery_ratio,marker = "o",color = "b")
#plotter.show()
plotter.savefig(param[x] +"result_{x*4+3}.png")

figs.append(plotter.figure(x * 4 + 4))
plotter.xlabel(param[x])
plotter.ylabel("Packet Drop Ratio")
plotter.plot(prm[x],Packet_drop_ratio,marker = "o",color = "b")
#plotter.show()
plotter.savefig(param[x] +"result_{x*4+4}.png")

figs.append(plotter.figure(x * 4 + 9))
plotter.xlabel(param[x])
plotter.ylabel("Total Energy Consumption")
plotter.plot(prm[x],Total_Energy_Consumption,marker = "o",color = "b")
#plotter.show()
plotter.savefig(param[x] +"result_{x*4+9}.png")

secFile = ["1805062_wired_node_number.txt","1805062_wired_flow_number.txt","1805062_wired_pkts.txt"]
print("z = 0 gives nn vs prms, z = 1 gives nf vs other prms", "x = 2 gives pkts vs prms")
z = input()
z = int (z)


graph_file              = open(file_num[z], "r")
param                   = ["Number of Nodes","Number of Flows","No of packets"]
prm                     = [[20,40,60,80,100],[10, 20, 30, 40, 50],[100,200,300,400,500]]

Net_throughput          = []
E_to_E_delay            = []
Pkt_delivery_ratio      = []
Pkt_drop_ratio          = []

for linecount in graph_file:
        metric_list = linecount.split()
        net_thr     = float(metric_list[0])
        delay_end   = float(metric_list[1])
        del_pkt     = float(metric_list[2])
        drp_pkt     = float(metric_list[3])

        Net_throughput.append(net_thr)
        E_to_E_delay.append(delay_end)
        Pkt_delivery_ratio.append(del_pkt)
        Pkt_drop_ratio.append(drp_pkt) 

graph_file.close()

figs.append(plotter.figure(x * 4 + 5))
plotter.xlabel(param[z])
plotter.ylabel("Network Throughtput (kilobits/sec)")
plotter.plot(prm[z],Network_throughput,marker = "o",color = "b")
#plotter.show()
plotter.savefig(param[z] + "result_{x*4+5}.png")

figs.append(plotter.figure(x * 4 + 6))
plotter.xlabel(param[z])
plotter.ylabel("End to End Delay (sec)")
plotter.plot(prm[z],End_to_end_delay,marker = "o",color = "b")
#plotter.show()
plotter.savefig(param[z] +"result_{x*4+6}.png")

figs.append(plotter.figure(x * 4 + 7))
plotter.xlabel(param[z])
plotter.ylabel("Packet Delivery Ratio")
plotter.plot(prm[z],Packet_delivery_ratio,marker = "o",color = "b")
#plotter.show()
plotter.savefig(param[z] +"result_{x*4+7}.png")

figs.append(plotter.figure(x * 4 + 8))
plotter.xlabel(param[z])
plotter.ylabel("Packet Drop Ratio")
plotter.plot(prm[z],Packet_drop_ratio,marker = "o",color = "b")
#plotter.show()
plotter.savefig(param[z] +"result_{x*4+8}.png")