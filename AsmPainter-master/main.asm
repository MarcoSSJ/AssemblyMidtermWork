;匈牙利命名法
;	b,w,dw	表示变量是byte,word,dword
;	h		表示句柄
;	p/lp		表示指针
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
include PaintInfo.inc
include FileStream.inc
.code
include ColorBox.asm
include	FileStream.asm

_MySaveFile proc uses edx ebx _hWnd:HWND
	invoke _GetSaveFileName, offset szFileNameBuffer 
	.if  (!eax)
		ret
	.endif
	;没有必要检查结尾,因为windows会自动补全.bmp
	invoke _SaveBmpToFile, stPaint.hBitmap, _hWnd, offset szFileNameBuffer

	ret
_MySaveFile endp

_MyOpenFile proc _hWnd:HWND
local @hDC:HDC

	invoke _GetOpenFileName, offset szFileNameBuffer
	.if (!eax)
		ret
	.endif
	; 成功打开，初始化环境，load 进来
	invoke GetDC, _hWnd
	mov @hDC, eax

	invoke LoadImage, NULL, offset szFileNameBuffer, IMAGE_BITMAP, 0,0,
				LR_LOADFROMFILE or LR_CREATEDIBSECTION
	mov stPaint.hBitmap, eax
	invoke SelectObject, stPaint.hMemDC, stPaint.hBitmap
	invoke BitBlt, @hDC, 0, 0, stPaint.dwWidth, stPaint.dwHeight, stPaint.hMemDC, 0, 0, SRCCOPY

	invoke	InvalidateRect, _hWnd, 0, FALSE
	invoke	UpdateWindow, _hWnd
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
	mov stPaint.bMouseDown,FALSE
	ret
_ComparePos endp

_CreateBuffer proc uses eax ecx,_hWnd
local	@hDc:HDC
local	@hBitMap:HBITMAP
local	@hPen:HPEN
	invoke	GetDC,_hWnd
	mov		@hDc,eax
	invoke	CreateCompatibleDC,@hDc
	mov		stPaint.hMemDC,eax
	invoke	CreateCompatibleBitmap,@hDc,WINDOW_WIDTH,WINDOW_HEIGHT
	mov		@hBitMap,eax
	invoke	SelectObject,stPaint.hMemDC,@hBitMap
	invoke	GetStockObject,NULL_PEN
	mov		@hPen,eax
	invoke	SelectObject,stPaint.hMemDC,@hPen
	invoke	Rectangle,stPaint.hMemDC,0,0,WINDOW_WIDTH,WINDOW_HEIGHT
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
local	@hMenu: HMENU
local	@hBitmap: HBITMAP
local	@stRect: RECT

	invoke	GetMenu, _hWnd
	mov		@hMenu, eax
		
	mov		eax,_stMsg
	.if	eax == WM_CLOSE
		invoke	PostQuitMessage,NULL

	.elseif eax == WM_CREATE
		invoke	_CreateBuffer,_hWnd
		invoke	_CreateColorBox,hInstance,_hWnd,0
		invoke	GetClientRect, _hWnd, addr @stRect
		
		mov	ebx, @stRect.right
		sub ebx, @stRect.left
		mov stPaint.dwWidth, ebx
		
		mov ebx, @stRect.bottom
		sub ebx, @stRect.top
		mov stPaint.dwHeight, ebx

		invoke GetDC, _hWnd
		mov @hDc, eax

		invoke CreateCompatibleDC, @hDc
		mov stPaint.hMemDC, eax

		invoke CreateCompatibleBitmap, @hDc, stPaint.dwWidth, stPaint.dwHeight
		mov stPaint.hBitmap, eax

		invoke SelectObject, stPaint.hMemDC, stPaint.hBitmap
		invoke GetStockObject, WHITE_BRUSH
		invoke SelectObject, stPaint.hMemDC, eax
		invoke GetStockObject, WHITE_PEN
		invoke SelectObject, stPaint.hMemDC, eax		
		invoke Rectangle, stPaint.hMemDC, 0, 0, stPaint.dwWidth, stPaint.dwHeight;TODO whether bug?
		invoke GetStockObject, WHITE_BRUSH
		invoke SelectObject, stPaint.hMemDC, eax
		invoke GetStockObject, BLACK_PEN
		invoke SelectObject, stPaint.hMemDC, eax

	.elseif eax == WM_PAINT
		mov	ebx,_hWnd
		.if ebx == hWinMain
			invoke	BeginPaint,_hWnd,addr @stPs
			mov		@hDc,eax
			invoke	SelectObject, stPaint.hMemDC, stPaint.hBitmap
			invoke	BitBlt,@hDc,0,0,stPaint.dwWidth, stPaint.dwHeight ,stPaint.hMemDC ,0,0,SRCCOPY
			invoke	EndPaint,_hWnd,addr @stPs
		.endif

	.elseif eax == WM_LBUTTONDOWN
		mov eax,_lParam
		and eax,0FFFFh
		mov stPaint.stPtStart.x,eax
		mov eax,_lParam
		shr eax,16
		mov stPaint.stPtStart.y,eax
		mov stPaint.bMouseDown,TRUE
		
		

	.elseif eax == WM_MOUSEMOVE
		mov eax,_lParam
		and eax,0FFFFh
		mov stPaint.stPtEnd.x,eax
		mov eax,_lParam
		shr eax,16
		mov stPaint.stPtEnd.y,eax
		invoke _ComparePos,stPaint.stPtEnd
		.if stPaint.bMouseDown == TRUE
			invoke	CreatePen,PS_SOLID,1,dwCurColor
			mov		@hPen,eax
			invoke	SelectObject,stPaint.hMemDC,@hPen
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stPtStart.x,stPaint.stPtStart.y,NULL
			invoke	LineTo,stPaint.hMemDC,stPaint.stPtEnd.x,stPaint.stPtEnd.y
								
			push	stPaint.stPtEnd.x
			push	stPaint.stPtEnd.y
			pop		stPaint.stPtStart.y
			pop		stPaint.stPtStart.x
			invoke	DeleteObject,@hPen
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.endif

	.elseif eax == WM_LBUTTONUP
		.if stPaint.bMouseDown == TRUE			
			mov stPaint.bMouseDown,FALSE
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
	or eax,eax
	call _WinMain
	invoke ExitProcess,NULL
end start
