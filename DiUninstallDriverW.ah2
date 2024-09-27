; success:=DllCall("newdev\DiUninstallDriverW","Ptr",0,"WStr","C:\Windows\System32\DriverStore\FileRepository\_\.inf","Uint",0x00000001,"Int*",&NeedReboot:=0,"Int") ;0x00000001=DIURFLAG_NO_REMOVE_INF
success:=DllCall("newdev\DiUninstallDriverW","Ptr",0,"WStr","C:\Windows\System32\DriverStore\FileRepository\_\.inf","Uint",0,"Int*",&NeedReboot:=0,"Int")
OutputDebug success "`n"
success:=0

; if this flag is set to DIURFLAG_NO_REMOVE_INF, DiUninstallDriver removes the driver package from any devices it is installed on, but does not remove the driver package from the Driver Store.

; #define DIURFLAG_NO_REMOVE_INF      0x00000001   // Do not remove inf from the system
; #define DIURFLAG_UNCONFIGURE_INF    0x00000002   // Unconfigure inf, if possible