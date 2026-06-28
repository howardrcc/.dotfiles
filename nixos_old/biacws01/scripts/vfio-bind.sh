#!/run/current-system/sw/bin/bash

# hook for unbinding drivers and bind them to vfio_pci


modprobe vfio-pci

DEVS="0000:08:00.0 0000:08:00.1 0000:08:00.2 0000:08:00.3"
for dev in $DEVS; do
    echo $dev
    vendor=$(cat /sys/bus/pci/devices/$dev/vendor)
    device=$(cat /sys/bus/pci/devices/$dev/device)
    echo $vendor
    echo $device

    # if driver exists
    if [ -e  /sys/bus/pci/devices/$dev/driver ]; then
        echo "driver $dev exists!"
        echo $dev > /sys/bus/pci/devices/$dev/driver/unbind
    fi

    
    echo $vendor $device > /sys/bus/pci/drivers/vfio_pci/new_id
done


