
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
