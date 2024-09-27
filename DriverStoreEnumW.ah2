; https://github.com/lostindark/DriverStoreExplorer/blob/master/Rapr/Utils/SetupAPI.cs
; https://github.com/lostindark/DriverStoreExplorer/blob/master/Rapr/Utils/DeviceHelper.cs

#DllLoad drvstore
byClass:=Map()
byClass.Default := false

DllCall("ole32\CLSIDFromString","WStr","{8163eb01-142c-4f7a-94e1-a274cc47dbba}","Ptr",DEVPKEY_DriverPackage_ClassGuid:=Buffer(0x14))
NumPut("Uint",13,DEVPKEY_DriverPackage_ClassGuid,0x10)
; internal static readonly DevPropKey DEVPKEY_DriverPackage_ClassGuid =               new DevPropKey(0x8163eb01, 0x142c, 0x4f7a, 0x94, 0xe1, 0xa2, 0x74, 0xcc, 0x47, 0xdb, 0xba, 13);   // DEVPROP_TYPE_GUID
DllCall("ole32\CLSIDFromString","WStr","{8163eb01-142c-4f7a-94e1-a274cc47dbba}","Ptr",DEVPKEY_DriverPackage_ProviderName:=Buffer(0x14))
NumPut("Uint",12,DEVPKEY_DriverPackage_ProviderName,0x10)
; internal static readonly DevPropKey DEVPKEY_DriverPackage_ProviderName =            new DevPropKey(0x8163eb01, 0x142c, 0x4f7a, 0x94, 0xe1, 0xa2, 0x74, 0xcc, 0x47, 0xdb, 0xba, 12);   // DEVPROP_TYPE_STRING

propertyBuffer:=Buffer(2048)
guid_map_DriverClass:=Map(0x11CEE3254D36E97D,"System Devices",0x4994D189D94EE5D8,"Security Devices",0x49F05A8188BAE032,"USB Device",0x11CFC46536FC9E60,"USB host controllers and USB hubs",0x11D0810F6BDD1FC6,"Imaging Device",0x11CEE3254D36E979,"Printers",0x11CEE3254D36E972,"Network Adapter",0x11CEE3254D36E974,"Network Service",0x4647CD8BE0CBF06C,"Bluetooth Devices",0x11CEE3254D36E968,"Display Adapters",0x4D14377C53D29EF7,"Biometric Device")
guid_map_DriverClass.Default:="Unknown"
c1Max:=0,c2Max:=0
EnumerateDriverPackageCallback(driverStoreHandle, driverStoreFilename, pDriverPackageInfo, lParam) {
    global c1Max, c2Max
    SplitPath StrGet(driverStoreFilename, "UTF-16"), &InfName
    DriverPublishedName:=StrGet(pDriverPackageInfo+0xac, "UTF-16")
    ; OutputDebug InfName " " StrGet(pDriverPackageInfo+0xac, "UTF-16") "`n" ;ushort + LOCALE_NAME_MAX_LENGTH

    DllCall("drvstore\DriverStoreGetObjectPropertyW", "Ptr", driverStoreHandle, "Uint", 0x00000002, "Ptr", driverStoreFilename, "Ptr", DEVPKEY_DriverPackage_ProviderName, "Uint*", &DevPropType:=0, "Ptr", propertyBuffer, "Uint", propertyBuffer.Size, "Uint*", &propertySize:=0, "Uint", 0)
    DriverPkgProvider:=StrGet(propertyBuffer, "UTF-16")

    ; internal static extern bool DriverStoreGetObjectProperty(
    ;     IntPtr driverStoreHandle,
    ;     DriverStoreObjectType objectType,
    ;     string objectName,
    ;     ref DevPropKey propertyKey,
    ;     out DevPropType propertyType,
    ;     IntPtr propertyBuffer,
    ;     int bufferSize,
    ;     out uint propertySize,
    ;     DriverStoreSetObjectPropertyFlags flag);
    DllCall("drvstore\DriverStoreGetObjectPropertyW", "Ptr", driverStoreHandle, "Uint", 0x00000002, "Ptr", driverStoreFilename, "Ptr", DEVPKEY_DriverPackage_ClassGuid, "Uint*", &DevPropType:=0, "Ptr", propertyBuffer, "Uint", propertyBuffer.Size, "Uint*", &propertySize:=0, "Uint", 0)
    ; VarSetStrCapacity(&sGUID, 38)
    ; DllCall("Ole32\StringFromGUID2", "Ptr", propertyBuffer, "WStr", sGUID, "Int", 39)
    ; OutputDebug sGUID "`n"

    ; OutputDebug Format("{:016X}",NumGet(propertyBuffer,"Uint64")) "`n"
    DriverClass:=guid_map_DriverClass[NumGet(propertyBuffer,"Uint64")]
    arr := byClass[DriverClass]
    if (!arr) {
        byClass[DriverClass] := arr := []
    }
    arr.push({InfName:InfName,DriverPublishedName:DriverPublishedName,DriverPkgProvider:DriverPkgProvider})
    ; OutputDebug ok "`n"

    len:=StrLen(InfName)
    if (len>c1Max) {
        c1Max:=len
    }
    len:=StrLen(DriverPkgProvider)
    if (len>c2Max) {
        c2Max:=len
    }

    return 1
}

DllCall("drvstore\DriverStoreEnumW","Ptr",0,"Uint",0x00000002,"Ptr",CallbackCreate(EnumerateDriverPackageCallback),"Ptr",0)
for DriverClass, arr in byClass {
    OutputDebug "[" DriverClass "]`n"
    ; OutputDebug "[" DriverClass "]" StrReplace(Format("{:0" max(0,80-2-StrLen(DriverClass)) "}",""),"0","-") "`n"
    for v in arr {
        OutputDebug Format("  > {:-" c1Max "} | {:-" c2Max "} | {}`n", v.InfName,v.DriverPkgProvider,v.DriverPublishedName)
    }
}

; DispatchCommandOperation
; EnumerateDriverPackages