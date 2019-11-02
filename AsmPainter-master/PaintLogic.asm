_PaintMouseMove proc uses ebx edi esi, _hPen, _hBrush, _hWnd
	.if stPaint.bMouseDown == TRUE
		.if bpentype == PENTYPE_PENCIL
			invoke	SetROP2,stPaint.hMemDC,R2_COPYPEN

			invoke	CreatePen,PS_SOLID,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax
			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	LineTo,stPaint.hMemDC,stPaint.stMovPoint.x,stPaint.stMovPoint.y

			push	stPaint.stMovPoint.x
			push	stPaint.stMovPoint.y
			pop		stPaint.stHitPoint.y
			pop		stPaint.stHitPoint.x
			invoke	DeleteObject,_hPen
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.elseif bpentype == PENTYPE_CIRCLE
			invoke	SetROP2,stPaint.hMemDC,R2_NOTXORPEN

			invoke	CreatePen,PS_SOLID,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax
			invoke	GetStockObject,NULL_BRUSH
			mov		_hBrush,eax

			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	SelectObject,stPaint.hMemDC,_hBrush
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	Ellipse,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stLastMovPoint.x,stPaint.stLastMovPoint.y
			invoke	Ellipse,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stMovPoint.x,stPaint.stMovPoint.y

			push	stPaint.stMovPoint.x
			push	stPaint.stMovPoint.y
			pop		stPaint.stLastMovPoint.y
			pop		stPaint.stLastMovPoint.x

			invoke	DeleteObject,_hPen
			invoke	DeleteObject,_hBrush
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.elseif bpentype == PENTYPE_RECTANGLE
			invoke	SetROP2,stPaint.hMemDC,R2_NOTXORPEN

			invoke	CreatePen,PS_SOLID,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax
			invoke	GetStockObject,NULL_BRUSH
			mov		_hBrush,eax

			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	SelectObject,stPaint.hMemDC,_hBrush
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	Rectangle,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stLastMovPoint.x,stPaint.stLastMovPoint.y
			invoke	Rectangle,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stMovPoint.x,stPaint.stMovPoint.y

			push	stPaint.stMovPoint.x
			push	stPaint.stMovPoint.y
			pop		stPaint.stLastMovPoint.y
			pop		stPaint.stLastMovPoint.x

			invoke	DeleteObject,_hPen
			invoke	DeleteObject,_hBrush
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.elseif bpentype == PENTYPE_LINE
			invoke	SetROP2,stPaint.hMemDC,R2_NOTXORPEN

			invoke	CreatePen,PS_SOLID,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax

			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	SelectObject,stPaint.hMemDC,_hBrush
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	LineTo,stPaint.hMemDC,stPaint.stLastMovPoint.x,stPaint.stLastMovPoint.y
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	LineTo,stPaint.hMemDC,stPaint.stMovPoint.x,stPaint.stMovPoint.y

			push	stPaint.stMovPoint.x
			push	stPaint.stMovPoint.y
			pop		stPaint.stLastMovPoint.y
			pop		stPaint.stLastMovPoint.x

			invoke	DeleteObject,_hPen
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.elseif bpentype == PENTYPE_ERASER	
			invoke	SetROP2,stPaint.hMemDC,R2_WHITE

			invoke	CreatePen,PS_SOLID,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax
			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	LineTo,stPaint.hMemDC,stPaint.stMovPoint.x,stPaint.stMovPoint.y

			push	stPaint.stMovPoint.x
			push	stPaint.stMovPoint.y
			pop		stPaint.stHitPoint.y
			pop		stPaint.stHitPoint.x
			invoke	DeleteObject,_hPen
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.elseif bpentype == PENTYPE_CIRCLE_FILLED
			invoke	SetROP2,stPaint.hMemDC,R2_NOTXORPEN

			invoke	CreatePen,PS_SOLID,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax
			invoke	CreateSolidBrush,stPaint.dwCurColor
			mov		_hBrush,eax

			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	SelectObject,stPaint.hMemDC,_hBrush
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	Ellipse,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stLastMovPoint.x,stPaint.stLastMovPoint.y
			invoke	Ellipse,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stMovPoint.x,stPaint.stMovPoint.y

			push	stPaint.stMovPoint.x
			push	stPaint.stMovPoint.y
			pop		stPaint.stLastMovPoint.y
			pop		stPaint.stLastMovPoint.x

			invoke	DeleteObject,_hPen
			invoke	DeleteObject,_hBrush
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.elseif bpentype == PENTYPE_RECTANGLE_FILLED
			invoke	SetROP2,stPaint.hMemDC,R2_NOTXORPEN

			invoke	CreatePen,PS_SOLID,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax
			invoke	CreateSolidBrush,stPaint.dwCurColor
			mov		_hBrush,eax

			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	SelectObject,stPaint.hMemDC,_hBrush
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	Rectangle,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stLastMovPoint.x,stPaint.stLastMovPoint.y
			invoke	Rectangle,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stMovPoint.x,stPaint.stMovPoint.y

			push	stPaint.stMovPoint.x
			push	stPaint.stMovPoint.y
			pop		stPaint.stLastMovPoint.y
			pop		stPaint.stLastMovPoint.x

			invoke	DeleteObject,_hPen
			invoke	DeleteObject,_hBrush
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.elseif bpentype == PENTYPE_DOT	
			invoke	SetROP2,stPaint.hMemDC,R2_NOTXORPEN

			invoke	CreatePen,PS_DOT,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax

			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	SelectObject,stPaint.hMemDC,_hBrush
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	LineTo,stPaint.hMemDC,stPaint.stLastMovPoint.x,stPaint.stLastMovPoint.y
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	LineTo,stPaint.hMemDC,stPaint.stMovPoint.x,stPaint.stMovPoint.y

			push	stPaint.stMovPoint.x
			push	stPaint.stMovPoint.y
			pop		stPaint.stLastMovPoint.y
			pop		stPaint.stLastMovPoint.x

			invoke	DeleteObject,_hPen
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.endif
	.endif
	ret
_PaintMouseMove endp

_PaintLButtonUp proc uses ebx edx esi edi, _hPen, _hBrush, _hWnd, _lParam
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

			invoke	CreatePen,PS_SOLID,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax
			invoke	GetStockObject,NULL_BRUSH
			mov		_hBrush,eax
			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	SelectObject,stPaint.hMemDC,_hBrush
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	Ellipse,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stReleasePoint.x,stPaint.stReleasePoint.y

			invoke	DeleteObject,_hPen
			invoke	DeleteObject,_hBrush
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.elseif bpentype == PENTYPE_RECTANGLE;rectangle
			invoke	SetROP2,stPaint.hMemDC,R2_COPYPEN

			invoke	CreatePen,PS_SOLID,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax
			invoke	GetStockObject,NULL_BRUSH
			mov		_hBrush,eax
			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	SelectObject,stPaint.hMemDC,_hBrush
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	Rectangle,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stReleasePoint.x,stPaint.stReleasePoint.y

			invoke	DeleteObject,_hPen
			invoke	DeleteObject,_hBrush
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.elseif bpentype == PENTYPE_LINE;line
			invoke	SetROP2,stPaint.hMemDC,R2_COPYPEN

			invoke	CreatePen,PS_SOLID,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax
			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	LineTo,stPaint.hMemDC,stPaint.stReleasePoint.x,stPaint.stReleasePoint.y

			invoke	DeleteObject,_hPen
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.elseif bpentype == PENTYPE_CIRCLE_FILLED;circle
			invoke	SetROP2,stPaint.hMemDC,R2_COPYPEN

			invoke	CreatePen,PS_SOLID,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax
			invoke	CreateSolidBrush,stPaint.dwCurColor
			mov		_hBrush,eax
			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	SelectObject,stPaint.hMemDC,_hBrush
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	Ellipse,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stReleasePoint.x,stPaint.stReleasePoint.y

			invoke	DeleteObject,_hPen
			invoke	DeleteObject,_hBrush
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.elseif bpentype == PENTYPE_RECTANGLE_FILLED;rectangle
			invoke	SetROP2,stPaint.hMemDC,R2_COPYPEN

			invoke	CreatePen,PS_SOLID,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax
			invoke	CreateSolidBrush,stPaint.dwCurColor
			mov		_hBrush,eax
			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	SelectObject,stPaint.hMemDC,_hBrush
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	Rectangle,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,stPaint.stReleasePoint.x,stPaint.stReleasePoint.y

			invoke	DeleteObject,_hPen
			invoke	DeleteObject,_hBrush
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.elseif bpentype == PENTYPE_DOT	;line
			invoke	SetROP2,stPaint.hMemDC,R2_COPYPEN

			invoke	CreatePen,PS_DOT,bpenwidth,stPaint.dwCurColor
			mov		_hPen,eax
			invoke	SelectObject,stPaint.hMemDC,_hPen
			invoke	MoveToEx,stPaint.hMemDC,stPaint.stHitPoint.x,stPaint.stHitPoint.y,NULL
			invoke	LineTo,stPaint.hMemDC,stPaint.stReleasePoint.x,stPaint.stReleasePoint.y

			invoke	DeleteObject,_hPen
			invoke	InvalidateRect,_hWnd,0,FALSE
			invoke	UpdateWindow,_hWnd
		.endif
	.endif
	ret
_PaintLButtonUp endp