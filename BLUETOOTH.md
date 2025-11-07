
    run bluetoothctl to access its prompt
    run devices to list the available devices
        the output can be filtered by using optional properties, for example devices Connected
    run connect AA:BB:CC:DD:EE:FF to select the devices to modify
        the address can be autocompleted with TAB
    run set-alias "new alias for my BT device" to modify the device alias

https://superuser.com/questions/778660/changing-bluetooth-device-name

ex LTK
hex KeyLength
hex ERand
hex EDIV
hex IRK
hex CSRK
hex CSRKInboundValue <LTK> of type REG_BINARY (3), data length 16 [0x10]
:00000  16 D4 D6 47 CA 00 AC 4D 97 7C 54 3B BA 48 C3 40 ...G...M.|T;.H.@


(...)\Parameters\Keys\a83b7672ea0c\d25cbf8c537a> Value <KeyLength> of type REG_DWORD (4), data length 4 [0x4]
:00000  10 00 00 00                                     ....


(...)\Parameters\Keys\a83b7672ea0c\d25cbf8c537a> Value <ERand> of type REG_QWORD (b), data length 8 [0x8]
:00000  81 9C 2F 15 DA A4 1C 0C                         ../.....


(...)\Parameters\Keys\a83b7672ea0c\d25cbf8c537a> Value <EDIV> of type REG_DWORD (4), data length 4 [0x4]
:00000  2F 1B 00 00                                     /...


(...)\Parameters\Keys\a83b7672ea0c\d25cbf8c537a> Value <IRK> of type REG_BINARY (3), data length 16 [0x10]
:00000  82 DD 9D 3B 37 67 9A 0C BC 3E D2 1E 53 FE 2A 72 ...;7g...>..S.*r


(...)\Parameters\Keys\a83b7672ea0c\d25cbf8c537a> Value <CSRK> of type REG_BINARY (3), data length 16 [0x10]
:00000  FC BF 0D 67 11 75 45 F1 5E 18 14 66 BE F1 5D BB ...g.uE.^..f..].
