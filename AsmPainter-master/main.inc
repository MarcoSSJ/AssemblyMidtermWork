;������������
;	b,w,dw	��ʾ������byte,word,dword
;	h		��ʾ����
;	lp		��ʾָ��
;	sz		��ʾ�ַ���
;	lpsz	��ʾ�ַ���ָ��
;	f		��ʾ������
;	st		��ʾһ�����ݽṹ
;	��������+������,��ͷСд,������д
;�����淶!
;	�������ô�д+�»���
;	ȫ�ֱ�����������������
;	������_��ͷ
;	�ֲ�������@��ͷ
;	�Զ��庯����ͷ�������»���!
;	ָ���ͼĴ�����Сд
;�����淶
;	�ֲ�������ַʹ��addr/lea,ȫ�ֱ�����ַʹ��offset
;	ȫ�ֱ���������.inc��
;	���ÿ⺯��������.inc��
;	ʹ��equ������=
;	ʹ��db,dw,dd������byte,word,dword
;	��תʹ��@@ �� @B(ǰ����һ��@@) ��@F(������һ��@@)
;	�Ӻ�����ʹ��proc,uses,local��αָ��
;�����淶
;	һ�������ͱ��Ŷ���ǰ������
;	һ������ָ��Ҫ��tab����
;	��֧��ѭ��������һ��
;��������
;	����ʹ�ú�

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
  bMouseDown				byte		0
  hBitmap					HBITMAP		?
  hMemDC					HDC			?
  dwWidth					DWORD		?
  dwHeight					DWORD		?
  dwCurColor				dd			0
PAINTINFO ENDS

WM_CHANGE_COLOR			equ			WM_USER + 1
WM_SELECT_COLOR			equ			WM_USER + 2
WM_REGION_SAVEFILE		equ			WM_USER + 3
WM_TAP_ICON				equ			WM_USER + 4

;IDM_OPEN				equ			30001
;IDM_SAVE				equ			30002
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
ID_SHAPE_ERASER         equ         40018
ID_SHAPE_CIRCLE_FILLED    equ       40019
ID_SHAPE_RECTANGLE_FILLED equ       40020
ID_SHAPE_DOT            equ         40021
ID_COLOR_SELECT			equ			40022
ID_COLOR_PICK			equ			40023
ID_FILE_CLEAR			equ			40024
ID_REGION_SET			equ			40025
ID_REGION_SAVE			equ			40026
ID_REGION_MOVE			equ			40027
ID_REGION_COPY			equ			40028
ID_REGION_CLEAR			equ			40029
ID_REGION_FILL			equ			40030

PENTYPE_PENCIL			equ			0
PENTYPE_CIRCLE			equ			1
PENTYPE_RECTANGLE		equ			2
PENTYPE_LINE			equ			3
PENTYPE_ERASER			equ			4
PENTYPE_CIRCLE_FILLED	equ			5
PENTYPE_RECTANGLE_FILLED equ		6
PENTYPE_DOT				equ			7
PENTYPE_PICKCOLOR		equ			10
MAX_FILESIZE			equ			1000
WINDOW_WIDTH			equ			800
WINDOW_HEIGHT			equ			600
COLOR_BUTTON_WIDTH		equ			40

;ico����
IDR_MENU1               equ			100
IDI_ICON1               equ			101
IDI_ICON2               equ			102
IDI_ICON3               equ			103
IDI_ICON4               equ			104
IDI_ICON5               equ			105
IDI_ICON6               equ			106
IDI_ICON7               equ			107
IDI_ICON8               equ			108
IDI_ICON9               equ			109
IDI_ICON_CIRCLE         equ			110
IDI_ICON_CIRCLEF        equ			111
IDI_ICON_CLEARR         equ			112
IDI_ICON_CLEAR          equ			113
IDI_ICON_COLOR          equ			114
IDI_ICON_COPY           equ			115
IDI_ICON_DOTTED         equ			116
IDI_ICON_FILL           equ			117
IDI_ICON_LINE           equ			118
IDI_ICON_LOAD           equ			119
IDI_ICON_MOVE           equ			120
IDI_ICON_PENCIL         equ			121
IDI_ICON_PICK           equ			122
IDI_ICON_RECT           equ			123
IDI_ICON_RECTF          equ			124
IDI_ICON_SAVE           equ			125
IDI_ICON_SCREENSHOT     equ			126
IDI_ICON_SET            equ			127
IDI_ICON_ERASER			equ			128
IDI_ICON_TITLE			equ			129
ID_TOOLBAR				equ			1

IDM_NEW		equ	1101
IDM_OPEN	equ	1102
IDM_SAVE	equ	1103


WHITE_COLOR				equ			0ffffffh
.data
;bMouseClick				db			FALSE

bpenwidth				db			1
bpentype				db			0;1��pencil, 2��circle, 3:Rectangle, 4:line, default:pencil
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
COLORS_NUM				equ			($ - offset dwColors) / 4

dwIcons					dd			IDI_ICON_LOAD,\
									IDI_ICON_SAVE,\
									IDI_ICON_CLEAR,\
									IDI_ICON_PENCIL,\
									IDI_ICON_ERASER,\
									IDI_ICON_RECT,\
									IDI_ICON_CIRCLE,\
									IDI_ICON_LINE,\
									IDI_ICON_RECTF,\
									IDI_ICON_CIRCLEF
dwIcons1						dd	IDI_ICON_DOTTED,\
									IDI_ICON_COLOR,\
									IDI_ICON_PICK,\
									IDI_ICON_SET,\
									IDI_ICON_CLEARR,\
									IDI_ICON_FILL,\
									IDI_ICON_MOVE,\
									IDI_ICON_COPY,\
									IDI_ICON_SCREENSHOT
dwIcons2				dd			IDI_ICON1,\
									IDI_ICON2,\
									IDI_ICON3,\
									IDI_ICON4,\
									IDI_ICON5,\
									IDI_ICON6,\
									IDI_ICON7,\
									IDI_ICON8,\
									IDI_ICON9
ICON_NUM				equ			($ - offset dwIcons) / 4
ICON_WIDTH				equ			24


.data?
hInstance				dd			?
hWinMain				dd			?
hWndSendTo				dd			?
hWndColor				dd			?
hMenu					dd			?
hAccelerator			dd			?
hWndColorBtns			dd			COLORS_NUM dup(?)




;dBuffer				dd			?
;stHitPoint				POINT		<>
;stLastMovPoint			POINT		<>
;stMovPoint				POINT		<>
;stReleasePoint			POINT		<>
szFileNameBuffer		db			MAX_FILESIZE DUP(?)
stPaint		PAINTINFO	<>
stRegion	PAINTINFO	<>
bInRegion				db			0
stRegPtBegin			POINT		<>
stRegPtEnd				POINT		<>

bRegionMove				db			0
stRegMvPtStart			POINT		<0,0>
stRegMvPtDelta			POINT		<0,0>
hBuffDC					HDC			?
hBuffBitmap				HBITMAP		?
dwBuffWidth				dword		?
dwBuffHeight			dword		?
hWinToolbar				dd			?
.const
szClassName				db			'MyClass',0
szCaptionMain			db			'MyPainter',0
szColorBtnClass			db			'ColorBtn', 0
szColorBoxClass			db			'ColorBox', 0
szToolBtnClass			db			'ToolBtn',0
szToolBoxClass			db			'ToolBox',0

szFilter				db			"BitMap(*.bmp)",0,"*.bmp",0
szOtherBmp				db			".bmp",0
szDefaultSaveFile		db			"1.bmp",0
szDefaultOpenFile		db			".bmp",0
szErrorSuffixNoBmp		db			'������ʽ������bmp��β!',0
szErrorNotRegion			db			'Error! ������ѡ��Region Set',0
szErrorZeroRegion		db			'Error! ����ѡ���д�С��Region',0
stToolbar	equ	this byte
