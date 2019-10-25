;匈牙利命名法
;	b,w,dw	表示变量是byte,word,dword
;	h		表示句柄
;	lp		表示指针
;	sz		表示字符串
;	lpsz	表示字符串指针
;	f		表示浮点数
;	st		表示一个数据结构
;	变量类型+变量名,开头小写,后面大写
;命名规范!
;	宏变量用大写+下划线
;	全局变量用匈牙利命名法
;	参数用_开头
;	局部变量用@开头
;	自定义函数开头必须加下划线!
;	指令和寄存器用小写
;代码规范
;	局部变量地址使用addr/lea,全局变量地址使用offset
;	全局变量定义在.inc中
;	引用库函数定义在.inc中
;	使用equ而不是=
;	使用db,dw,dd而不是byte,word,dword
;	跳转使用@@ 和 @B(前面第一个@@) 和@F(后面第一个@@)
;	子函数请使用proc,uses,local等伪指令
;缩进规范
;	一般变量和标号定义前无缩进
;	一整块的指令要用tab对齐
;	分支或循环再缩进一格
;避免事项
;	避免使用宏
.386
.model flat,stdcall
option casemap:none

include main.inc
.code
include ColorBox.asm
include	FileStream.asm
_MySaveFile proc uses edx ebx _hWnd:HWND
local @hdc:HDC
local @hdcBmp:HDC
local @hBmpBuffer:HBITMAP
local @bmfHeader:BITMAPFILEHEADER   
local @BitFore:BITMAPINFOHEADER   
local @bmpScreen:BITMAP
local @DWSize:dword
local @hDIB:HANDLE
local @lpbitmap:ptr byte
local @hFile:HANDLE  
local @DIBSize:dword
local @WrittenBytes:dword
local @len:dword

	invoke _GetSaveFileName, offset szFileNameBuffer 
	.if  (!eax)
		ret
	.endif

	invoke _CheckBmpSuffix, offset szFileNameBuffer
	.if eax
	.else
		ret
		;add	ebx, 4
		;invoke	crt_strcpy, ebx, offset szOtherBmp
	.endif


	invoke	GetDC,_hWnd;函数功能：该函数检索一指定窗口的客户区域或整个屏幕的显示设备上下文环境的句柄，以后可以在GDI函数中使用该句柄来在设备上下文环境中绘图。
	mov		@hdc,eax
	invoke	CreateCompatibleDC,@hdc;该函数创建一个与指定设备兼容的内存设备上下文环境（DC）
	mov		@hdcBmp,eax
	invoke	SetStretchBltMode,@hdc,HALFTONE;Windows GDI函数，功能为该函数可以设置指定设备环境中的位图拉伸模式。
	invoke	CreateCompatibleBitmap,@hdc,WINDOW_WIDTH,WINDOW_HEIGHT;该函数用于创建与指定的设备环境相关的设备兼容的位图。
	mov		@hBmpBuffer,eax
	invoke	SelectObject,@hdcBmp,@hBmpBuffer;The SelectObject function selects an object into the specified device context (DC). The new object replaces the previous object of the same type.
	invoke	BitBlt,@hdcBmp,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,dBuffer,0,0,SRCCOPY;The BitBlt function performs a bit-block transfer of the color data corresponding to a rectangle of pixels from the specified source device context into a destination device context.
	invoke	GetObject,@hBmpBuffer,sizeof BITMAP,addr @bmpScreen;The GetObject function retrieves information for the specified graphics object.
	push	sizeof BITMAPINFOHEADER
	pop		@BitFore.biSize;参见这里https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapinfoheader
	push	@bmpScreen.bmWidth
	pop		@BitFore.biWidth
	push	@bmpScreen.bmHeight
	pop		@BitFore.biHeight
	mov		@BitFore.biPlanes,1
	mov		@BitFore.biBitCount,32
	mov		@BitFore.biCompression,BI_RGB
	mov		@BitFore.biSizeImage,0
	mov		@BitFore.biXPelsPerMeter,0
	mov		@BitFore.biYPelsPerMeter,0
	mov		@BitFore.biClrUsed,0
	mov		@BitFore.biClrImportant,0

	movzx	eax,@BitFore.biBitCount;movzx零填充
	mul		@bmpScreen.bmWidth
	add		eax,31
	mov		ebx,32
	cdq								;这个指令把 EAX 的第 31 bit 复制到 EDX 的每一个 bit 上。 它大多出现在除法运算之前。它实际的作用只是把EDX的所有位都设成EAX最高位的值
	div		ebx
	mov		edx,4
	mul		edx
	mul		@bmpScreen.bmHeight
	mov		@DWSize,eax
	invoke	GlobalAlloc,GHND,@DWSize
	mov		@hDIB,eax
	invoke	GlobalLock,@hDIB;Locks a global memory object and returns a pointer to the first byte of the object's memory block.
	mov		@lpbitmap,eax

	invoke	GetDIBits,@hdc,@hBmpBuffer,0,@bmpScreen.bmHeight,@lpbitmap,addr @BitFore,DIB_RGB_COLORS;The GetDIBits function retrieves the bits of the specified compatible bitmap and copies them into a buffer as a DIB using the specified format.
	invoke	CreateFile,addr szFileNameBuffer,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL;This function creates, opens, or truncates a file, COM port, device, service, or console. It returns a handle that you can use to access the object.
	mov		@hFile,eax
	mov		eax,@DWSize 
	add		eax,sizeof BITMAPFILEHEADER
	add		eax,sizeof BITMAPINFOHEADER
	mov		@DIBSize,eax

	mov		eax,sizeof BITMAPFILEHEADER
	add		eax,sizeof BITMAPINFOHEADER
	mov		@bmfHeader.bfOffBits,eax
	push	@DIBSize
	pop		@bmfHeader.bfSize
	mov		@bmfHeader.bfType,4D42h;' file type always 4D42h or "BM"
								;https://rerickso.w3.uvm.edu/projects/vb_bmp/BMP.html 利用c写的

	invoke	WriteFile,@hFile,addr @bmfHeader,sizeof BITMAPFILEHEADER,addr @WrittenBytes,NULL
	invoke	WriteFile,@hFile,addr @BitFore,sizeof BITMAPINFOHEADER,addr @WrittenBytes,NULL
	invoke	WriteFile,@hFile,@lpbitmap,@DWSize,addr @WrittenBytes,NULL

	invoke	GlobalUnlock,@hDIB;Decrements the lock count associated with a memory object that was allocated with GMEM_MOVEABLE. This function has no effect on memory objects allocated with GMEM_FIXED.
	invoke	GlobalFree,@hDIB;Frees the specified global memory object and invalidates its handle.
	invoke	CloseHandle,@hFile

	invoke	DeleteDC,@hdcBmp
	invoke	DeleteObject,@hBmpBuffer
	invoke	ReleaseDC,_hWnd,@hdc
	ret
_MySaveFile endp

_MyOpenFile proc _hWnd:HWND
local @hdc:HDC
local @hdcBmp:HDC
local @hBmp:HBITMAP
local @tempDC:HDC
local @tempBmp:HBITMAP

	invoke _GetOpenFileName
	.if (!eax)
		ret
	.endif
	; 成功打开，初始化环境，load 进来
	invoke	GetDC,_hWnd
	mov		@hdc,eax
	invoke	CreateCompatibleDC,@hdc
	mov		@tempDC,eax
	invoke	CreateCompatibleDC,@hdc
	mov		@hdcBmp,eax
	invoke	CreateCompatibleBitmap,@hdc,WINDOW_WIDTH,WINDOW_HEIGHT
	mov		@tempBmp,eax
	invoke	SelectObject,@tempDC,@tempBmp
	invoke	BitBlt,@tempDC,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,dBuffer,0,0,SRCCOPY

	invoke	LoadImage,hInstance,addr szFileNameBuffer,IMAGE_BITMAP,0,0,LR_LOADFROMFILE 
	.if (!eax)
		ret
	.endif

	
	mov		@hBmp,HBITMAP ptr eax
	invoke	SelectObject,@hdcBmp,@hBmp
	invoke	BitBlt,@tempDC,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,@hdcBmp,0,0,SRCCOPY
	invoke	BitBlt,dBuffer,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,@tempDC,0,0,SRCCOPY
    
	invoke	DeleteDC,@hdcBmp
	invoke	DeleteDC,@tempDC
	invoke	DeleteObject,@tempBmp
	invoke	ReleaseDC,_hWnd,@hdc

	invoke	InvalidateRect,_hWnd,0,FALSE
	invoke	UpdateWindow,_hWnd
	ret
_MyOpenFile endp

_MySelectColor proc _hWnd:HWND
local @myColor:CHOOSECOLOR

	mov		@myColor.lStructSize,sizeof @myColor
	mov		eax,_hWnd
	mov		@myColor.hwndOwner,eax
	mov		eax,hInstance
	mov		@myColor.hInstance,eax
	mov		@myColor.rgbResult,0
	mov		eax,offset dwArrCustomColor
	mov		@myColor.lpCustColors,eax
	mov		@myColor.Flags,CC_FULLOPEN or CC_RGBINIT
	mov		@myColor.lCustData,0
	mov		@myColor.lpfnHook,0
	mov		@myColor.lpTemplateName,0
	invoke	ChooseColor,addr @myColor
	mov		eax,@myColor.rgbResult
	mov		dwCurColor,eax
	ret
_MySelectColor endp

_ComparePos proc uses eax ebx,hPoint:POINT
	mov		eax,hPoint.x
	mov		ebx,1
	CMP		eax,ebx
	JL	L1
	mov		eax,hPoint.y
	mov		ebx,1
	CMP		eax,ebx
	JL	L1
	mov		eax,800
	mov		ebx,hPoint.x
	CMP		eax,ebx
	JL	L1
	mov		eax,600
	mov		ebx,hPoint.y
	CMP		eax,ebx
	JL	L1
L2:
	ret
L1:
	mov bMouseClick,FALSE
	ret
_ComparePos endp

_CreateBuffer proc uses eax ecx,_hWnd
local	@hDc:HDC
local	@hBitMap:HBITMAP
local	@hPen:HPEN
	invoke	GetDC,_hWnd
	mov		@hDc,eax
	invoke	CreateCompatibleDC,@hDc
	mov		dBuffer,eax
	invoke	CreateCompatibleBitmap,@hDc,WINDOW_WIDTH,WINDOW_HEIGHT
	mov		@hBitMap,eax
	invoke	SelectObject,dBuffer,@hBitMap
	invoke	GetStockObject,NULL_PEN
	mov		@hPen,eax
	invoke	SelectObject,dBuffer,@hPen
	invoke	Rectangle,dBuffer,0,0,WINDOW_WIDTH,WINDOW_HEIGHT
	invoke	ReleaseDC,_hWnd,@hDc
	ret
_CreateBuffer endp

_CreateMenu proc uses eax,_hIns:HINSTANCE
	invoke	LoadMenu,_hIns,IDR_MENU1
	mov		hMenu,eax
	mov		hAccelerator,eax
	ret
_CreateMenu endp

;窗口过程
_ProcWinMain proc uses ebx edi esi,_hWnd,_stMsg,_wParam,_lParam
local	@stPs:PAINTSTRUCT
local	@hDc:HDC
local	@hPen:HPEN
local	@myhDc:HDC
local	@temphDc:HDC
local	@tempBit:HBITMAP
local	@hMenu: HMENU
local	@color: COLORREF

	invoke	GetMenu, _hWnd
	mov		@hMenu, eax
		
	mov		eax,_stMsg
	.if	eax == WM_CLOSE
		invoke	PostQuitMessage,NULL

	.elseif eax == WM_CREATE
		invoke	_CreateBuffer,_hWnd
		invoke	_CreateColorBox,hInstance,_hWnd,0

	.elseif eax == WM_PAINT
		mov	ebx,_hWnd
		.if ebx == hWinMain
			invoke	BeginPaint,_hWnd,addr @stPs
			mov		@hDc,eax
			invoke	BitBlt,@hDc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,dBuffer,0,0,SRCCOPY
			invoke	EndPaint,_hWnd,addr @stPs
		.endif

	.elseif eax == WM_LBUTTONDOWN
		mov eax,_lParam
		and eax,0FFFFh
		mov stHitPoint.x,eax
		mov eax,_lParam
		shr eax,16
		mov stHitPoint.y,eax
		mov bMouseClick,TRUE

	.elseif eax == WM_MOUSEMOVE
		mov eax,_lParam
		and eax,0FFFFh
		mov stMovPoint.x,eax
		mov eax,_lParam
		shr eax,16
		mov stMovPoint.y,eax
		invoke _ComparePos,stMovPoint
		.if bMouseClick == TRUE
			invoke	GetDC,_hWnd
			mov		@myhDc,eax
			invoke	CreateCompatibleDC,@myhDc
			mov		@temphDc,eax
			invoke	CreateCompatibleBitmap,@myhDc,WINDOW_WIDTH,WINDOW_HEIGHT
			mov		@tempBit,eax
			invoke	SelectObject,@temphDc,@tempBit
			invoke	BitBlt,@temphDc,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,dBuffer,0,0,SRCCOPY
			invoke	CreatePen,PS_SOLID,1,dwCurColor
			mov		@hPen,eax
			invoke	SelectObject,@temphDc,@hPen
			invoke	MoveToEx,@temphDc,stHitPoint.x,stHitPoint.y,NULL
			invoke	LineTo,@temphDc,stMovPoint.x,stMovPoint.y
								
			push	stMovPoint.x
			push	stMovPoint.y
			pop		stHitPoint.y
			pop		stHitPoint.x
			invoke	BitBlt,dBuffer,0,0,WINDOW_WIDTH,WINDOW_HEIGHT,@temphDc,0,0,SRCCOPY
				
			invoke	DeleteObject,@hPen
			invoke	DeleteObject,@tempBit
			invoke	DeleteDC,@temphDc
			invoke	ReleaseDC,_hWnd,@myhDc

			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.endif

	.elseif eax == WM_LBUTTONUP
		.if bMouseClick == TRUE			
			mov bMouseClick,FALSE
		.endif

	.elseif eax == WM_COMMAND
		mov eax,_wParam
		.if ax == ID_FILE_SAVE
			invoke _MySaveFile,_hWnd
		.elseif ax == ID_FILE_OPENFILE
			invoke _MyOpenFile,_hWnd
		.endif

	.elseif eax == WM_CHANGE_COLOR
		mov		eax,_lParam
		mov		dwCurColor, eax
		invoke	DeleteObject, @hPen

		invoke	CreatePen,PS_SOLID,1,dwCurColor
		mov		@hPen,eax

	.else 
 		invoke	DefWindowProc,_hWnd,_stMsg,_wParam,_lParam
		ret
	.endif

	xor eax,eax
	ret
_ProcWinMain endp 


_WinMain proc
local	@stWndClass:WNDCLASSEX
local	@stMsg:MSG
	;If the function succeeds, the return value is a handle to the specified module.
	invoke	GetModuleHandle,NULL
	mov		hInstance,eax
	invoke	RtlZeroMemory,addr @stWndClass,sizeof @stWndClass ;Fills a block of memory with zeros.

	; 函数: MyRegisterClass()
	;
	; 目标: 注册窗口类。
	;
	invoke	LoadCursor,0,IDC_ARROW
	mov		@stWndClass.hCursor,eax
	push	hInstance
	pop		@stWndClass.hInstance
	mov		@stWndClass.cbSize,sizeof WNDCLASSEX
	mov		@stWndClass.style,CS_HREDRAW or CS_VREDRAW
	mov		@stWndClass.lpfnWndProc,offset  _ProcWinMain
	mov		@stWndClass.hbrBackground,COLOR_WINDOW+1
	;COLOR_BACKGROUND COLOR_HIGHLIGHT COLOR_MENU COLOR_WINDOW..预置
	mov		@stWndClass.lpszClassName,offset szClassName
	mov		@stWndClass.lpszMenuName,IDR_MENU1
	invoke	RegisterClassEx,addr @stWndClass
	invoke	_RegisterColorClass, hInstance

	;//   函数:  InitInstance(HINSTANCE, int)
	;  目的:  保存实例句柄并创建主窗口
	;  在此函数中，我们在全局变量中保存实例句柄并
	;  创建和显示主程序窗口。

	;WS_EX_CLIENTEDGE预置的一种样式
	invoke	CreateWindowEx,WS_EX_CLIENTEDGE,
			offset szClassName,offset szCaptionMain,
			WS_OVERLAPPEDWINDOW and not WS_MAXIMIZEBOX and not WS_THICKFRAME,
			0,0,WINDOW_WIDTH,WINDOW_HEIGHT,
			NULL,NULL,hInstance,NULL
	mov		hWinMain,eax
	;invoke _CreateToolbar,hWinMain,hInstance
	;invoke LoadAccelerators,hInstance,IDR_ACCELERATOR
	;mov hAccelerator,eax
	invoke	ShowWindow,hWinMain,SW_SHOWNORMAL;SW_SHOWNORMAL sets the window state to restored and makes the window visible. SW_HIDE
	invoke	UpdateWindow,hWinMain



	;invoke LoadAccelerators,hInstance,IDA_MENU;IDA_MENU在rc中定义,为快捷键
	mov		hAccelerator,eax
		
	;消息循环
	.while TRUE
		invoke GetMessage,addr @stMsg,NULL,0,0
		.break .if eax == 0
		invoke TranslateAccelerator,hWinMain,hAccelerator,addr @stMsg
		.if eax == 0
			invoke	TranslateMessage,addr @stMsg
			invoke	DispatchMessage,addr @stMsg
		.endif
	.endw

	ret
_WinMain endp

start:
	call _WinMain
	invoke ExitProcess,NULL
end start
