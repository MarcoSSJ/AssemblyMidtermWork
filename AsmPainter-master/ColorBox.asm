;色彩格子界面

;在WM_CREATE中调用这个函数
_CreateColorBox proc uses ebx esi edi, _hInst:HINSTANCE, _hWnd:HWND ,_isDock: DWORD
local @rt:RECT 
local @pt1:POINT
local @pt2:POINT
local @hWndColorBox:HWND
local @rtWidth:DWORD
local @rtHeight:DWORD
	mov	eax, _isDock
	.if eax
		invoke	SetRect,addr @rt,0,0,480,80
		invoke	AdjustWindowRect,addr @rt,WS_CHILD or WS_VISIBLE or WS_BORDER,0
		
		mov		esi,@rt.right
		mov		edi,@rt.left
		sub		esi,edi
		mov		@rtWidth,esi

		mov		esi,@rt.bottom
		mov		edi,@rt.top
		sub		esi,edi
		mov		@rtHeight,esi

		invoke	CreateWindowEx,NULL,offset szColorBoxClass,0,WS_CHILD or WS_VISIBLE or WS_BORDER,@rt.left,@rt.top,
			@rtWidth,@rtHeight,_hWnd,0,_hInst,_hWnd
		mov		@hWndColorBox,eax
	.else
		mov		@pt1.x,200
		mov		@pt1.y,0
		mov		@pt2.x,680
		mov		@pt2.y,80
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

		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,offset szColorBoxClass,0,
				WS_POPUP or WS_CAPTION or WS_VISIBLE or WS_BORDER,
				@rt.left,@rt.top,
				@rtWidth,@rtHeight, _hWnd, 0, _hInst, _hWnd
		mov		@hWndColorBox,eax
	.endif
	mov eax,@hWndColorBox
	ret
_CreateColorBox endp

;色彩格子(窗口)对应的事件循环
_WndColorBtnProc proc uses ebx edi esi,_hWnd,_stMsg,_wParam,_lParam
local	@ps:PAINTSTRUCT
local	@hdc:HDC 
local	@color:COLORREF
local	@hbr:HBRUSH 
local	@hOldBr:HBRUSH
local	@rt:RECT
	mov	eax,_stMsg
	.if eax == WM_CREATE
		mov		ecx,_lParam
        mov		eax,[ecx].CREATESTRUCTA.lpCreateParams
		mov		@color,eax
		invoke	SetWindowLong,_hWnd,0,@color
	.elseif eax == WM_PAINT
		invoke	BeginPaint,_hWnd,addr @ps
		mov		@hdc,eax
		invoke	GetClientRect,_hWnd,addr @rt
		invoke	GetWindowLong,_hWnd,0
		mov		@color,eax
		invoke	CreateSolidBrush,@color
		mov		@hbr,eax;
		invoke	SelectObject,@hdc,@hbr
		mov		@hOldBr,eax
		invoke	Rectangle,@hdc,0,0,@rt.right,@rt.bottom
		invoke	SelectObject,@hdc,@hOldBr
		invoke	DeleteObject,@hbr
		invoke	EndPaint,_hWnd,addr @ps
	.elseif eax == WM_LBUTTONDOWN
		invoke	GetWindowLong,_hWnd,0
		mov		@color,eax
		invoke	GetParent,_hWnd
		mov		ebx,eax
		invoke	SendMessage,ebx,WM_CHANGE_COLOR,0,@color;传递WM_CHANGE_COLOR信号
	.elseif eax == WM_DESTROY
		;invoke	PostQuitMessage,NULL 这个是主窗口用的
	.else
		invoke	DefWindowProc,_hWnd,_stMsg,_wParam,_lParam
		ret
	.endif
	mov eax,0
	ret
_WndColorBtnProc  endp

_CloseAllColorBtns proc uses ebx ecx esi
	mov		ecx,COLORS_NUM
	mov		esi,0
	@@:
		pushad
		invoke SendMessage, hWndColorBtns[esi], WM_CLOSE, NULL, NULL
		popad
		add esi,4
		sub ecx,4
		cmp ecx,0
		jne @B
	ret
_CloseAllColorBtns endp

_CreateAllColorBtns proc uses ebx edx edi esi, _hInsthWnd, _hWnd
local	@width: dword
local	@hWndColor: HWND
	mov		ecx,COLORS_NUM
	mov		esi,0
	mov		edi,ecx
	shr		edi,1
	mov		@width,edi
@@:
	.if esi < @width
		pushad
		mov		eax,esi
		shr		eax,2
		mov		ebx,COLOR_BUTTON_WIDTH
		mul		ebx
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,
				offset szColorBtnClass,0,WS_CHILD,
				eax,0,COLOR_BUTTON_WIDTH,COLOR_BUTTON_WIDTH,_hWnd,
				0,_hInsthWnd,dwColors[esi]
		mov		@hWndColor,eax
		mov		hWndColorBtns[esi], eax
		invoke	ShowWindow,@hWndColor,SW_NORMAL
		popad
	.else
		pushad
		mov		eax,esi
		sub		eax,edi
		shr		eax,2
		mov		ebx,COLOR_BUTTON_WIDTH
		mul		ebx; 40 * Buttonsize
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,
				offset szColorBtnClass,0,WS_CHILD,
				eax,COLOR_BUTTON_WIDTH,COLOR_BUTTON_WIDTH,COLOR_BUTTON_WIDTH,_hWnd,
				0,_hInsthWnd,dwColors[esi]
		mov		@hWndColor,eax
		mov		hWndColorBtns[esi], eax
		invoke	ShowWindow,@hWndColor,SW_NORMAL
		popad
	.endif
	add esi,4
	sub ecx,4
	cmp ecx,0
	jne @B
	ret
_CreateAllColorBtns endp

_UpdateColorBox	proc uses ebx edi esi, _dwColor: dword, _hInsthWnd, _hWnd
local	@dwTmpColor: dword
	mov eax, dwColors
	.if eax != _dwColor
		invoke _CloseAllColorBtns

		mov eax, _dwColor
		mov @dwTmpColor, eax
		;将新的颜色加入到dwColors中
		mov		ecx,COLORS_NUM
		mov		esi,0
		@@:
			mov ebx, dwColors[esi]
			mov eax, @dwTmpColor
			mov dwColors[esi], eax
			mov @dwTmpColor, ebx
			add esi,4
			sub ecx,4
			cmp ecx,0
			jne @B
		invoke _CreateAllColorBtns, _hInsthWnd, _hWnd
	.endif
	ret
_UpdateColorBox endp


;色彩板对应的事件循环,创建时会创建24个色彩格子
_WndColorBoxProc proc  uses ebx edi esi,_hWnd,_stMsg,_wParam,_lParam
local @ps:PAINTSTRUCT
local @hdc:HDC
local @hWndColor:HWND
local @hInsthWnd:HINSTANCE
local @width:DWORD

	mov eax,_stMsg
	.if eax == WM_CREATE
		mov		ecx,_lParam
        mov		eax,[ecx].CREATESTRUCTA.lpCreateParams
		mov		hWndSendTo,eax
		invoke	GetWindowLong,_hWnd,GWL_HINSTANCE
		mov		@hInsthWnd,eax
		invoke	_CreateAllColorBtns, @hInsthWnd, _hWnd
		;mov		ecx,COLORS_NUM
		;mov		esi,0
		;mov		edi,ecx
		;shr		edi,1
		;mov		@width,edi
	;@@:
		;.if esi < @width
			;pushad
			;mov		eax,esi
			;shr		eax,2
			;mov		ebx,COLOR_BUTTON_WIDTH
			;mul		ebx
			;invoke	CreateWindowEx,WS_EX_CLIENTEDGE,
					;offset szColorBtnClass,0,WS_CHILD,
					;eax,0,COLOR_BUTTON_WIDTH,COLOR_BUTTON_WIDTH,_hWnd,
					;0,@hInsthWnd,dwColors[esi]
			;mov		@hWndColor,eax
			;mov		hWndColorBtns[esi], eax
			;invoke	ShowWindow,@hWndColor,SW_NORMAL
			;popad
		;.else
			;pushad
			;mov		eax,esi
			;sub		eax,edi
			;shr		eax,2
			;mov		ebx,COLOR_BUTTON_WIDTH
			;mul		ebx; 40 * Buttonsize
			;invoke	CreateWindowEx,WS_EX_CLIENTEDGE,
					;offset szColorBtnClass,0,WS_CHILD,
					;eax,COLOR_BUTTON_WIDTH,COLOR_BUTTON_WIDTH,COLOR_BUTTON_WIDTH,_hWnd,
					;0,@hInsthWnd,dwColors[esi]
			;mov		@hWndColor,eax
			;mov		hWndColorBtns[esi], eax
			;invoke	ShowWindow,@hWndColor,SW_NORMAL
			;popad
		;.endif
		;add esi,4
		;sub ecx,4
		;cmp ecx,0
		;jne @B
	.elseif eax == WM_PAINT
		invoke	BeginPaint,_hWnd,addr @ps
		mov		@hdc, eax
		invoke	EndPaint,_hWnd,addr @ps
	.elseif eax == WM_CHANGE_COLOR
		invoke	SendMessage,hWndSendTo,_stMsg,_wParam,_lParam;;传递WM_CHANGE_COLOR信号
	.elseif eax == WM_SELECT_COLOR
		invoke	GetWindowLong,_hWnd,GWL_HINSTANCE
		mov		@hInsthWnd,eax
		invoke	_UpdateColorBox, _lParam, @hInsthWnd, _hWnd
	.elseif eax == WM_DESTROY
		nop
	.else
		invoke	DefWindowProc,_hWnd,_stMsg,_wParam,_lParam
		ret
	.endif
	mov eax,0
	ret
_WndColorBoxProc endp

;注册色彩格子和色彩板两类窗口
_RegisterColorClass proc _hInstance
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
	mov		@wcex.lpszClassName,offset szColorBtnClass
	mov		@wcex.lpszMenuName,NULL;
	mov		@wcex.lpfnWndProc,offset _WndColorBtnProc;TODO
	mov		@wcex.cbWndExtra,4;
	invoke	RegisterClassEx,addr @wcex; 
	.if !eax
		mov	eax,0
		ret
	.endif
	mov		@wcex.lpszClassName,offset szColorBoxClass
	mov		@wcex.lpszMenuName,NULL
	mov		@wcex.lpfnWndProc,offset _WndColorBoxProc;TODO
	mov		@wcex.cbWndExtra,0;
	invoke	RegisterClassEx,addr @wcex; 
	.if !eax
		mov eax,0
		ret
	.endif
	mov eax,1
ret
_RegisterColorClass endp