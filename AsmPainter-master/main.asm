;������������
;	b,w,dw	��ʾ������byte,word,dword
;	h		��ʾ���
;	p/lp		��ʾָ��
;	sz		��ʾ�ַ���
;	lpsz	��ʾ�ַ���ָ��
;	f		��ʾ������
;	st		��ʾһ�����ݽṹ
;	��������+������,��ͷСд,�����д
;�����淶!
;	������ô�д+�»���
;	ȫ�ֱ�����������������
;	������_��ͷ
;	�ֲ�������@��ͷ
;	�Զ��庯����ͷ������»���!
;	ָ��ͼĴ�����Сд
;����淶
;	�ֲ�������ַʹ��addr/lea,ȫ�ֱ�����ַʹ��offset
;	ȫ�ֱ���������.inc��
;	���ÿ⺯��������.inc��
;	ʹ��equ������=
;	ʹ��db,dw,dd������byte,word,dword
;	��תʹ��@@ �� @B(ǰ���һ��@@) ��@F(�����һ��@@)
;	�Ӻ�����ʹ��proc,uses,local��αָ��
;�����淶
;	һ������ͱ�Ŷ���ǰ������
;	һ�����ָ��Ҫ��tab����
;	��֧��ѭ��������һ��
;��������
;	����ʹ�ú�
.386
.model flat,stdcall
option casemap:none


include main.inc
include PaintInfo.inc
include FileStream.inc
.code
include RegionLogic.asm
include PaintLogic.asm
include ColorBox.asm
include	FileStream.asm

_MySaveFile proc uses edx ebx _hWnd:HWND
	invoke _GetSaveFileName, offset szFileNameBuffer
	.if  (!eax)
		ret
	.endif
	;û�б�Ҫ����β,��Ϊwindows���Զ���ȫ.bmp
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
	mov		stPaint.dwCurColor,eax
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

_CreateBuffer proc uses ecx,_hWnd, _hMemDC
local	@hDc:HDC
local	@hBitMap:HBITMAP
local	@hPen:HPEN
	invoke	GetDC,_hWnd
	mov		@hDc,eax
	invoke	CreateCompatibleDC,@hDc
	mov		_hMemDC,eax
	invoke	CreateCompatibleBitmap,@hDc,WINDOW_WIDTH,WINDOW_HEIGHT
	mov		@hBitMap,eax
	invoke	SelectObject,_hMemDC,@hBitMap
	invoke	GetStockObject,NULL_PEN
	mov		@hPen,eax
	invoke	SelectObject,_hMemDC,@hPen
	invoke	Rectangle,_hMemDC,0,0,WINDOW_WIDTH,WINDOW_HEIGHT
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

;��������Ϊ��ɫ
_BrushWhiteBg proc uses ebx ecx, _lpStPaint: ptr PAINTINFO

	mov ebx, _lpStPaint
	assume ebx: ptr PAINTINFO
	invoke SelectObject, [ebx].hMemDC, [ebx].hBitmap
	invoke GetStockObject, WHITE_BRUSH
	mov ebx, _lpStPaint
	assume ebx: ptr PAINTINFO
	invoke SelectObject, [ebx].hMemDC, eax
	invoke GetStockObject, WHITE_PEN
	mov ebx, _lpStPaint
	assume ebx: ptr PAINTINFO
	invoke SelectObject, [ebx].hMemDC, eax
	mov ebx, _lpStPaint
	assume ebx: ptr PAINTINFO
	invoke Rectangle, [ebx].hMemDC, 0, 0, [ebx].dwWidth, [ebx].dwHeight;TODO whether bug?
	ret
_BrushWhiteBg endp

_FillWithColor proc uses ebx ecx edi esi, _hDC, _dwColor, _dwStartX, _dwStartY, _dwEndX, _dwEndY, _hWnd, _bUpdate
local @hBitmap: HBITMAP
local @hPen:	HPEN
local @hBrush:	HBRUSH
	invoke	CreatePen,PS_SOLID, 0, _dwColor
	mov		@hPen,eax
	invoke	CreateSolidBrush, _dwColor
	mov		@hBrush,eax

	invoke	SelectObject,stPaint.hMemDC,@hPen
	invoke	SelectObject,stPaint.hMemDC,@hBrush
	invoke	MoveToEx,stPaint.hMemDC, _dwStartX , _dwStartY, NULL
	invoke	Rectangle,stPaint.hMemDC, _dwStartX, _dwStartY, _dwEndX, _dwEndY

	invoke	DeleteObject,@hPen
	invoke	DeleteObject,@hBrush
	.if _bUpdate == TRUE
		invoke	InvalidateRect,_hWnd,0,FALSE
		invoke	UpdateWindow,_hWnd
	.endif
	ret
_FillWithColor endp

;���ڹ���
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
		mov	eax,_hWnd
		mov	hWinMain,eax

		invoke	_CreateBuffer,_hWnd, stPaint.hMemDC
		invoke	_CreateBuffer,_hWnd, stRegion.hMemDC
		invoke	_CreateBuffer,_hWnd, hBuffDC

		invoke	_CreateColorBox,hInstance,_hWnd,0
		mov		hWndColor,	eax
		invoke	GetClientRect, _hWnd, addr @stRect

		mov	ebx, @stRect.right
		sub ebx, @stRect.left
		mov stPaint.dwWidth, ebx
		mov stRegion.dwWidth, ebx

		mov ebx, @stRect.bottom
		sub ebx, @stRect.top
		mov stPaint.dwHeight, ebx
		mov stRegion.dwHeight, ebx

		invoke GetDC, _hWnd
		mov @hDc, eax

		invoke CreateCompatibleDC, @hDc
		mov stPaint.hMemDC, eax
		invoke CreateCompatibleDC, @hDc
		mov stRegion.hMemDC, eax
		invoke CreateCompatibleDC, @hDc
		mov hBuffDC, eax
		
		invoke CreateCompatibleBitmap, @hDc, stPaint.dwWidth, stPaint.dwHeight
		mov stPaint.hBitmap, eax

		invoke CreateCompatibleBitmap, @hDc, stRegion.dwWidth, stRegion.dwHeight
		mov stRegion.hBitmap, eax

		invoke CreateCompatibleBitmap, @hDc, stRegion.dwWidth, stRegion.dwHeight
		mov hBuffBitmap, eax

		invoke _BrushWhiteBg, offset stPaint
		invoke _BrushWhiteBg, offset stRegion

		invoke	CreateToolbarEx,hWinMain,\
				WS_VISIBLE or WS_CHILD or TBSTYLE_FLAT or TBSTYLE_TOOLTIPS or CCS_ADJUSTABLE,\
				ID_TOOLBAR,0,HINST_COMMCTRL,IDB_STD_SMALL_COLOR,offset stToolbar,\
				NUM_BUTTONS,0,0,0,0,sizeof TBBUTTON
			mov	hWinToolbar,eax
		invoke	SendMessage,hWinToolbar,TB_AUTOSIZE,0,0
		;invoke	GetClientRect,hWinMain,addr @stRect
		;invoke	GetWindowRect,hWinToolbar,addr @stRect1
	.elseif eax == WM_PAINT
		mov	ebx,_hWnd
		.if ebx == hWinMain
			invoke	BeginPaint,_hWnd,addr @stPs
			mov		@hDc,eax
			invoke	SelectObject, stPaint.hMemDC, stPaint.hBitmap
			invoke	BitBlt,@hDc,0,0,stPaint.dwWidth, stPaint.dwHeight ,stPaint.hMemDC ,0,0,SRCCOPY
			.if bInRegion != 0
				.if bRegionMove == FALSE
					invoke  BitBlt, @hDc, 0, 0, stRegion.dwWidth, stRegion.dwHeight, stRegion.hMemDC, 0, 0, SRCAND					
				.else
					mov eax, stRegMvPtStart.x
					add eax, stRegMvPtDelta.x
					mov ebx, stRegMvPtStart.y
					add ebx, stRegMvPtDelta.y
					invoke BitBlt, @hDc, eax, ebx, dwBuffWidth, dwBuffHeight, hBuffDC, 0, 0, SRCAND
				.endif
			.endif 
			invoke	EndPaint,_hWnd,addr @stPs
		.endif

	.elseif eax == WM_LBUTTONDOWN
		mov eax,_lParam
		and eax,0FFFFh
		mov stPaint.stHitPoint.x, eax
		mov stRegion.stHitPoint.x, eax
		mov eax,_lParam
		shr eax,16
		mov stPaint.stHitPoint.y,eax
		mov stRegion.stHitPoint.y,eax
		.if bInRegion != 0
			.if bRegionMove != TRUE
				invoke _BrushWhiteBg, offset stRegion
				invoke	InvalidateRect, _hWnd, 0, FALSE
				invoke	UpdateWindow, _hWnd
			.endif
			mov stRegion.bMouseDown, TRUE
			push stRegion.stHitPoint.x
			push stRegion.stHitPoint.y
			pop	stRegion.stLastMovPoint.y
			pop	stRegion.stLastMovPoint.x
		.else
			.if bpentype == PENTYPE_PICKCOLOR
				invoke GetDC, _hWnd
				mov @hDc, eax
				invoke GetPixel, @hDc,  stPaint.stHitPoint.x, stPaint.stHitPoint.y;get pixel color
				mov stPaint.dwCurColor, eax
				invoke SendMessage, hWndColor, WM_SELECT_COLOR, 0, eax
			.else
				mov stPaint.bMouseDown,TRUE
				push stPaint.stHitPoint.x
				push stPaint.stHitPoint.y
				pop	stPaint.stLastMovPoint.y
				pop	stPaint.stLastMovPoint.x
			.endif
		.endif

	.elseif eax == WM_MOUSEMOVE
		mov eax,_lParam
		and eax,0FFFFh
		mov stPaint.stMovPoint.x,eax
		mov stRegion.stMovPoint.x, eax
		mov eax,_lParam
		shr eax,16
		mov stPaint.stMovPoint.y,eax
		mov stRegion.stMovPoint.y, eax
		invoke _ComparePos,stPaint.stMovPoint
		.if bInRegion != 0
			.if stRegion.bMouseDown != 0
				invoke _RegionMouseMove, @hPen, @hBrush, _hWnd
				invoke	InvalidateRect, _hWnd, 0, FALSE
				invoke	UpdateWindow, _hWnd
			.endif 
		.else
			invoke _PaintMouseMove, @hPen, @hBrush, _hWnd
		.endif

	.elseif eax == WM_LBUTTONUP
		
		.if bInRegion != 0
			invoke _RegionLButtonUp, @hPen, @hBrush, _hWnd, _lParam
		.else
			invoke _PaintLButtonUp, @hPen, @hBrush, _hWnd, _lParam

		.endif
			

	.elseif eax == WM_COMMAND
		mov eax,_wParam
		;��δʹ��ѡ��,��ȡ��
		.if ax > ID_REGION_FILL || ax < ID_REGION_SET
			mov bInRegion, FALSE
			push eax
			invoke _BrushWhiteBg, offset stRegion
			pop eax
		.endif

		;ʹ��ѡ����δ��ѡ��set,������ʾ
		.if ax >= ID_REGION_SAVE && ax <= ID_REGION_FILL && bInRegion != TRUE
			invoke MessageBox,NULL,offset szErrorNotRegion, NULL,MB_OK
			ret
		.endif

		.if ax == ID_FILE_SAVE
			invoke _MySaveFile,_hWnd
		.elseif ax == ID_FILE_OPENFILE
			invoke _MyOpenFile,_hWnd
		.elseif ax == ID_FILE_CLEAR
			;invoke	_CreateBuffer,_hWnd, stPaint.hMemDC
			invoke _BrushWhiteBg, offset stPaint
			invoke	InvalidateRect, _hWnd, 0, FALSE
			invoke	UpdateWindow, _hWnd
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
			invoke SendMessage, hWndColor, WM_SELECT_COLOR, 0, stPaint.dwCurColor
		.elseif ax == ID_COLOR_PICK
			mov bpentype, PENTYPE_PICKCOLOR
		.elseif ax == ID_REGION_SET
			mov bInRegion, 1
		.elseif ax == ID_REGION_SAVE
				invoke _BrushWhiteBg, offset stRegion
				invoke	InvalidateRect, _hWnd, 0, FALSE
				invoke	UpdateWindow, _hWnd
				mov stRegion.bMouseDown, TRUE
				invoke SendMessage, hWinMain, WM_REGION_SAVEFILE, 0, 0

				mov bInRegion, FALSE

		.elseif ax == ID_REGION_COPY
				mov eax, stRegPtEnd.x
				sub eax, stRegPtBegin.x
				mov dwBuffWidth, eax
				mov ebx, stRegPtEnd.y
				sub ebx, stRegPtBegin.y
				mov dwBuffHeight, ebx
				push	stRegPtBegin.y
				push	stRegPtBegin.x
				pop	stRegMvPtStart.x
				pop	stRegMvPtStart.y
				invoke SelectObject, stPaint.hMemDC, stPaint.hBitmap
				invoke SelectObject, hBuffDC, hBuffBitmap
				invoke BitBlt, hBuffDC, 0, 0, dwBuffWidth, dwBuffHeight, stPaint.hMemDC, stRegPtBegin.x, stRegPtBegin.y, SRCCOPY
				mov bRegionMove, TRUE
		.elseif ax == ID_REGION_MOVE
				mov eax, stRegPtEnd.x
				sub eax, stRegPtBegin.x
				mov dwBuffWidth, eax
				mov ebx, stRegPtEnd.y
				sub ebx, stRegPtBegin.y
				mov dwBuffHeight, ebx
				push	stRegPtBegin.y
				push	stRegPtBegin.x
				pop	stRegMvPtStart.x
				pop	stRegMvPtStart.y
				invoke SelectObject, stPaint.hMemDC, stPaint.hBitmap
				invoke SelectObject, hBuffDC, hBuffBitmap
				invoke BitBlt, hBuffDC, 0, 0, dwBuffWidth, dwBuffHeight, stPaint.hMemDC, stRegPtBegin.x, stRegPtBegin.y, SRCCOPY
				mov    bRegionMove, TRUE
				invoke _FillWithColor, stPaint.hMemDC, WHITE_COLOR, stRegPtBegin.x, stRegPtBegin.y, stRegPtEnd.x, stRegPtEnd.y, _hWnd, FALSE
		.elseif ax == ID_REGION_CLEAR
			
			invoke _FillWithColor, stPaint.hMemDC, WHITE_COLOR, stRegPtBegin.x, stRegPtBegin.y, stRegPtEnd.x, stRegPtEnd.y, _hWnd, TRUE

		.elseif ax == ID_REGION_FILL

			invoke _FillWithColor, stPaint.hMemDC, stPaint.dwCurColor, stRegPtBegin.x, stRegPtBegin.y, stRegPtEnd.x, stRegPtEnd.y, _hWnd, TRUE

		.endif

	.elseif eax == WM_CHANGE_COLOR
		mov		eax,_lParam
		mov		stPaint.dwCurColor, eax
		invoke	DeleteObject, @hPen

		invoke	CreatePen,PS_SOLID,bpenwidth,stPaint.dwCurColor
		mov		@hPen,eax

	.elseif eax ==WM_REGION_SAVEFILE
		
		push stRegPtBegin.x
		push stRegPtBegin.y
		push stRegPtEnd.x
		push stRegPtEnd.y

		pop	@stRect.bottom
		pop @stRect.right
		pop @stRect.top
		pop @stRect.left

		invoke _GetSaveFileName, offset szFileNameBuffer
		invoke _SaveScreenToBmp, addr @stRect, hWinMain

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
	invoke LoadIcon,hInstance,IDI_ICON_LOAD
	invoke LoadIcon,hInstance,IDI_ICON_SAVE
	invoke LoadIcon,hInstance,IDI_ICON_CLEAR
	invoke	RtlZeroMemory,addr @stWndClass,sizeof @stWndClass ;Fills a block of memory with zeros.

	; ����: MyRegisterClass()
	;
	; Ŀ��: ע�ᴰ���ࡣ
	;
	invoke	LoadCursor,0,IDC_ARROW
	mov		@stWndClass.hCursor,eax
	push	hInstance
	pop		@stWndClass.hInstance
	mov		@stWndClass.cbSize,sizeof WNDCLASSEX
	mov		@stWndClass.style,CS_HREDRAW or CS_VREDRAW
	mov		@stWndClass.lpfnWndProc,offset  _ProcWinMain
	mov		@stWndClass.hbrBackground,COLOR_WINDOW+1
	;COLOR_BACKGROUND COLOR_HIGHLIGHT COLOR_MENU COLOR_WINDOW..Ԥ��
	mov		@stWndClass.lpszClassName,offset szClassName
	mov		@stWndClass.lpszMenuName,IDR_MENU1
	invoke	RegisterClassEx,addr @stWndClass
	invoke	_RegisterColorClass, hInstance

	;//   ����:  InitInstance(HINSTANCE, int)
	;  Ŀ��:  ����ʵ�����������������
	;  �ڴ˺����У�������ȫ�ֱ����б���ʵ�������
	;  ��������ʾ�����򴰿ڡ�

	;WS_EX_CLIENTEDGEԤ�õ�һ����ʽ
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



	;invoke LoadAccelerators,hInstance,IDA_MENU;IDA_MENU��rc�ж���,Ϊ��ݼ�
	mov		hAccelerator,eax

	;��Ϣѭ��
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
