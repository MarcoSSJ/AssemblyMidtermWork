;工具栏窗口对应的代码
;工具栏中的每一个工具都是一个bmp构成的图标子窗口
;点击图标会传递消息回主窗口

;创建工具栏,完成注册并将其放置于主窗口的某一位置
;isDock原本像用来表示他是否内嵌,后来没有实现
_CreateToolBox proc uses ebx esi edi, _hInst:HINSTANCE, _hWnd:HWND ,_isDock: DWORD
local @rt:RECT 
local @pt1:POINT
local @pt2:POINT
local @hWndColorBox:HWND
local @rtWidth, @rtHeight: dword
	mov		@pt1.x,100
	mov		@pt1.y,100
	mov		@pt2.x,130
	mov		@pt2.y,776
	invoke	ClientToScreen,	_hWnd,addr @pt1
	invoke	ClientToScreen, _hWnd,addr @pt2

	invoke	SetRect,addr @rt,@pt1.x,@pt1.y,@pt2.x,@pt2.y
		
	invoke	AdjustWindowRect,addr @rt,WS_POPUP or WS_CAPTION or WS_VISIBLE or WS_BORDER,0
		
	mov		esi,@rt.right
	mov		edi,@rt.left
	sub		esi,edi
	mov		@rtWidth,esi

	mov		esi,@rt.bottom
	mov		edi,@rt.top
	sub		esi,edi
	mov		@rtHeight,esi

	invoke	CreateWindowEx,WS_EX_CLIENTEDGE,offset szToolBoxClass,0,
			WS_POPUP or WS_CAPTION or WS_VISIBLE or WS_BORDER,
			@rt.left,@rt.top,
			@rtWidth,@rtHeight, _hWnd, 0, _hInst, _hWnd
	mov		@hWndColorBox,eax
	mov eax,@hWndColorBox
	ret
_CreateToolBox endp



;tool中每一个的格子(窗口)对应的事件循环
_WndToolBtnProc proc uses ebx edi esi,_hWnd,_stMsg,_wParam,_lParam
local	@ps:PAINTSTRUCT
local	@hdc:HDC 
local	@hIcon: HICON
local	@hMemDC:  HDC
local	@hParWnd: HWND
local	@dwF:	dword
local	@hIns:	HINSTANCE
	mov	eax,_stMsg
	.if eax == WM_CREATE
		mov		ecx,_lParam
        mov		eax,[ecx].CREATESTRUCTA.lpCreateParams
		invoke	SetWindowLong,_hWnd,0,eax
	.elseif eax == WM_PAINT
		invoke	BeginPaint,_hWnd,addr @ps
		mov		@hdc,eax
		invoke	GetWindowLong,_hWnd,0
		mov		@dwF, eax
		invoke	GetWindowLong, _hWnd, GWL_HINSTANCE
		mov		@hIns, eax
		invoke	CreateCompatibleDC,	@hdc
		mov		@hMemDC, eax
		invoke	LoadBitmap, @hIns, @dwF
		mov		@hIcon, eax
		invoke	SelectObject,@hMemDC,@hIcon
		invoke	BitBlt, @hdc, 0, 0, ICON_WIDTH, ICON_WIDTH, @hMemDC, 0, 0, SRCCOPY
		invoke	ReleaseDC, _hWnd, @hdc
		invoke	EndPaint,_hWnd,addr @ps
	.elseif eax == WM_LBUTTONDOWN
		invoke	GetWindowLong,_hWnd,0
		mov		@dwF,eax
		invoke	GetParent,_hWnd
		mov		@hParWnd,eax
		invoke	SendMessage, @hParWnd, WM_TAP_ICON,0,@dwF;传递WM_CHANGE_COLOR信号
	.elseif eax == WM_DESTROY
		;invoke	PostQuitMessage,NULL 这个是主窗口用的
	.else
		invoke	DefWindowProc,_hWnd,_stMsg,_wParam,_lParam
		ret
	.endif
	mov eax,0
	ret
_WndToolBtnProc  endp

;toolbar对应的事件循环,创建时会创建24个色彩格子
_WndToolBoxProc proc  uses ebx ecx edi esi,_hWnd,_stMsg,_wParam,_lParam
local @ps:PAINTSTRUCT
local @hdc:HDC
local @hWndTool:HWND
local @hInsthWnd:HINSTANCE
local @width:DWORD
local @dwSend: dword

	mov eax,_stMsg
	.if eax == WM_CREATE
		mov		ecx,_lParam
        mov		eax,[ecx].CREATESTRUCTA.lpCreateParams
		mov		hWndSendTo,eax
		invoke	GetWindowLong,_hWnd,GWL_HINSTANCE
		mov		@hInsthWnd,eax
		
		mov		ecx,ICON_NUM
		shl		ecx,2
		mov		esi,0
		@@:
			pushad
			mov		eax,esi
			shr		eax,2
			mov		ebx,ICON_WIDTH
			mul		ebx; 24 * Buttonsize
			invoke	CreateWindowEx,WS_EX_CLIENTEDGE,
					offset szToolBtnClass,0,WS_CHILD,
					0,eax,ICON_WIDTH,ICON_WIDTH,_hWnd,
					0,@hInsthWnd,dwIcons[esi]
			mov		@hWndTool,eax
			invoke	ShowWindow,@hWndTool,SW_NORMAL
			popad
			add esi,4
			sub ecx,4
			cmp ecx,0
			jne @B
	.elseif eax == WM_PAINT
		invoke	BeginPaint,_hWnd,addr @ps
		mov		@hdc, eax
		invoke	EndPaint,_hWnd,addr @ps
	.elseif eax == WM_TAP_ICON
		mov	eax, _lParam
		.if eax == IDI_ICON_LOAD
			mov @dwSend, ID_FILE_OPENFILE
		.elseif eax == IDI_ICON_SAVE
			mov @dwSend, ID_FILE_SAVE
		.elseif eax == IDI_ICON_CLEAR
			mov @dwSend, ID_FILE_CLEAR
		.elseif eax == IDI_ICON1
			mov @dwSend, ID_PEN_WIDTH1
		.elseif eax == IDI_ICON2
			mov @dwSend, ID_PEN_WIDTH2
		.elseif eax == IDI_ICON3
			mov @dwSend, ID_PEN_WIDTH3
		.elseif eax == IDI_ICON4
			mov @dwSend, ID_PEN_WIDTH4
		.elseif eax == IDI_ICON5
			mov @dwSend, ID_PEN_WIDTH5
		.elseif eax == IDI_ICON6
			mov @dwSend, ID_PEN_WIDTH6
		.elseif eax == IDI_ICON7
			mov @dwSend, ID_PEN_WIDTH7
		.elseif eax == IDI_ICON8
			mov @dwSend, ID_PEN_WIDTH8
		.elseif eax == IDI_ICON9
			mov @dwSend, ID_PEN_WIDTH9
		.elseif eax == IDI_ICON_CIRCLE
			mov @dwSend, ID_SHAPE_CIRCLE
		.elseif eax == IDI_ICON_CIRCLEF
			mov @dwSend, ID_SHAPE_CIRCLE_FILLED
		.elseif eax == IDI_ICON_RECT
			mov @dwSend, ID_SHAPE_RECTANGLE
		.elseif eax == IDI_ICON_RECTF
			mov @dwSend, ID_SHAPE_RECTANGLE_FILLED
		.elseif eax == IDI_ICON_LINE
			mov @dwSend, ID_SHAPE_LINE
		.elseif eax == IDI_ICON_DOTTED
			mov @dwSend, ID_SHAPE_DOT
		.elseif eax == IDI_ICON_PENCIL
			mov @dwSend, ID_SHAPE_PENCIL
		.elseif eax == IDI_ICON_ERASER
			mov @dwSend, ID_SHAPE_ERASER
		.elseif eax == IDI_ICON_COLOR
			mov @dwSend, ID_COLOR_SELECT
		.elseif eax == IDI_ICON_PICK
			mov @dwSend, ID_COLOR_PICK
		.elseif eax == IDI_ICON_SET
			mov @dwSend, ID_REGION_SET
		.elseif eax == IDI_ICON_FILL
			mov @dwSend, ID_REGION_FILL
		.elseif eax == IDI_ICON_SCREENSHOT
			mov @dwSend, ID_REGION_SAVE
		.elseif eax == IDI_ICON_CLEARR
			mov @dwSend, ID_REGION_CLEAR
		.elseif eax == IDI_ICON_MOVE
			mov @dwSend, ID_REGION_MOVE
		.elseif eax == IDI_ICON_COPY
			mov @dwSend, ID_REGION_COPY
		.endif
		invoke	SendMessage,hWndSendTo,WM_COMMAND, @dwSend, _lParam;传递WM_CHANGE_COLOR信号
	.elseif eax == WM_DESTROY
		nop
	.else
		invoke	DefWindowProc,_hWnd,_stMsg,_wParam,_lParam
		ret
	.endif
	mov eax,0
	ret
_WndToolBoxProc endp

;注册色彩格子和色彩板两类窗口
_RegisterToolClass proc _hInstance
local @wcex:WNDCLASSEX

	mov		@wcex.cbSize,sizeof WNDCLASSEX
	mov		@wcex.style,CS_HREDRAW or CS_VREDRAW
	mov		@wcex.cbClsExtra,0
	mov		@wcex.cbWndExtra,0
	mov		eax,_hInstance
	mov		@wcex.hInstance,eax
	mov		@wcex.hIcon,NULL
	invoke	LoadCursor,NULL, IDC_ARROW
	mov		@wcex.hCursor,eax
	mov		@wcex.hbrBackground,COLOR_WINDOW + 1
	mov		@wcex.lpszMenuName, NULL;
	mov		@wcex.hIconSm,NULL;
	mov		@wcex.lpszClassName,offset szToolBtnClass
	mov		@wcex.lpszMenuName,NULL;
	mov		@wcex.lpfnWndProc,offset _WndToolBtnProc;TODO
	mov		@wcex.cbWndExtra,4;
	invoke	RegisterClassEx,addr @wcex; 
	.if !eax
		mov	eax,0
		ret
	.endif
	mov		@wcex.lpszClassName,offset szToolBoxClass
	mov		@wcex.lpszMenuName,NULL
	mov		@wcex.lpfnWndProc,offset _WndToolBoxProc;TODO
	mov		@wcex.cbWndExtra,0;
	invoke	RegisterClassEx,addr @wcex; 
	.if !eax
		mov eax,0
		ret
	.endif
	mov eax,1
ret
_RegisterToolClass endp