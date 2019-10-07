; Windows 应用程序           (WinApp.asm)
; 本程序显示一个可调大小的应用程序窗口和几个弹出消息框
.386
INCLUDE Irvine32.inc
INCLUDE GraphWin.inc
;==================== DATA =======================
.data
AppLoadMsgTitle BYTE "Application Loaded",0
AppLoadMsgText  BYTE "This window displays when the WM_CREATE "
                BYTE "message is received",0
PopupTitle BYTE "Popup Window",0
PopupText  BYTE "This window was activated by a "
           BYTE "WM_LBUTTONDOWN message",0
GreetTitle BYTE "Main Window Active",0
GreetText  BYTE "This window is shown immediately after "
           BYTE "CreateWindow and UpdateWindow are called.",0
CloseMsg   BYTE "WM_CLOSE message received",0
ErrorTitle  BYTE "Error",0
WindowName  BYTE "ASM Windows App",0
className   BYTE "ASMWin",0
; 定义应用程序的窗口类结构
MainWin WNDCLASS <NULL,WinProc,NULL,NULL,NULL,NULL,NULL, \
    COLOR_WINDOW,NULL,className>
msg          MSGStruct <>
winRect   RECT <>
hMainWnd  DWORD ?
hInstance DWORD ?
;=================== CODE =========================
.code
WinMain PROC
; 获得当前过程的句柄
    INVOKE GetModuleHandle, NULL
    mov hInstance, eax
    mov MainWin.hInstance, eax
; 加载程序的图标和光标
    INVOKE LoadIcon, NULL, IDI_APPLICATION
    mov MainWin.hIcon, eax
    INVOKE LoadCursor, NULL, IDC_ARROW
    mov MainWin.hCursor, eax
; 注册窗口类
    INVOKE RegisterClass, ADDR MainWin
    .IF eax == 0
      call ErrorHandler
      jmp Exit_Program
    .ENDIF
; 创建应用程序的主窗口
    INVOKE CreateWindowEx, 0, ADDR className,
      ADDR WindowName,MAIN_WINDOW_STYLE,
      CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,
      CW_USEDEFAULT,NULL,NULL,hInstance,NULL
    mov hMainWnd,eax
; 若 CreateWindowEx 失败，则显示消息并退出
    .IF eax == 0
      call ErrorHandler
      jmp  Exit_Program
    .ENDIF
; 保存窗口句柄，显示并绘制窗口
    INVOKE ShowWindow, hMainWnd, SW_SHOW
    INVOKE UpdateWindow, hMainWnd
; 显示欢迎消息
    INVOKE MessageBox, hMainWnd, ADDR GreetText,
      ADDR GreetTitle, MB_OK
; 启动程序的连续消息处理循环
Message_Loop:
    ; 从队列中取出下一条消息
    INVOKE GetMessage, ADDR msg, NULL,NULL,NULL
    ; 若没有其他消息则退出
    .IF eax == 0
      jmp Exit_Program
    .ENDIF
    ; 将消息传递给程序的 WinProc
    INVOKE DispatchMessage, ADDR msg
    jmp Message_Loop
Exit_Program:
      INVOKE ExitProcess,0
WinMain ENDP
;-----------------------------------------------------
WinProc PROC,
    hWnd:DWORD, localMsg:DWORD, wParam:DWORD, lParam:DWORD
; 应用程序的消息处理过程，处理应用程序特定的消息。
; 其他所有消息则传递给默认的 windows 消息处理过程
;-----------------------------------------------------
    mov eax, localMsg
    .IF eax == WM_LBUTTONDOWN          ; 鼠标按钮?
      INVOKE MessageBox, hWnd, ADDR PopupText,
        ADDR PopupTitle, MB_OK
      jmp WinProcExit
    .ELSEIF eax == WM_CREATE           ; 创建窗口?
      INVOKE MessageBox, hWnd, ADDR AppLoadMsgText,
        ADDR AppLoadMsgTitle, MB_OK
      jmp WinProcExit
    .ELSEIF eax == WM_CLOSE            ; 关闭窗口?
      INVOKE MessageBox, hWnd, ADDR CloseMsg,
        ADDR WindowName, MB_OK
      INVOKE PostQuitMessage,0
      jmp WinProcExit
    .ELSE                              ; 其他消息?
      INVOKE DefWindowProc, hWnd, localMsg, wParam, lParam
      jmp WinProcExit
    .ENDIF
WinProcExit:
    ret
WinProc ENDP
;---------------------------------------------------
ErrorHandler PROC
; 显示合适的系统错误消息
;---------------------------------------------------
.data
pErrorMsg  DWORD ?         ; 错误消息指针
messageID  DWORD ?
.code
    INVOKE GetLastError    ; 用EAX返回消息ID
    mov messageID,eax
    ; 获取相应的消息字符串
    INVOKE FormatMessage, FORMAT_MESSAGE_ALLOCATE_BUFFER + \
      FORMAT_MESSAGE_FROM_SYSTEM,NULL,messageID,NULL,
      ADDR pErrorMsg,NULL,NULL
    ; 显示错误消息
    INVOKE MessageBox,NULL, pErrorMsg, ADDR ErrorTitle,
      MB_ICONERROR+MB_OK
    ; 释放错误消息字符串
    INVOKE LocalFree, pErrorMsg
    ret
ErrorHandler ENDP
END WinMain