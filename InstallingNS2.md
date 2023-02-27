Installing ns2 on WSL/Ubuntu
This tutorial is compitable for Windows 10

Check your WSL version from Command Prompt:

wsl -l -v
Ensure that you are running WSL version 2. If that is not the case, follow this guide to upgrade.

Step 1: Installing nam
Download the suitable nam installer from this link. After downloading, run sudo dpkg -i FILE_NAME. The apt version didn't seem to work for me.

Step 2: Installing ns2-allinone-2.35
2.1 Installing g++-4.8
Try sudo apt install g++-4.8. If this works, you are done. Proceed to step 2.
If the above command doesn't work, you will have to manually add the older repository to your system. Execute the following commands:
echo "deb [trusted=yes] http://th.archive.ubuntu.com/ubuntu bionic main universe" | sudo tee -a /etc/apt/sources.list 
sudo apt update
sudo apt install g++-4.8
If the above commands are successfully executed, you are done. Proceed to step 2.
If there are errors, try sudo apt --fix-broken install and then proceed to step 2.
2.2 Installing Dependecies (If needed)
You might face error, "fatal error: X11/Xlib.h: No such file or directory". To solve this you need to install libx11-dev using sudo apt install libx11-dev

You might face error, "otcl-1.14 configuration failed! can't find X includes". To solve this you need to install xorg-dev using sudo apt-get install xorg-dev

2.3 Installing ns2-allinone-2.35
Download the installer from this link.
Unzip the downloaded file: tar xvf ns-allinone-2.35_gcc5.tar.gz
This will create a directory named ns-allinone-2.35. Now run the following commands to install ns2:
cd ns-allinone-2.35/
export CC=gcc-4.8 CXX=g++-4.8 && ./install
cd ns-2.35/
sudo make install
If the above commands have executed successfully, you should be able to type ns in the terminal and a prompt beggining with % will appear. This marks a successful installation.
Once installed, you can make changes to the source code within the ns-2.35/ directory. Then you can incorporate those changes by executing:
make
sudo make install
Step 3: Cleanup (optional)
You might want to remove the older repository link from your system by running the following command:

sudo sed -i '$ d' /etc/apt/sources.list
Step 4: GWSL Setup
For GUI Support in WSL - Windows 10, we need to use X-Server. In this case, I am using GWSL. The version in Microsoft Store seem to become a paid app.

Download GWSL from this link from their official github repository.
Install GWSL and Run
On first run of GWSL, Windows will ask you to allow GWSL through the Windows Firewall. It is important to give it access to public and private networks. You might be asked to allow it through twice.
Open GWSL window from notification panel. Go to GWSL Distro Tools > Enable ✅ Display / Audio Auto Exporting
Optional: Go to GWSL Distro Tools > More shell and options > Enable ✅ Bash : Display / Audio Auto Exporting
Done
You should be able to run ns2 projects and view simulation of it using nam.