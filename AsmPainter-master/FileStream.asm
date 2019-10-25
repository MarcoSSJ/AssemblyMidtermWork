_GetSaveFileW proc
local @openfile: OPENFILENAME
	invoke	ZeroMemory,	addr @openfile,	sizeof @openfile
	invoke	crt_strcpy,	offset szFileNameBuffer,	offset szDefaultSaveFile
	mov		@openfile.lpstrFile,	offset szFileNameBuffer
	mov		@openfile.nMaxFile,		MAX_FILESIZE
	mov		@openfile.lpstrFilter,	offset	szFilter
ret
endp