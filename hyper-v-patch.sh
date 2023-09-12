#!/bin/bash

# Hyper-V patching only
sudo echo 'hv_vmbus' >> /etc/initramfs-tools/modules
sudo echo 'hv_storvsc' >> /etc/initramfs-tools/modules
sudo echo 'hv_blkvsc' >> /etc/initramfs-tools/modules
sudo echo 'hv_netvsc' >> /etc/initramfs-tools/modules
sudo echo 'hv_utils' >> /etc/initramfs-tools/modules
sudo apt install linux-virtual linux-cloud-tools-virtual linux-tools-virtual -y
sudo update-initramfs -u