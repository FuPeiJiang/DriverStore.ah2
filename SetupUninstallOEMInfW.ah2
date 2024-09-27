; success:=DllCall("Setupapi\SetupUninstallOEMInfW","WStr","oem17.inf","Uint",0,"Ptr",0,"Int")
success:=DllCall("Setupapi\SetupUninstallOEMInfW","WStr","oem17.inf","Uint",0x0001,"Ptr",0,"Int") ;0x0001=SUOI_FORCEDELETE
OutputDebug success "`n"
success:=0
