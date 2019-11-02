PBITMAPINFO       TYPEDEF PTR BITMAPINFO
PBITMAPINFOHEADER TYPEDEF PTR BITMAPINFOHEADER

_SaveScreenToBmp proto _lpRect: ptr RECT, _hWnd: HWND

.const
szDisplay			byte	"DISPLAY",0
.data?
stPointBegin		POINT	<>