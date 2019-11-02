_RegionMouseMove proc uses ebx edi esi, _hPen, _hBrush, _hWnd
	.if stRegion.bMouseDown == TRUE
		.if bRegionMove == TRUE
			mov eax, stRegion.stMovPoint.x
			mov ebx, stRegion.stMovPoint.y
			sub eax, stRegion.stHitPoint.x
			sub ebx, stRegion.stHitPoint.y
			mov stRegMvPtDelta.x, eax
			mov stRegMvPtDelta.y, ebx

		.else
			invoke	SetROP2,stRegion.hMemDC,R2_NOTXORPEN

			invoke	CreatePen,PS_SOLID,bpenwidth,stRegion.dwCurColor
			mov		_hPen,eax
			invoke	GetStockObject,GRAY_BRUSH
			mov		_hBrush,eax

			invoke	SelectObject,stRegion.hMemDC,_hPen
			invoke	SelectObject,stRegion.hMemDC,_hBrush
			invoke	MoveToEx,stRegion.hMemDC,stRegion.stHitPoint.x,stRegion.stHitPoint.y,NULL
			invoke	Rectangle,stRegion.hMemDC,stRegion.stHitPoint.x,stRegion.stHitPoint.y,stRegion.stLastMovPoint.x,stRegion.stLastMovPoint.y
			invoke	Rectangle,stRegion.hMemDC,stRegion.stHitPoint.x,stRegion.stHitPoint.y,stRegion.stMovPoint.x,stRegion.stMovPoint.y

			push	stRegion.stMovPoint.x
			push	stRegion.stMovPoint.y
			pop		stRegion.stLastMovPoint.y
			pop		stRegion.stLastMovPoint.x

			invoke	DeleteObject,_hPen
			invoke	DeleteObject,_hBrush

		.endif
		invoke	InvalidateRect,_hWnd,0,FALSE
		invoke	UpdateWindow,_hWnd
	.endif
	ret
_RegionMouseMove endp

_RegionLButtonUp proc uses ebx edx esi edi, _hPen, _hBrush, _hWnd, _lParam
	mov eax,_lParam
	and eax,0FFFFh
	mov stRegion.stReleasePoint.x,eax
	mov eax,_lParam
	shr eax,16
	mov stRegion.stReleasePoint.y,eax
	.if stRegion.bMouseDown == TRUE
		invoke	SetROP2,stRegion.hMemDC,R2_COPYPEN

		invoke	CreatePen,PS_SOLID,bpenwidth,stRegion.dwCurColor
		mov		_hPen,eax
		invoke	GetStockObject, GRAY_BRUSH
		mov		_hBrush,eax
		invoke	SelectObject,stRegion.hMemDC,_hPen
		invoke	SelectObject,stRegion.hMemDC,_hBrush
		invoke	MoveToEx,stRegion.hMemDC,stRegion.stHitPoint.x,stRegion.stHitPoint.y,NULL
		invoke	Rectangle,stRegion.hMemDC,stRegion.stHitPoint.x,stRegion.stHitPoint.y,stRegion.stReleasePoint.x,stRegion.stReleasePoint.y

		invoke	DeleteObject,_hPen
		invoke	DeleteObject,_hBrush
		invoke	InvalidateRect,_hWnd,0,FALSE
		invoke	UpdateWindow,_hWnd

		push stRegion.stHitPoint.x
		push stRegion.stHitPoint.y
		push stRegion.stReleasePoint.x
		push stRegion.stReleasePoint.y
		pop stRegPtEnd.y
		pop stRegPtEnd.x
		pop stRegPtBegin.y
		pop stRegPtBegin.x
		.if bRegionMove == TRUE
			
			invoke SelectObject, stPaint.hMemDC, stPaint.hBitmap
			invoke SelectObject, hBuffDC, hBuffBitmap

			
			mov eax, stRegMvPtStart.x
			add eax, stRegMvPtDelta.x
			mov ebx, stRegMvPtStart.y
			add ebx, stRegMvPtDelta.y
			invoke BitBlt, stPaint.hMemDC, eax, ebx, dwBuffWidth, dwBuffHeight, hBuffDC, 0, 0, SRCAND
			mov bRegionMove, FALSE

		.endif
	.endif
	mov stRegion.bMouseDown,FALSE
	ret
_RegionLButtonUp endp