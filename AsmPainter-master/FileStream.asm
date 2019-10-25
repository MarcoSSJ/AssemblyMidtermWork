;通过弹窗选择输出文档名称
_GetSaveFileName proc
local @openfile: OPENFILENAME
	invoke	RtlZeroMemory,	addr @openfile,	sizeof @openfile
	invoke	crt_strcpy,	offset szFileNameBuffer,	offset szDefaultSaveFile
	mov		@openfile.lpstrFile,	offset szFileNameBuffer
	mov		@openfile.nMaxFile,		MAX_FILESIZE
	mov		@openfile.lpstrFilter,	offset	szFilter
	mov		@openfile.lpstrDefExt,	offset	szOtherBmp
	mov		@openfile.lpstrTitle,	NULL
	mov		@openfile.Flags,		OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	mov		@openfile.lStructSize,	sizeof OPENFILENAME
	mov		@openfile.hwndOwner,	NULL
	invoke	GetSaveFileName,		addr @openfile
	.if	eax
		mov eax,	offset szFileNameBuffer
		ret
	.else
		mov eax,	NULL
		ret
	.endif
	ret
_GetSaveFileName endp