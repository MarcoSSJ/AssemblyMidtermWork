.386
.model flat,stdcall
option casemap:none

include windows.inc
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
include gdi32.inc
includelib gdi32.lib
include comctl32.inc
includelib comctl32.lib
include comdlg32.inc
includelib comdlg32.lib
include msvcrt.inc
includelib msvcrt.lib

WM_CHANGE_COLOR			equ			WM_USER + 1
IDR_MENU1               equ			101
IDM_OPEN				equ			40001
IDM_SAVE				equ			40002
ID_FILE_OPENFILE		equ			40002
ID_FILE_SAVE			equ			40003

.data
MouseClick				db			FALSE
fgColor					dd			0
acrCustClr				dd			16 dup(0)
;openFileN							OPENFILENAME <>
FilterString            byte		"BitMap(*.bmp)",0,"*.bmp",0
OtherBmp				byte		".bmp",0

aColor			dd			0h,\
							0c0c0c0h,\
							0808080h,\
							0ff0000h,\
							0800000h,\
							0ffff00h,\
							0808000h,\
							0ff00h,\
							08000h,\
							0ffffh,\
							08080h,\
							0ffh,\
							080h,\
							0ff00ffh,\
							0800080h,\
							0ffff80h,\
							0808040h,\
							0ff80h,\
							04040h,\
							080ffffh,\
							080ffh,\
							08080ffh,\
							04080h,\
							0ff0080h
szColor = ($ - offset aColor)

.data?
hInstance				dd			?
hWinMain				dd			? 
hWndSendTo				dd			?
hMenu					dd			?
hAccelerator			dd			?
buffer					dd			?
hitpoint				POINT		<>
movpoint				POINT		<>
fileNameBuffer			byte		1000 DUP(?)


.const
szClassName			db		'MyClass',0
szCaptionMain		db		'MyPainter',0
szColorBtnClass     db      'ColorBtn', 0
szColorBoxClass     db      'ColorBox', 0
WndWidth				equ		800
WndHeight				equ		600
buttonWidth				equ		40

.code

_MySaveFile proc USES edx ebx hWnd:HWND
	local @hdc:HDC
	local @hdcBmp:HDC
	local @hBmpBuffer:HBITMAP
	local @bmfHeader:BITMAPFILEHEADER   
	local @BitFore:BITMAPINFOHEADER   
	local @bmpScreen:BITMAP
	local @DWSize:dword
	local @hDIB:HANDLE
	local @lpbitmap:PTR byte
	local @hFile:HANDLE  
	local @DIBSize:dword
	local @WrittenBytes:dword
	local @len:dword
	local @SF:OPENFILENAME

	invoke	RtlZeroMemory,addr @SF,sizeof @SF
	mov  @SF.lStructSize,SIZEOF @SF
	mov  @SF.hwndOwner,NULL 
	;push hInstance 
	;pop  openFileN.hInstance 
	mov  @SF.lpstrFilter,OFFSET FilterString 
	mov  @SF.lpstrFile,OFFSET fileNameBuffer 
	mov  @SF.nMaxFile,SIZEOF fileNameBuffer 
	mov  @SF.Flags,OFN_PATHMUSTEXIST
	invoke GetSaveFileName,ADDR @SF
	.IF (!eax)
		ret
	.ENDIF

	invoke crt_strlen, offset fileNameBuffer
	mov @len, eax
	mov ebx, offset fileNameBuffer
	add ebx, @len
	sub  ebx, 4
	invoke crt_strcmp, ebx, offset OtherBmp
	.if eax != 0
	add ebx, 4
	invoke crt_strcpy, ebx, offset OtherBmp
	.endif

	invoke GetDC,hWnd;函数功能：该函数检索一指定窗口的客户区域或整个屏幕的显示设备上下文环境的句柄，以后可以在GDI函数中使用该句柄来在设备上下文环境中绘图。
	mov @hdc,eax
	invoke CreateCompatibleDC,@hdc;该函数创建一个与指定设备兼容的内存设备上下文环境（DC）
	mov @hdcBmp,eax
	invoke SetStretchBltMode,@hdc,HALFTONE;Windows GDI函数，功能为该函数可以设置指定设备环境中的位图拉伸模式。
	invoke CreateCompatibleBitmap,@hdc,WndWidth,WndHeight;该函数用于创建与指定的设备环境相关的设备兼容的位图。
	mov @hBmpBuffer,eax
	invoke SelectObject,@hdcBmp,@hBmpBuffer;The SelectObject function selects an object into the specified device context (DC). The new object replaces the previous object of the same type.
	invoke BitBlt,@hdcBmp,0,0,WndWidth,WndHeight,buffer,0,0,SRCCOPY;The BitBlt function performs a bit-block transfer of the color data corresponding to a rectangle of pixels from the specified source device context into a destination device context.
	invoke GetObject,@hBmpBuffer,SIZEOF BITMAP,addr @bmpScreen;The GetObject function retrieves information for the specified graphics object.
	push sizeof BITMAPINFOHEADER
	pop @BitFore.biSize;参见这里https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
	push @bmpScreen.bmWidth
	pop @BitFore.biWidth
	push @bmpScreen.bmHeight
	pop @BitFore.biHeight
	mov @BitFore.biPlanes,1
	mov @BitFore.biBitCount,32
	mov @BitFore.biCompression,BI_RGB
	mov @BitFore.biSizeImage,0
	mov @BitFore.biXPelsPerMeter,0
	mov @BitFore.biYPelsPerMeter,0
	mov @BitFore.biClrUsed,0
	mov @BitFore.biClrImportant,0

	movzx eax,@BitFore.biBitCount;movzx零填充
	mul @bmpScreen.bmWidth
	add eax,31
	mov ebx,32
	cdq; 这个指令把 EAX 的第 31 bit 复制到 EDX 的每一个 bit 上。 它大多出现在除法运算之前。它实际的作用只是把EDX的所有位都设成EAX最高位的值
	div ebx
	mov edx,4
	mul edx
	mul @bmpScreen.bmHeight
	mov @DWSize,eax
	invoke GlobalAlloc,GHND,@DWSize
	mov @hDIB,eax
	invoke GlobalLock,@hDIB;Locks a global memory object and returns a pointer to the first byte of the object's memory block.
	mov @lpbitmap,eax

	invoke GetDIBits,@hdc,@hBmpBuffer,0,@bmpScreen.bmHeight,@lpbitmap,addr @BitFore,DIB_RGB_COLORS;The GetDIBits function retrieves the bits of the specified compatible bitmap and copies them into a buffer as a DIB using the specified format.
	invoke CreateFile,addr fileNameBuffer,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL;This function creates, opens, or truncates a file, COM port, device, service, or console. It returns a handle that you can use to access the object.
	mov @hFile,eax
	mov eax,@DWSize 
	add eax,sizeof BITMAPFILEHEADER
	add eax,sizeof BITMAPINFOHEADER
	mov @DIBSize,eax

	mov eax,sizeof BITMAPFILEHEADER
	add eax,sizeof BITMAPINFOHEADER
	mov @bmfHeader.bfOffBits,eax
	push @DIBSize
	pop @bmfHeader.bfSize
	mov @bmfHeader.bfType,4D42h;' file type always 4D42h or "BM"
								;https://rerickso.w3.uvm.edu/projects/vb_bmp/BMP.html 利用c写的

	invoke WriteFile,@hFile,addr @bmfHeader,sizeof BITMAPFILEHEADER,addr @WrittenBytes,NULL
	invoke WriteFile,@hFile,addr @BitFore,sizeof BITMAPINFOHEADER,addr @WrittenBytes,NULL
	invoke WriteFile,@hFile,@lpbitmap,@DWSize,addr @WrittenBytes,NULL

	invoke GlobalUnlock,@hDIB;Decrements the lock count associated with a memory object that was allocated with GMEM_MOVEABLE. This function has no effect on memory objects allocated with GMEM_FIXED.
	invoke GlobalFree,@hDIB;Frees the specified global memory object and invalidates its handle.
	invoke CloseHandle,@hFile

	invoke DeleteDC,@hdcBmp
	invoke DeleteObject,@hBmpBuffer
	invoke ReleaseDC,hWnd,@hdc
	ret
_MySaveFile endp

_MyOpenFile proc hWnd:HWND
	local @hdc:HDC
	local @hdcBmp:HDC
	local @hBmp:HBITMAP
	local @tempDC:HDC
	local @tempBmp:HBITMAP
	local @OF:OPENFILENAME

	; open file
	invoke	RtlZeroMemory,addr @OF,sizeof @OF
	mov  @OF.lStructSize,sizeof @OF
	mov  @OF.hwndOwner,NULL
	mov  @OF.lpstrFilter,OFFSET FilterString
	mov  @OF.lpstrFile,OFFSET fileNameBuffer 
	mov  @OF.nMaxFile,sizeof fileNameBuffer 
	mov  @OF.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
	invoke GetOpenFileName,ADDR @OF
	.IF (!eax)
		ret
	.ENDIF
	; 成功打开，初始化环境，load 进来
	invoke GetDC,hWnd
	mov @hdc,eax
	invoke CreateCompatibleDC,@hdc
	mov @tempDC,eax
	invoke CreateCompatibleDC,@hdc
	mov @hdcBmp,eax
	invoke CreateCompatibleBitmap,@hdc,WndWidth,WndHeight
	mov @tempBmp,eax
	invoke SelectObject,@tempDC,@tempBmp
	invoke BitBlt,@tempDC,0,0,WndWidth,WndHeight,buffer,0,0,SRCCOPY

	invoke LoadImage,hInstance,addr fileNameBuffer,IMAGE_BITMAP,0,0,LR_LOADFROMFILE 
	.IF (!eax)
		ret
	.ENDIF

	
	mov @hBmp,HBITMAP PTR eax
	invoke SelectObject,@hdcBmp,@hBmp
	invoke BitBlt,@tempDC,0,0,WndWidth,WndHeight,@hdcBmp,0,0,SRCCOPY
	invoke BitBlt,buffer,0,0,WndWidth,WndHeight,@tempDC,0,0,SRCCOPY
    
	invoke DeleteDC,@hdcBmp
	invoke DeleteDC,@tempDC
	invoke DeleteObject,@tempBmp
	invoke ReleaseDC,hWnd,@hdc

	invoke InvalidateRect,hWnd,0,FALSE
	invoke UpdateWindow,hWnd
	ret
_MyOpenFile endp

_MySelectColor proc hWnd:HWND
	local @myColor:CHOOSECOLOR

	mov @myColor.lStructSize,sizeof @myColor
	mov eax,hWnd
	mov @myColor.hwndOwner,eax
	mov eax,hInstance
	mov @myColor.hInstance,eax
	mov @myColor.rgbResult,0
	mov eax,offset acrCustClr
	mov @myColor.lpCustColors,eax
	mov @myColor.Flags,CC_FULLOPEN or CC_RGBINIT
	mov @myColor.lCustData,0
	mov @myColor.lpfnHook,0
	mov @myColor.lpTemplateName,0
	invoke ChooseColor,addr @myColor
	mov eax,@myColor.rgbResult
	mov fgColor,eax
	ret
_MySelectColor endp

_ComparePos proc uses eax ebx,hPoint:POINT
	mov eax,hPoint.x
	mov ebx,1
	CMP eax,ebx
	JL L1
	mov eax,hPoint.y
	mov ebx,1
	CMP eax,ebx
	JL L1
	mov eax,800
	mov ebx,hPoint.x
	CMP eax,ebx
	JL L1
	mov eax,600
	mov ebx,hPoint.y
	CMP eax,ebx
	JL L1
L2:
	ret
L1:
	mov MouseClick,FALSE
	ret
_ComparePos endp

_CreateBuffer proc uses eax ecx,hWnd
	LOCAL @hDc:HDC
	LOCAL @hBitMap:HBITMAP
	LOCAL @hPen:HPEN
	invoke GetDC,hWnd
	mov @hDc,eax
	invoke CreateCompatibleDC,@hDc
	mov buffer,eax
	invoke CreateCompatibleBitmap,@hDc,WndWidth,WndHeight
	mov @hBitMap,eax
	invoke SelectObject,buffer,@hBitMap
	invoke GetStockObject,NULL_PEN
	mov @hPen,eax
	invoke SelectObject,buffer,@hPen
	invoke Rectangle,buffer,0,0,WndWidth,WndHeight
	invoke ReleaseDC,hWnd,@hDc
	ret
_CreateBuffer endp

_CreateMenu proc uses eax,hIns:HINSTANCE
	invoke LoadMenu,hIns,IDR_MENU1
	mov hMenu,eax
	mov hAccelerator,eax
	ret
_CreateMenu endp

_CreateColorBox proc uses eax ebx esi edi, hInst:HINSTANCE, hWnd:HWND ,isDock: DWORD
	LOCAL @rt:RECT 
	LOCAL @pt1:POINT
	LOCAL @pt2:POINT
	LOCAL @hWndColorBox:HWND
	LOCAL @rtWidth:DWORD
	LOCAL @rtHeight:DWORD
	mov eax,isDock
	.if eax
		invoke SetRect,addr @rt,0,0,480,80
		invoke AdjustWindowRect,addr @rt,WS_CHILD or WS_VISIBLE or WS_BORDER,0
		
		mov esi,@rt.right
		mov edi,@rt.left
		sub esi,edi
		mov @rtWidth,esi

		mov esi,@rt.bottom
		mov edi,@rt.top
		sub esi,edi
		mov @rtHeight,esi

		invoke CreateWindowEx,NULL,offset szColorBoxClass,0,WS_CHILD or WS_VISIBLE or WS_BORDER,@rt.left,@rt.top,
			@rtWidth,@rtHeight,hWnd,0,hInst,hWnd
		mov @hWndColorBox,eax
	.else
		mov @pt1.x,200
		mov @pt1.y,0
		mov @pt2.x,680
		mov @pt2.y,80
		invoke ClientToScreen,hWnd,addr @pt1
		invoke ClientToScreen, hWnd,addr @pt2

		invoke SetRect,addr @rt,@pt1.x,@pt1.y,@pt2.x,@pt2.y
		
		invoke AdjustWindowRect,addr @rt,WS_POPUP or WS_CAPTION or WS_VISIBLE or WS_BORDER,0
		
		mov esi,@rt.right
		mov edi,@rt.left
		sub esi,edi
		mov @rtWidth,esi

		mov esi,@rt.bottom
		mov edi,@rt.top
		sub esi,edi
		mov @rtHeight,esi

		invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szColorBoxClass,0,WS_POPUP or WS_CAPTION or WS_VISIBLE or WS_BORDER,@rt.left,@rt.top,
			@rtWidth,@rtHeight,hWnd,0,hInst,hWnd
		mov @hWndColorBox,eax
	.endif
	mov eax,@hWndColorBox
	ret
_CreateColorBox endp

;窗口过程
_ProcWinMain proc uses ebx edi esi,hWnd,uMsg,wParam,lParam
	LOCAL @stPs:PAINTSTRUCT
	LOCAL @hDc:HDC
	LOCAL @hPen:HPEN
	LOCAL @myhDc:HDC
	LOCAL @temphDc:HDC
	LOCAL @tempBit:HBITMAP
	LOCAL @hMenu: HMENU
	LOCAL @color: COLORREF

	invoke GetMenu, hWnd
	mov @hMenu, eax
		
	mov eax,uMsg
	.if eax == WM_CLOSE
		invoke PostQuitMessage,NULL

	.elseif eax == WM_CREATE
		invoke _CreateBuffer,hWnd
		invoke _CreateColorBox,hInstance,hWnd,0

	.elseif eax == WM_PAINT
		mov ebx,hWnd
		.if ebx == hWinMain
			invoke BeginPaint,hWnd,addr @stPs
			mov @hDc,eax
			invoke BitBlt,@hDc,0,0,WndWidth,WndHeight,buffer,0,0,SRCCOPY
			invoke EndPaint,hWnd,addr @stPs
		.endif

	.elseif eax == WM_LBUTTONDOWN
		mov eax,lParam
		and eax,0FFFFh
		mov hitpoint.x,eax
		mov eax,lParam
		shr eax,16
		mov hitpoint.y,eax
		mov MouseClick,TRUE

	.elseif eax == WM_MOUSEMOVE
		mov eax,lParam
		and eax,0FFFFh
		mov movpoint.x,eax
		mov eax,lParam
		shr eax,16
		mov movpoint.y,eax
		invoke _ComparePos,movpoint
		.if MouseClick == TRUE
			invoke GetDC,hWnd
			mov @myhDc,eax
			invoke CreateCompatibleDC,@myhDc
			mov @temphDc,eax
			invoke CreateCompatibleBitmap,@myhDc,WndWidth,WndHeight
			mov @tempBit,eax
			invoke SelectObject,@temphDc,@tempBit
			invoke BitBlt,@temphDc,0,0,WndWidth,WndHeight,buffer,0,0,SRCCOPY
			invoke CreatePen,PS_SOLID,1,fgColor
			mov @hPen,eax
			invoke SelectObject,@temphDc,@hPen
			invoke MoveToEx,@temphDc,hitpoint.x,hitpoint.y,NULL
			invoke LineTo,@temphDc,movpoint.x,movpoint.y
								
			push movpoint.x
			push movpoint.y
			pop hitpoint.y
			pop hitpoint.x
			invoke BitBlt,buffer,0,0,WndWidth,WndHeight,@temphDc,0,0,SRCCOPY
				
			invoke DeleteObject,@hPen
			invoke DeleteObject,@tempBit
			invoke DeleteDC,@temphDc
			invoke ReleaseDC,hWnd,@myhDc

			invoke InvalidateRect,hWnd,0,FALSE
			invoke UpdateWindow,hWnd
		.endif

	.elseif eax == WM_LBUTTONUP
		.if MouseClick == TRUE			
			mov MouseClick,FALSE
		.endif

	.elseif eax == WM_COMMAND
		mov eax,wParam
		.if ax == ID_FILE_SAVE
			invoke _MySaveFile,hWnd
		.elseif ax == ID_FILE_OPENFILE
			invoke _MyOpenFile,hWnd
		.endif

	.elseif eax == WM_CHANGE_COLOR
		mov eax, lParam
		mov fgColor, eax
		invoke DeleteObject, @hPen

		invoke CreatePen,PS_SOLID,1,fgColor
		mov @hPen,eax

	.else 
 		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.endif

	xor eax,eax
	ret
_ProcWinMain endp 

_WndColorBtnProc proc uses ebx edi esi,hWnd,message,wParam,lParam
	LOCAL @ps:PAINTSTRUCT
	LOCAL @hdc:HDC 
	LOCAL @color:COLORREF
	LOCAL @hbr:HBRUSH 
	LOCAL @hOldBr:HBRUSH
	LOCAL @rt:RECT
	mov eax,message
	.if eax == WM_CREATE
		mov ecx,lParam
        mov eax,[ecx].CREATESTRUCTA.lpCreateParams
		mov @color,eax
		;这句不好翻译
		;color = (COLORREF)((LPCREATESTRUCT)lParam)->lpCreateParams;
		invoke SetWindowLong,hWnd,0,@color
	.elseif eax == WM_PAINT
		invoke BeginPaint,hWnd,addr @ps
		mov @hdc,eax
		invoke GetClientRect,hWnd,addr @rt
		invoke GetWindowLong,hWnd,0
		mov @color,eax
		;color = (COLORREF)GetWindowLong(hWnd, 0);
		invoke CreateSolidBrush,@color
		mov @hbr,eax;
		invoke SelectObject,@hdc,@hbr
		mov @hOldBr,eax
		invoke Rectangle,@hdc,0,0,@rt.right,@rt.bottom
		; TODO: 在此添加任意绘图代码...
		invoke SelectObject,@hdc,@hOldBr
		invoke DeleteObject,@hbr
		invoke EndPaint,hWnd,addr @ps
	.elseif eax == WM_LBUTTONDOWN
		invoke GetWindowLong,hWnd,0
		mov @color,eax
		invoke GetParent,hWnd
		mov ebx,eax
		invoke SendMessage,ebx,WM_CHANGE_COLOR,0,@color
	.elseif eax == WM_DESTROY
		nop
	.else
		invoke DefWindowProc,hWnd,message,wParam,lParam
		ret
	.endif
	mov eax,0
	ret
_WndColorBtnProc  endp

_WndColorBoxProc proc  uses ebx edi esi,hWnd,message,wParam,lParam
	LOCAL @ps:PAINTSTRUCT
	LOCAL @hdc:HDC
	LOCAL @i:DWORD
	LOCAL @hWndColor:HWND
	LOCAL @hInsthWnd:HINSTANCE
	LOCAL @width:DWORD
	;PAINTSTRUCT ps;
	;HDC hdc;
	;int i;
	;HWND hWndColor;
	mov eax,message
	.if eax == WM_CREATE
		mov ecx,lParam
        mov eax,[ecx].CREATESTRUCTA.lpCreateParams
		mov hWndSendTo,eax
		;hWndSendTo = (HWND)(((LPCREATESTRUCT)(lParam))
			;->lpCreateParams);
		invoke GetWindowLong,hWnd,GWL_HINSTANCE
		mov @hInsthWnd,eax
		;hInsthWnd = (HINSTANCE)GetWindowLong(hWnd, GWL_HINSTANCE);
		mov ecx,szColor
		mov esi,0
		mov edi,ecx
		shr edi,1
		mov @width,edi
	@@:
		.if esi < @width
			pushad
			mov eax,esi
			shr eax,2
			mov ebx,buttonWidth
			mul ebx
			invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szColorBtnClass,0,WS_CHILD,eax,0,buttonWidth,buttonWidth,hWnd,0,@hInsthWnd,aColor[esi]
			mov @hWndColor,eax
			invoke ShowWindow,@hWndColor,SW_NORMAL
			popad
		.else
			pushad
			mov eax,esi
			sub eax,edi
			shr eax,2
			mov ebx,buttonWidth
			mul ebx; 40 * Buttonsize
			invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szColorBtnClass,0,WS_CHILD,eax,buttonWidth,buttonWidth,buttonWidth,hWnd,0,@hInsthWnd,aColor[esi]
			mov @hWndColor,eax
			invoke ShowWindow,@hWndColor,SW_NORMAL
			popad
		.endif
		add esi,4
		sub ecx,4
		cmp ecx,0
		jne @B
	.elseif eax == WM_PAINT
		invoke BeginPaint,hWnd,addr @ps
		mov @hdc, eax
		invoke EndPaint,hWnd,addr @ps
	.elseif eax == WM_CHANGE_COLOR
		invoke SendMessage,hWndSendTo,message,wParam,lParam
	.elseif eax == WM_DESTROY
		nop
	.else
		invoke DefWindowProc,hWnd,message,wParam,lParam
		ret
	.endif
	mov eax,0
	ret
_WndColorBoxProc endp

_RegisterColorClass proc @hInstance
	LOCAL  @wcex:WNDCLASSEX

	mov @wcex.cbSize,sizeof WNDCLASSEX

	mov @wcex.style,CS_HREDRAW or CS_VREDRAW
	mov @wcex.cbClsExtra,0
	mov @wcex.cbWndExtra,0
	mov eax,@hInstance
	mov @wcex.hInstance,eax
	mov @wcex.hIcon,NULL
	invoke LoadCursor,NULL, IDC_ARROW
	mov @wcex.hCursor,eax
	mov @wcex.hbrBackground,COLOR_WINDOW + 1
	mov @wcex.lpszMenuName, NULL;
	mov @wcex.hIconSm,NULL;
	mov @wcex.lpszClassName,offset szColorBtnClass
	mov @wcex.lpszMenuName,NULL;
	mov @wcex.lpfnWndProc,offset _WndColorBtnProc;TODO
	mov @wcex.cbWndExtra,4;
	invoke RegisterClassEx,addr @wcex; 据说由bug
	.if !eax
		mov eax,0
		ret
	.endif
	mov @wcex.lpszClassName,offset szColorBoxClass
	mov @wcex.lpszMenuName,NULL
	mov @wcex.lpfnWndProc,offset _WndColorBoxProc;TODO
	mov @wcex.cbWndExtra,0;
	invoke RegisterClassEx,addr @wcex; 据说由bug
	.if !eax
		mov eax,0
		ret
	.endif
	mov eax,1
ret
_RegisterColorClass endp

_WinMain proc
	LOCAL @stWndClass:WNDCLASSEX
	LOCAL @stMsg:MSG
	;If the function succeeds, the return value is a handle to the specified module.
	invoke GetModuleHandle,NULL
	mov hInstance,eax
	invoke RtlZeroMemory,addr @stWndClass,sizeof @stWndClass ;Fills a block of memory with zeros.

	; 函数: MyRegisterClass()
	;
	; 目标: 注册窗口类。
	;
	invoke LoadCursor,0,IDC_ARROW
	mov @stWndClass.hCursor,eax
	push hInstance
	pop @stWndClass.hInstance
	mov @stWndClass.cbSize,sizeof WNDCLASSEX
	mov @stWndClass.style,CS_HREDRAW or CS_VREDRAW
	mov @stWndClass.lpfnWndProc,offset  _ProcWinMain
	mov @stWndClass.hbrBackground,COLOR_WINDOW+1
	;COLOR_BACKGROUND COLOR_HIGHLIGHT COLOR_MENU COLOR_WINDOW..预置
	mov @stWndClass.lpszClassName,offset szClassName
	mov @stWndClass.lpszMenuName,IDR_MENU1
	invoke RegisterClassEx,addr @stWndClass
	invoke _RegisterColorClass, hInstance

	;//   函数:  InitInstance(HINSTANCE, int)
	;  目的:  保存实例句柄并创建主窗口
	;  在此函数中，我们在全局变量中保存实例句柄并
	;  创建和显示主程序窗口。

	;WS_EX_CLIENTEDGE预置的一种样式
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szClassName,offset szCaptionMain,WS_OVERLAPPEDWINDOW and not WS_MAXIMIZEBOX and not WS_THICKFRAME,0,0,WndWidth,WndHeight,NULL,NULL,hInstance,NULL
	mov hWinMain,eax
	;invoke _CreateToolbar,hWinMain,hInstance
	;invoke LoadAccelerators,hInstance,IDR_ACCELERATOR
	;mov hAccelerator,eax
	invoke ShowWindow,hWinMain,SW_SHOWNORMAL;SW_SHOWNORMAL sets the window state to restored and makes the window visible. SW_HIDE
	invoke UpdateWindow,hWinMain



	;invoke LoadAccelerators,hInstance,IDA_MENU;IDA_MENU在rc中定义,为快捷键
	mov hAccelerator,eax
		
	;消息循环
	.while TRUE
		invoke GetMessage,addr @stMsg,NULL,0,0
		.break .if eax == 0
		invoke TranslateAccelerator,hWinMain,hAccelerator,addr @stMsg
		.if eax == 0
			invoke TranslateMessage,addr @stMsg
			invoke DispatchMessage,addr @stMsg
		.endif
	.endw

	ret
_WinMain endp

start:
	call _WinMain
	invoke ExitProcess,NULL
end start
