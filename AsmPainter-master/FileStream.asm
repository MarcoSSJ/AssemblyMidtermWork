;通过弹窗选择输出文档名称
_GetSaveFileName proc, _lpszFileNameBuffer:ptr byte
local @openfile: OPENFILENAME
	invoke	RtlZeroMemory,	addr @openfile,	sizeof @openfile
	invoke	crt_strcpy,	_lpszFileNameBuffer, offset	szDefaultSaveFile
	mov		eax,					_lpszFileNameBuffer
	mov		@openfile.lpstrFile,	eax
	mov		@openfile.nMaxFile,		MAX_FILESIZE
	mov		@openfile.lpstrFilter,	offset	szFilter
	mov		@openfile.lpstrDefExt,	offset	szOtherBmp
	mov		@openfile.lpstrTitle,	NULL
	mov		@openfile.Flags,		OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	mov		@openfile.lStructSize,	sizeof OPENFILENAME
	mov		@openfile.hwndOwner,	NULL
	invoke	GetSaveFileName,		addr @openfile
	.if	eax
		mov eax,	_lpszFileNameBuffer
		ret
	.else
		mov eax,	NULL
		ret
	.endif
	ret
_GetSaveFileName endp

_CheckBmpSuffix proc uses ebx, _lpszFileNameBuffer: ptr byte
local	@len:	DWORD
	invoke	crt_strlen, _lpszFileNameBuffer
	mov		@len, eax
	mov		ebx, _lpszFileNameBuffer
	add		ebx, @len
	sub		ebx, 4
	invoke	crt_strcmp, ebx, offset szOtherBmp
	.if		eax == 0
		mov eax, 1
		ret
	.else
		mov eax, 0
		ret
	.endif
_CheckBmpSuffix endp

_GetOpenFileName proc,	_lpszFileNameBuffer:ptr byte
local @openfile: OPENFILENAME
	invoke	RtlZeroMemory,	addr @openfile,	sizeof @openfile
	invoke	crt_strcpy,	_lpszFileNameBuffer,	offset szDefaultOpenFile
	mov		eax,					_lpszFileNameBuffer
	mov		@openfile.lpstrFile,	eax
	mov		@openfile.nMaxFile,		MAX_FILESIZE
	mov		@openfile.lpstrFilter,	offset	szFilter
	mov		@openfile.lpstrDefExt,	offset	szOtherBmp
	mov		@openfile.lpstrTitle,	NULL
	mov		@openfile.Flags,		OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	mov		@openfile.lStructSize,	sizeof OPENFILENAME
	mov		@openfile.hwndOwner,	NULL
	invoke	GetSaveFileName,		addr @openfile
	.if	eax
		mov eax,	_lpszFileNameBuffer
		ret
	.else
		mov eax,	NULL
		ret
	.endif
	ret
_GetOpenFileName endp