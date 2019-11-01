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

include windows.inc
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
include gdi32.inc
includelib gdi32.lib
include comctl32.inc
includelib comctl32.lib
include comdlg32.inc
includelib comdlg32.lib
include msvcrt.inc
includelib msvcrt.lib
PAINTINFO STRUCT
  stHitPoint				POINT		<>
  stMovPoint				POINT		<>
  stLastMovPoint			POINT		<>
  stReleasePoint			POINT		<>
	bMouseDown	byte	0
	hBitmap		HBITMAP	?
	hMemDC		HDC		?
	dwWidth		DWORD	?
	dwHeight	DWORD	?
PAINTINFO ENDS


WM_CHANGE_COLOR			equ			WM_USER + 1
WM_SELECT_COLOR			equ			WM_USER + 2
IDR_MENU1               equ			101
IDM_OPEN				equ			40001
IDM_SAVE				equ			40002
ID_FILE_OPENFILE		equ			40002
ID_FILE_SAVE			equ			40003
ID_PEN_WIDTH1           equ         40004
ID_PEN_WIDTH2           equ         40005
ID_PEN_WIDTH3           equ         40006
ID_PEN_WIDTH4           equ			40007
ID_PEN_WIDTH5           equ         40008
ID_PEN_WIDTH6           equ         40009
ID_PEN_WIDTH7           equ         40010
ID_PEN_WIDTH8           equ			40011
ID_PEN_WIDTH9           equ         40012
ID_PEN_WIDTH10          equ         40013
ID_SHAPE_CIRCLE         equ         40014
ID_SHAPE_RECTANGLE      equ         40015
ID_SHAPE_LINE           equ         40016
ID_SHAPE_PENCIL         equ         40017
ID_SHAPE_EARSER         equ         40018
ID_COLOR_SELECT			equ			40019
MAX_FILESIZE			equ			1000
WINDOW_WIDTH			equ			800
WINDOW_HEIGHT			equ			600
COLOR_BUTTON_WIDTH		equ			40
.data
;bMouseClick				db			FALSE
dwCurColor				dd			0
bpenwidth				db			1
bpentype				db			1;1：pencil, 2：circle, 3:Rectangle, 4:line, default:pencil
dwColors				dd			0h,\
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
COLORS_NUM				equ			($ - offset dwColors)

.data?
hInstance				dd			?
hWinMain				dd			?
hWndSendTo				dd			?
hWndColor				dd			?
hMenu					dd			?
hAccelerator			dd			?
hWndColorBtns			dd			COLORS_NUM dup(?)


;dBuffer					dd			?
;stHitPoint				POINT		<>
;stLastMovPoint			POINT		<>
;stMovPoint				POINT		<>
;stReleasePoint			POINT		<>
szFileNameBuffer		db			MAX_FILESIZE DUP(?)
stPaint		PAINTINFO	<>

.const
szClassName				db			'MyClass',0
szCaptionMain			db			'MyPainter',0
szColorBtnClass			db			'ColorBtn', 0
szColorBoxClass			db			'ColorBox', 0
szFilter				db			"BitMap(*.bmp)",0,"*.bmp",0
szOtherBmp				db			".bmp",0
szDefaultSaveFile		db			"1.bmp",0
szDefaultOpenFile		db			".bmp",0
szErrorSuffixNoBmp		db			'保存格式必须以bmp结尾!',0
szError					db			'Error!',0
