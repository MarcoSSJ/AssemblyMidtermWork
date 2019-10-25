;ɫ�ʸ��ӽ���

;��WM_CREATE�е����������
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

;ɫ�ʸ���(����)��Ӧ���¼�ѭ��
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
		invoke SetWindowLong,hWnd,0,@color
	.elseif eax == WM_PAINT
		invoke BeginPaint,hWnd,addr @ps
		mov @hdc,eax
		invoke GetClientRect,hWnd,addr @rt
		invoke GetWindowLong,hWnd,0
		mov @color,eax
		invoke CreateSolidBrush,@color
		mov @hbr,eax;
		invoke SelectObject,@hdc,@hbr
		mov @hOldBr,eax
		invoke Rectangle,@hdc,0,0,@rt.right,@rt.bottom
		invoke SelectObject,@hdc,@hOldBr
		invoke DeleteObject,@hbr
		invoke EndPaint,hWnd,addr @ps
	.elseif eax == WM_LBUTTONDOWN
		invoke GetWindowLong,hWnd,0
		mov @color,eax
		invoke GetParent,hWnd
		mov ebx,eax
		invoke SendMessage,ebx,WM_CHANGE_COLOR,0,@color;����WM_CHANGE_COLOR�ź�
	.elseif eax == WM_DESTROY
		nop
	.else
		invoke DefWindowProc,hWnd,message,wParam,lParam
		ret
	.endif
	mov eax,0
	ret
_WndColorBtnProc  endp

;ɫ�ʰ��Ӧ���¼�ѭ��,����ʱ�ᴴ��24��ɫ�ʸ���
_WndColorBoxProc proc  uses ebx edi esi,hWnd,message,wParam,lParam
	LOCAL @ps:PAINTSTRUCT
	LOCAL @hdc:HDC
	LOCAL @i:DWORD
	LOCAL @hWndColor:HWND
	LOCAL @hInsthWnd:HINSTANCE
	LOCAL @width:DWORD

	mov eax,message
	.if eax == WM_CREATE
		mov ecx,lParam
        mov eax,[ecx].CREATESTRUCTA.lpCreateParams
		mov hWndSendTo,eax
		invoke GetWindowLong,hWnd,GWL_HINSTANCE
		mov @hInsthWnd,eax
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
		invoke SendMessage,hWndSendTo,message,wParam,lParam;;����WM_CHANGE_COLOR�ź�
	.elseif eax == WM_DESTROY
		nop
	.else
		invoke DefWindowProc,hWnd,message,wParam,lParam
		ret
	.endif
	mov eax,0
	ret
_WndColorBoxProc endp

;ע��ɫ�ʸ��Ӻ�ɫ�ʰ����ര��
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
	invoke RegisterClassEx,addr @wcex; 
	.if !eax
		mov eax,0
		ret
	.endif
	mov @wcex.lpszClassName,offset szColorBoxClass
	mov @wcex.lpszMenuName,NULL
	mov @wcex.lpfnWndProc,offset _WndColorBoxProc;TODO
	mov @wcex.cbWndExtra,0;
	invoke RegisterClassEx,addr @wcex; 
	.if !eax
		mov eax,0
		ret
	.endif
	mov eax,1
ret
_RegisterColorClass endp