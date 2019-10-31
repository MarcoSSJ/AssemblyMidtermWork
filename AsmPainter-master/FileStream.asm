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

;检查文件后缀是否是bmp
_CheckBmpSuffix proc uses ebx, _lpszFileNameBuffer: ptr byte
local	@len:	dword
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

;通过弹窗选择打开文档名称
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

;将hWnd窗口屏幕保存成HBITMAP
_SaveScreenToBmp proc uses ebx esi edi, _lpRect: ptr RECT, _hWnd: HWND
local	@hScreenDC:	HDC
local	@hMemoryDC:	HDC
local	@hBitmap:	HBITMAP
local	@hOldBitmap:	HBITMAP
local	@dwX1:		dword
local	@dwX2:		dword
local	@dwY1:		dword
local	@dwY2:		dword
local	@dwWidth:	dword
local	@dwHeight:	dword
local	@dwXReso:	dword;分辨率 resolution
local	@dwYReso:	dword
	invoke IsRectEmpty,	_lpRect
	or eax, eax
	jz @F
	;.if (eax != 0);坑!!! 莫名其妙出bug??????????
	ret
@@:

	invoke	CreateDC,addr szDisplay, NULL, NULL, NULL
	mov		@hScreenDC, eax

	invoke	CreateCompatibleDC, @hScreenDC
	mov		@hMemoryDC, eax

	mov		eax, _lpRect
	assume	eax: ptr RECT
	mov		edi, [eax].left
	mov		@dwX1, edi
	mov		edi, [eax].right
	mov		@dwX2, edi
	mov		edi, [eax].top
	mov		@dwY1, edi
	mov		edi, [eax].bottom
	mov		@dwY2, edi

	invoke GetDeviceCaps, @hScreenDC, HORZRES
	mov	@dwXReso, eax
	invoke GetDeviceCaps, @hScreenDC, VERTRES 
	mov	@dwYReso, eax

	.if (@dwX1 < 0)
		mov @dwX1, 0
	.endif

	.if (@dwY1 < 0)
		mov @dwY1, 0
	.endif

	mov eax, @dwXReso
	.if (@dwX2 > eax)
		mov @dwX2, eax
	.endif

	mov eax, @dwYReso
	.if (@dwY2 > eax)
		mov @dwY2, eax
	.endif

	mov eax, @dwX2
	sub eax, @dwX1
	mov @dwWidth, eax

	mov eax, @dwY2
	sub eax, @dwY1
	mov @dwHeight, eax

	invoke CreateCompatibleBitmap, @hScreenDC, @dwWidth, @dwHeight
	mov @hBitmap, eax

	invoke SelectObject, @hMemoryDC, @hBitmap
	mov @hOldBitmap, eax

	invoke BitBlt, @hMemoryDC, 0, 0, @dwWidth, @dwHeight, @hScreenDC,
					@dwX1, @dwY1, SRCCOPY

	invoke SelectObject, @hMemoryDC, @hOldBitmap
	
	mov @hBitmap, eax


	invoke DeleteDC, @hScreenDC
	invoke DeleteDC, @hMemoryDC

	mov eax, @hBitmap
	ret
_SaveScreenToBmp endp

;根据HBITMAP和 HBITMAPHEADERINFO保存成二进制文件
_CreateBmpFile proc uses ebx edx esi edi, _hWnd: HWND, _lpszFile: ptr byte,
				_lpBmi: PBITMAPINFO,
				_hBitmap: HBITMAP, _hDC: HDC
local @hFile: HANDLE
local @hBmpFileH: BITMAPFILEHEADER
local @pBmpInfoH: PBITMAPINFOHEADER
local @lpMem: ptr byte
local @dwTotal: dword
local @dwCntByte: dword
local @lpB:	ptr byte
local @dwTmp: dword
	mov eax, _lpBmi
	mov @pBmpInfoH, eax
	mov ebx, @pBmpInfoH
	
	assume  ebx: ptr BITMAPINFOHEADER
	invoke GlobalAlloc, GMEM_FIXED, [ebx].biSizeImage
	mov @lpMem, eax

	invoke GetDIBits, _hDC, _hBitmap, 0, [ebx].biHeight, @lpMem, _lpBmi, DIB_RGB_COLORS

	invoke CreateFile, _lpszFile, GENERIC_READ or GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
	mov @hFile, eax
	.if eax == INVALID_HANDLE_VALUE
		nop;TODO perro
	.endif

	mov @hBmpFileH.bfType, 04d42h; 42h 'B', 4dh 'M'
	mov @hBmpFileH.bfReserved1, 0
	mov @hBmpFileH.bfReserved2, 0
	;(sizeof(BITMAPFILEHEADER)+
	;	pBmpInfoH->biSize + pBmpInfoH->biClrUsed
	;	* sizeof(RGBQUAD)+pBmpInfoH->biSizeImage);
	mov ebx, @pBmpInfoH
	mov eax, [ebx].biClrUsed
	mov edi, sizeof RGBQUAD
	mul edi
	mov edi, [ebx].biSizeImage
	add eax, edi
	mov edi, [ebx].biSize
	add eax, edi
	add eax, sizeof BITMAPFILEHEADER
	mov @hBmpFileH.bfSize, eax

	;(DWORD) sizeof(BITMAPFILEHEADER)+
	;	pbih->biSize + pbih->biClrUsed
	;	* sizeof (RGBQUAD);
	mov ebx, @pBmpInfoH
	mov eax, [ebx].biClrUsed
	mov edi, sizeof RGBQUAD
	mul edi
	mov edi, [ebx].biSize
	add eax, edi
	add eax, sizeof BITMAPFILEHEADER
	mov @hBmpFileH.bfOffBits, eax

	;Copy the BITMAPFILEHEADER into the .BMP file.  
	invoke WriteFile, @hFile, addr @hBmpFileH, sizeof BITMAPFILEHEADER,
			addr @dwTmp, NULL
	.if eax == 0
		nop;TODO: perro
	.endif

	;Copy the BITMAPINFOHEADER and RGBQUAD array into the file. 
	
	;sizeof(BITMAPINFOHEADER)
	;	+pBmiFileH->biClrUsed * sizeof (RGBQUAD)
	mov ebx, @pBmpInfoH
	mov eax, [ebx].biClrUsed
	mov edi, sizeof RGBQUAD
	mul eax
	add eax, sizeof BITMAPINFOHEADER
	mov ebx, eax
	invoke WriteFile, @hFile, @pBmpInfoH, ebx, addr @dwTmp, NULL
	.if eax == 0
		nop;TODO: perro
	.endif

	mov ebx, @pBmpInfoH
	mov edi, [ebx].biSizeImage
	mov @dwTotal, edi
	mov edi, [ebx].biSizeImage
	mov @dwCntByte, edi

	mov eax, @lpMem
	mov @lpB, eax

	;Copy the array of color indices into the .BMP file.  
	invoke WriteFile, @hFile, @lpB, @dwCntByte, addr @dwTmp, NULL
	.if eax == 0
		nop;TODO: perro
	.endif

	invoke CloseHandle, @hFile
	.if eax == 0
		nop;TODO: perro
	.endif

	invoke GlobalFree, @lpMem
	mov eax,0
	ret
_CreateBmpFile endp

;根据HBITMAP保存成二进制文件
_SaveBmpToFile proc uses ebx edx ecx esi edi, _hBitmap:HBITMAP, _hWnd:HWND, _lpszFile: ptr byte
local @lpBmi: PBITMAPINFO
local @hDC: HDC
local @wColorBit: word ;PBITMAPINFOHEAD biPlanes is word
local @bmp: BITMAP
	
	;-----------------------------------------------------
	;创建BITMAPINFO内容
	invoke GetObject, _hBitmap, sizeof BITMAP, addr @bmp

	mov ax, @bmp.bmPlanes
	mul @bmp.bmBitsPixel
	.if ax == 1
		mov @wColorBit, 1
	.elseif ax <= 4
		mov @wColorBit, 4
	.elseif ax <= 8
		mov @wColorBit, 8
	.elseif ax <= 16
		mov @wColorBit, 16
	.elseif ax <= 24
		mov @wColorBit, 24
	.else
		mov @wColorBit, 32
	.endif

	mov ax, @wColorBit
	.if ax < 24
		mov bx, 1 ; bx = sizeof(BITMAPINFOHEADER)+ sizeof(RGBQUAD)* (1 << cClrBits)
		mov cx, ax
		shl bx, cl
		mov ax, bx
		mov edi, sizeof RGBQUAD
		mul edi
		add ax, sizeof BITMAPINFOHEADER
		invoke LocalAlloc, LPTR, ax
		mov @lpBmi, eax
	.else
		invoke LocalAlloc, LPTR, sizeof BITMAPINFOHEADER
		mov @lpBmi, eax
	.endif

	mov esi, @lpBmi
	assume esi: ptr BITMAPINFO
	mov [esi].bmiHeader.biSize, sizeof BITMAPINFOHEADER
	mov ebx, @bmp.bmWidth
	mov [esi].bmiHeader.biWidth, ebx
	mov ebx, @bmp.bmHeight
	mov [esi].bmiHeader.biHeight, ebx
	mov bx, @bmp.bmPlanes
	mov [esi].bmiHeader.biPlanes, bx
	mov bx, @bmp.bmBitsPixel
	mov [esi].bmiHeader.biBitCount, bx
	mov [esi].bmiHeader.biCompression, BI_RGB
	mov [esi].bmiHeader.biClrImportant, 0
	
	;((pbmi->bmiHeader.biWidth * cClrBits + 31) & ~31) / 8
	;* pbmi->bmiHeader.biHeight
	mov eax, [esi].bmiHeader.biWidth
	movzx ebx, @wColorBit
	mul ebx
	add eax, 31
	mov ebx, 31
	not ebx
	and eax, ebx
	shr eax, 3
	mov ebx, [esi].bmiHeader.biHeight
	mul ebx

	mov di, @wColorBit
	.if di < 24
		mov eax, 1
		mov ecx, edi 
		shl eax, cl
		mov [esi].bmiHeader.biClrUsed, eax
	.endif
	;---------------------------------------------------
	; HBITMAPHEADER end

	invoke GetDC, _hWnd
	mov @hDC, eax

	invoke _CreateBmpFile, _hWnd, _lpszFile, @lpBmi, _hBitmap, @hDC

	invoke DeleteDC, @hDC

	mov eax, 0
	ret
_SaveBmpToFile endp 