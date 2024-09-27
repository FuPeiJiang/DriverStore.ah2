UNICODE_STRING(str) {
    inner_buf:=Buffer(StrPut(str,"UTF-16")-2)
    StrPut(str,inner_buf,"UTF-16")
    buf:=Buffer(2*A_PtrSize)
    NumPut("UShort",inner_buf.Size,"UShort",inner_buf.Size,buf)
    NumPut("Ptr",inner_buf.Ptr,buf,A_PtrSize)
    buf.inner_buf:=inner_buf
    return buf
}

DllCall("ntdll\ApiSetQueryApiSetPresence","Ptr",UNICODE_STRING("ext-ms-win-newdev-config-l1-1-1"),"Int*",&Present:=0,"Int")
OutputDebug Present "`n"