; Windows Ӧ�ó���           (WinApp.asm)
; ��������ʾһ���ɵ���С��Ӧ�ó��򴰿ںͼ���������Ϣ��
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
; ����Ӧ�ó���Ĵ�����ṹ
MainWin WNDCLASS <NULL,WinProc,NULL,NULL,NULL,NULL,NULL, \
    COLOR_WINDOW,NULL,className>
msg          MSGStruct <>
winRect   RECT <>
hMainWnd  DWORD ?
hInstance DWORD ?
;=================== CODE =========================
.code
WinMain PROC
; ��õ�ǰ���̵ľ��
    INVOKE GetModuleHandle, NULL
    mov hInstance, eax
    mov MainWin.hInstance, eax
; ���س����ͼ��͹��
    INVOKE LoadIcon, NULL, IDI_APPLICATION
    mov MainWin.hIcon, eax
    INVOKE LoadCursor, NULL, IDC_ARROW
    mov MainWin.hCursor, eax
; ע�ᴰ����
    INVOKE RegisterClass, ADDR MainWin
    .IF eax == 0
      call ErrorHandler
      jmp Exit_Program
    .ENDIF
; ����Ӧ�ó����������
    INVOKE CreateWindowEx, 0, ADDR className,
      ADDR WindowName,MAIN_WINDOW_STYLE,
      CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,
      CW_USEDEFAULT,NULL,NULL,hInstance,NULL
    mov hMainWnd,eax
; �� CreateWindowEx ʧ�ܣ�����ʾ��Ϣ���˳�
    .IF eax == 0
      call ErrorHandler
      jmp  Exit_Program
    .ENDIF
; ���洰�ھ������ʾ�����ƴ���
    INVOKE ShowWindow, hMainWnd, SW_SHOW
    INVOKE UpdateWindow, hMainWnd
; ��ʾ��ӭ��Ϣ
    INVOKE MessageBox, hMainWnd, ADDR GreetText,
      ADDR GreetTitle, MB_OK
; ���������������Ϣ����ѭ��
Message_Loop:
    ; �Ӷ�����ȡ����һ����Ϣ
    INVOKE GetMessage, ADDR msg, NULL,NULL,NULL
    ; ��û��������Ϣ���˳�
    .IF eax == 0
      jmp Exit_Program
    .ENDIF
    ; ����Ϣ���ݸ������ WinProc
    INVOKE DispatchMessage, ADDR msg
    jmp Message_Loop
Exit_Program:
      INVOKE ExitProcess,0
WinMain ENDP
;-----------------------------------------------------
WinProc PROC,
    hWnd:DWORD, localMsg:DWORD, wParam:DWORD, lParam:DWORD
; Ӧ�ó������Ϣ������̣�����Ӧ�ó����ض�����Ϣ��
; ����������Ϣ�򴫵ݸ�Ĭ�ϵ� windows ��Ϣ�������
;-----------------------------------------------------
    mov eax, localMsg
    .IF eax == WM_LBUTTONDOWN          ; ��갴ť?
      INVOKE MessageBox, hWnd, ADDR PopupText,
        ADDR PopupTitle, MB_OK
      jmp WinProcExit
    .ELSEIF eax == WM_CREATE           ; ��������?
      INVOKE MessageBox, hWnd, ADDR AppLoadMsgText,
        ADDR AppLoadMsgTitle, MB_OK
      jmp WinProcExit
    .ELSEIF eax == WM_CLOSE            ; �رմ���?
      INVOKE MessageBox, hWnd, ADDR CloseMsg,
        ADDR WindowName, MB_OK
      INVOKE PostQuitMessage,0
      jmp WinProcExit
    .ELSE                              ; ������Ϣ?
      INVOKE DefWindowProc, hWnd, localMsg, wParam, lParam
      jmp WinProcExit
    .ENDIF
WinProcExit:
    ret
WinProc ENDP
;---------------------------------------------------
ErrorHandler PROC
; ��ʾ���ʵ�ϵͳ������Ϣ
;---------------------------------------------------
.data
pErrorMsg  DWORD ?         ; ������Ϣָ��
messageID  DWORD ?
.code
    INVOKE GetLastError    ; ��EAX������ϢID
    mov messageID,eax
    ; ��ȡ��Ӧ����Ϣ�ַ���
    INVOKE FormatMessage, FORMAT_MESSAGE_ALLOCATE_BUFFER + \
      FORMAT_MESSAGE_FROM_SYSTEM,NULL,messageID,NULL,
      ADDR pErrorMsg,NULL,NULL
    ; ��ʾ������Ϣ
    INVOKE MessageBox,NULL, pErrorMsg, ADDR ErrorTitle,
      MB_ICONERROR+MB_OK
    ; �ͷŴ�����Ϣ�ַ���
    INVOKE LocalFree, pErrorMsg
    ret
ErrorHandler ENDP
END WinMain