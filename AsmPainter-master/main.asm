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
local @hTmpDC: HDC
local @hTmpBmp:HBITMAP

	invoke _GetOpenFileName, offset szFileNameBuffer
	.if (!eax)
		ret
	.endif

	invoke GetDC, _hWnd
	mov @hDC, eax
    invoke CreateCompatibleDC,@hDC
    mov @hTmpDC,eax
    invoke CreateCompatibleBitmap,@hDC,stPaint.dwWidth, stPaint.dwHeight
    mov @hTmpBmp,eax
    invoke SelectObject,@hTmpDC,@hTmpBmp
    invoke BitBlt,@hTmpDC,0,0, stPaint.dwWidth, stPaint.dwHeight,stPaint.hMemDC,0,0,SRCCOPY

	invoke LoadImage, NULL, offset szFileNameBuffer, IMAGE_BITMAP, 0,0,
				LR_LOADFROMFILE or LR_CREATEDIBSECTION
	mov @hTmpBmp, eax
	invoke SelectObject, @hTmpDC, @hTmpBmp
	invoke BitBlt, stPaint.hMemDC, 0, 0, stPaint.dwWidth, stPaint.dwHeight, @hTmpDC, 0, 0, SRCCOPY
	invoke BitBlt, @hDC , 0, 0, stPaint.dwWidth, stPaint.dwHeight, stPaint.hMemDC, 0, 0, SRCCOPY


    invoke DeleteDC,@hTmpDC
    invoke DeleteObject,@hTmpBmp
    invoke ReleaseDC,_hWnd, @hDC
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
	mov		eax,offset dwColors
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
	invoke	InvalidateRect, _hWnd, 0, FALSE
	invoke	UpdateWindow, _hWnd
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
local	@hBrush:HBRUSH
local	@hMenu: HMENU
local	@hBitmap: HBITMAP
local	@stRect: RECT
local	@dwPickColor: dword

	invoke	GetMenu, _hWnd
	mov		@hMenu, eax

	mov		eax,_stMsg
	.if	eax == WM_CLOSE
		invoke	PostQuitMessage,NULL

	.elseif eax == WM_CREATE
		invoke	_CreateBuffer,_hWnd
		invoke	_CreateColorBox,hInstance,_hWnd,0
		mov		hWndColor,	eax
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
		mov stPaint.stHitPoint.x,eax
		mov eax,_lParam
		shr eax,16
		mov stPaint.stHitPoint.y,eax
		.if bpentype == PENTYPE_PICKCOLOR
			invoke GetDC, _hWnd
			mov @hDc, eax
			invoke GetPixel, @hDc,  stPaint.stHitPoint.x, stPaint.stHitPoint.y;get pixel color
			mov dwCurColor, eax
			invoke SendMessage, hWndColor, WM_SELECT_COLOR, 0, eax
		.else
			mov stPaint.bMouseDown,TRUE
			push stPaint.stHitPoint.x
			push stPaint.stHitPoint.y
			pop	stPaint.stLastMovPoint.y
			pop	stPaint.stLastMovPoint.x
		.endif

	.elseif eax == WM_MOUSEMOVE
		mov eax,_lParam
		and eax,0FFFFh
		mov stPaint.stMovPoint.x,eax
		mov eax,_lParam
		shr eax,16
		mov stPaint.stMovPoint.y,eax
		invoke _ComparePos,stPaint.stMovPoint
		.if stPaint.bMouseDown == TRUE
			.if bpentype == PENTYPE_PENCIL
				invoke	SetROP2,stPaint.hMemDC,R2_COPYPEN

				invoke	CreatePen,PS_SOLID,bpenwidth,dwCurColor
				mov		@hPen,eax
				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	LineTo,stPaint.hMemDC,stPaint.stMovPoint.x,stPaint.stMovPoint.y

				push	stPaint.stMovPoint.x
				push	stPaint.stMovPoint.y
				pop		stPaint.stHitPoint.y
				pop		stPaint.stHitPoint.x
				invoke	DeleteObject,@hPen
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.elseif bpentype == PENTYPE_CIRCLE
				invoke	SetROP2,stPaint.hMemDC,R2_NOTXORPEN

				invoke	CreatePen,PS_SOLID,bpenwidth,dwCurColor
				mov		@hPen,eax
				invoke	GetStockObject,NULL_BRUSH
				mov		@hBrush,eax

				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	SelectObject,stPaint.hMemDC,@hBrush
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	Ellipse,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stLastMovPoint.x,stPaint.stLastMovPoint.y
				invoke	Ellipse,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stMovPoint.x,stPaint.stMovPoint.y

				push	stPaint.stMovPoint.x
				push	stPaint.stMovPoint.y
				pop		stPaint.stLastMovPoint.y
				pop		stPaint.stLastMovPoint.x

				invoke	DeleteObject,@hPen
				invoke	DeleteObject,@hBrush
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.elseif bpentype == PENTYPE_RECTANGLE
				invoke	SetROP2,stPaint.hMemDC,R2_NOTXORPEN

				invoke	CreatePen,PS_SOLID,bpenwidth,dwCurColor
				mov		@hPen,eax
				invoke	GetStockObject,NULL_BRUSH
				mov		@hBrush,eax

				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	SelectObject,stPaint.hMemDC,@hBrush
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	Rectangle,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stLastMovPoint.x,stPaint.stLastMovPoint.y
				invoke	Rectangle,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stMovPoint.x,stPaint.stMovPoint.y

				push	stPaint.stMovPoint.x
				push	stPaint.stMovPoint.y
				pop		stPaint.stLastMovPoint.y
				pop		stPaint.stLastMovPoint.x

				invoke	DeleteObject,@hPen
				invoke	DeleteObject,@hBrush
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.elseif bpentype == PENTYPE_LINE
				invoke	SetROP2,stPaint.hMemDC,R2_NOTXORPEN

				invoke	CreatePen,PS_SOLID,bpenwidth,dwCurColor
				mov		@hPen,eax

				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	SelectObject,stPaint.hMemDC,@hBrush
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	LineTo,stPaint.hMemDC,stPaint.stLastMovPoint.x,stPaint.stLastMovPoint.y
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	LineTo,stPaint.hMemDC,stPaint.stMovPoint.x,stPaint.stMovPoint.y

				push	stPaint.stMovPoint.x
				push	stPaint.stMovPoint.y
				pop		stPaint.stLastMovPoint.y
				pop		stPaint.stLastMovPoint.x

				invoke	DeleteObject,@hPen
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.elseif bpentype == PENTYPE_ERASER	
				invoke	SetROP2,stPaint.hMemDC,R2_WHITE

				invoke	CreatePen,PS_SOLID,bpenwidth,dwCurColor
				mov		@hPen,eax
				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	LineTo,stPaint.hMemDC,stPaint.stMovPoint.x,stPaint.stMovPoint.y

				push	stPaint.stMovPoint.x
				push	stPaint.stMovPoint.y
				pop		stPaint.stHitPoint.y
				pop		stPaint.stHitPoint.x
				invoke	DeleteObject,@hPen
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.elseif bpentype == PENTYPE_CIRCLE_FILLED
				invoke	SetROP2,stPaint.hMemDC,R2_NOTXORPEN

				invoke	CreatePen,PS_SOLID,bpenwidth,dwCurColor
				mov		@hPen,eax
				invoke	CreateSolidBrush,dwCurColor
				mov		@hBrush,eax

				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	SelectObject,stPaint.hMemDC,@hBrush
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	Ellipse,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stLastMovPoint.x,stPaint.stLastMovPoint.y
				invoke	Ellipse,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stMovPoint.x,stPaint.stMovPoint.y

				push	stPaint.stMovPoint.x
				push	stPaint.stMovPoint.y
				pop		stPaint.stLastMovPoint.y
				pop		stPaint.stLastMovPoint.x

				invoke	DeleteObject,@hPen
				invoke	DeleteObject,@hBrush
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.elseif bpentype == PENTYPE_RECTANGLE_FILLED
				invoke	SetROP2,stPaint.hMemDC,R2_NOTXORPEN

				invoke	CreatePen,PS_SOLID,bpenwidth,dwCurColor
				mov		@hPen,eax
				invoke	CreateSolidBrush,dwCurColor
				mov		@hBrush,eax

				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	SelectObject,stPaint.hMemDC,@hBrush
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	Rectangle,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stLastMovPoint.x,stPaint.stLastMovPoint.y
				invoke	Rectangle,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stMovPoint.x,stPaint.stMovPoint.y

				push	stPaint.stMovPoint.x
				push	stPaint.stMovPoint.y
				pop		stPaint.stLastMovPoint.y
				pop		stPaint.stLastMovPoint.x

				invoke	DeleteObject,@hPen
				invoke	DeleteObject,@hBrush
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.elseif bpentype == PENTYPE_DOT	
				invoke	SetROP2,stPaint.hMemDC,R2_NOTXORPEN

				invoke	CreatePen,PS_DOT,bpenwidth,dwCurColor
				mov		@hPen,eax

				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	SelectObject,stPaint.hMemDC,@hBrush
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	LineTo,stPaint.hMemDC,stPaint.stLastMovPoint.x,stPaint.stLastMovPoint.y
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	LineTo,stPaint.hMemDC,stPaint.stMovPoint.x,stPaint.stMovPoint.y

				push	stPaint.stMovPoint.x
				push	stPaint.stMovPoint.y
				pop		stPaint.stLastMovPoint.y
				pop		stPaint.stLastMovPoint.x

				invoke	DeleteObject,@hPen
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.endif
		.endif

	.elseif eax == WM_LBUTTONUP
		.if stPaint.bMouseDown == TRUE
			mov stPaint.bMouseDown,FALSE
			mov eax,_lParam
			and eax,0FFFFh
			mov stPaint.stReleasePoint.x,eax
			mov eax,_lParam
			shr eax,16
			mov stPaint.stReleasePoint.y,eax

			.if bpentype == PENTYPE_CIRCLE;circle
				invoke	SetROP2,stPaint.hMemDC,R2_COPYPEN

				invoke	CreatePen,PS_SOLID,bpenwidth,dwCurColor
				mov		@hPen,eax
				invoke	GetStockObject,NULL_BRUSH
				mov		@hBrush,eax
				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	SelectObject,stPaint.hMemDC,@hBrush
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	Ellipse,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stReleasePoint.x,stPaint.stReleasePoint.y

				invoke	DeleteObject,@hPen
				invoke	DeleteObject,@hBrush
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.elseif bpentype == PENTYPE_RECTANGLE;rectangle
				invoke	SetROP2,stPaint.hMemDC,R2_COPYPEN

				invoke	CreatePen,PS_SOLID,bpenwidth,dwCurColor
				mov		@hPen,eax
				invoke	GetStockObject,NULL_BRUSH
				mov		@hBrush,eax
				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	SelectObject,stPaint.hMemDC,@hBrush
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	Rectangle,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stReleasePoint.x,stPaint.stReleasePoint.y

				invoke	DeleteObject,@hPen
				invoke	DeleteObject,@hBrush
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.elseif bpentype == PENTYPE_LINE;line
				invoke	SetROP2,stPaint.hMemDC,R2_COPYPEN

				invoke	CreatePen,PS_SOLID,bpenwidth,dwCurColor
				mov		@hPen,eax
				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	LineTo,stPaint.hMemDC,stPaint.stReleasePoint.x,stPaint.stReleasePoint.y

				invoke	DeleteObject,@hPen
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.elseif bpentype == PENTYPE_CIRCLE_FILLED;circle
				invoke	SetROP2,stPaint.hMemDC,R2_COPYPEN

				invoke	CreatePen,PS_SOLID,bpenwidth,dwCurColor
				mov		@hPen,eax
				invoke	CreateSolidBrush,dwCurColor
				mov		@hBrush,eax
				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	SelectObject,stPaint.hMemDC,@hBrush
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	Ellipse,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stReleasePoint.x,stPaint.stReleasePoint.y

				invoke	DeleteObject,@hPen
				invoke	DeleteObject,@hBrush
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.elseif bpentype == PENTYPE_RECTANGLE_FILLED;rectangle
				invoke	SetROP2,stPaint.hMemDC,R2_COPYPEN

				invoke	CreatePen,PS_SOLID,bpenwidth,dwCurColor
				mov		@hPen,eax
				invoke	CreateSolidBrush,dwCurColor
				mov		@hBrush,eax
				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	SelectObject,stPaint.hMemDC,@hBrush
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	Rectangle,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stReleasePoint.x,stPaint.stReleasePoint.y

				invoke	DeleteObject,@hPen
				invoke	DeleteObject,@hBrush
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.elseif bpentype == PENTYPE_DOT	;line
				invoke	SetROP2,stPaint.hMemDC,R2_COPYPEN

				invoke	CreatePen,PS_DOT,bpenwidth,dwCurColor
				mov		@hPen,eax
				invoke	SelectObject,stPaint.hMemDC,@hPen
				invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
				invoke	LineTo,stPaint.hMemDC,stPaint.stReleasePoint.x,stPaint.stReleasePoint.y

				invoke	DeleteObject,@hPen
				invoke	InvalidateRect,_hWnd,0,FALSE
				invoke	UpdateWindow,_hWnd
			.endif
		.endif

	.elseif eax == WM_COMMAND
		mov eax,_wParam
		.if ax == ID_FILE_SAVE
			invoke _MySaveFile,_hWnd
		.elseif ax == ID_FILE_OPENFILE
			invoke _MyOpenFile,_hWnd
		.elseif ax == ID_FILE_CLEAR
			invoke	_CreateBuffer,_hWnd
		.elseif ax == ID_SHAPE_PENCIL
			mov bpentype,PENTYPE_PENCIL
		.elseif ax == ID_SHAPE_CIRCLE
			mov bpentype,PENTYPE_CIRCLE
		.elseif ax == ID_SHAPE_RECTANGLE
			mov bpentype,PENTYPE_RECTANGLE
		.elseif ax == ID_SHAPE_LINE
			mov bpentype,PENTYPE_LINE
		.elseif ax == ID_SHAPE_EARSER
			mov bpentype,PENTYPE_ERASER
		.elseif ax == ID_SHAPE_CIRCLE_FILLED
			mov bpentype,PENTYPE_CIRCLE_FILLED
		.elseif ax == ID_SHAPE_RECTANGLE_FILLED
			mov bpentype,PENTYPE_RECTANGLE_FILLED
		.elseif ax == ID_SHAPE_DOT
			mov bpentype,PENTYPE_DOT

		.elseif ax == ID_PEN_WIDTH1
			mov bpenwidth,1
		.elseif ax == ID_PEN_WIDTH2
			mov bpenwidth,2
		.elseif ax == ID_PEN_WIDTH3
			mov bpenwidth,3
		.elseif ax == ID_PEN_WIDTH4
			mov bpenwidth,4
		.elseif ax == ID_PEN_WIDTH5
			mov bpenwidth,5
		.elseif ax == ID_PEN_WIDTH6
			mov bpenwidth,6
		.elseif ax == ID_PEN_WIDTH7
			mov bpenwidth,7
		.elseif ax == ID_PEN_WIDTH8
			mov bpenwidth,8
		.elseif ax == ID_PEN_WIDTH9
			mov bpenwidth,9
		.elseif ax == ID_PEN_WIDTH10
			mov bpenwidth,10
		.elseif ax == ID_COLOR_SELECT
			invoke _MySelectColor, _hWnd
			invoke SendMessage, hWndColor, WM_SELECT_COLOR, 0, dwCurColor
		.elseif ax == ID_COLOR_PICK
			mov bpentype, PENTYPE_PICKCOLOR
		.endif

	.elseif eax == WM_CHANGE_COLOR
		mov		eax,_lParam
		mov		dwCurColor, eax
		invoke	DeleteObject, @hPen

		invoke	CreatePen,PS_SOLID,bpenwidth,dwCurColor
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
