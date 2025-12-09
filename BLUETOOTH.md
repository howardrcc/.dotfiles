# use python script to convert Value

# step 1 register bluetooth device in windows

# STEP 2 (optional) on linux

# step 3 rename bluetooth devices address in case of logitech mx series (devices address increments on every pair)

# edit the info

# get info from using chntpw to get hex values from windows registry

# mount windows partition first

# <https://wiki.archlinux.org/title/Bluetooth#Extracting_on_Linux>

    run bluetoothctl to access its prompt
    run devices to list the available devices
        the output can be filtered by using optional properties, for example devices Connected
    run connect AA:BB:CC:DD:EE:FF to select the devices to modify
        the address can be autocompleted with TAB
    run set-alias "new alias for my BT device" to modify the device alias

<https://superuser.com/questions/778660/changing-bluetooth-device-name>

hex LTK
hex KeyLength
hex ERand
hex EDIV
hex IRK
hex CSRK
hex CSRKInboundValue <LTK> of type REG_BINARY (3), data length 16 [0x10]

# my bluetooth mac + device adress (increments )

(...)\Parameters\Keys\a83b7672ea0c\d25cbf8c537a> Value <KeyLength> of type REG_DWORD (4), data length 4 [0x4]
