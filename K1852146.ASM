DATA	SEGMENT
FILE	DB	'C:\DATA.TXT',0,'$',128 DUP(0),'$'	;读入文件名称缓存，默认文件路径为C:\DATA.TXT
FILEID	DW	?									;文件操作时分配的文件代号
FILEBUF	DB	?									;按字节读取文件内容时的缓存
ARRAY	DW	102,176,147,89,138,72				;工作数据数组，存放每一天的快递量
LEN		EQU	$-ARRAY								;工作数组长度
BASE_S	DW	2200								;基本工资，单位（角）
BASE_Q	DW	100									;基本快递量
AWARD	DW	15									;多余基本快递量的每件快递的奖金（角/件）
AWACOL	DW	000AH								;有利消息主题色
DEDUCT	DW	12									;不足基本快递量的每件快递的扣费（角/件）
DEDCOL	DW	000CH								;不利消息主题色
SALARY	DD	?									;程序计算出的周工资
SCOL	DW	000FH								;中性消息主题色
;------------------------------------工作日缩写及其地址表-----------------------------------
DAY1	DB	13,10,'Mon ','$'
DAY2	DB	13,10,'Tue ','$'
DAY3	DB	13,10,'Wed ','$'
DAY4	DB	13,10,'Thur ','$'
DAY5	DB	13,10,'Fri ','$'
DAY6	DB	13,10,'Sar ','$'
WEEK	DW	OFFSET DAY1,OFFSET DAY2,OFFSET DAY3,OFFSET DAY4,OFFSET DAY5,OFFSET DAY6
;------------------------------------程序信息提示语------------------------------------------
MEG1	DB	13,10,'The salary is: ','$'
MEG2	DB	13,10,'WARNING:The number of input data is more than 6, rest of data will be ignored','$' 
MEG3	DB	13,10,80 DUP('#'),'$'
MEG4	DB	13,10,'#',20 DUP(' '),'Welcome to Salary Calculation Program',21 DUP(' '),'#','$'
MEG5	DB	13,10,'#<press keybord to choose function>',44 DUP(' '),'#'
		DB	13,10,'#[1] input work data',59 DUP(' '),'#'
		DB	13,10,'#[2] read data file',60 DUP(' '),'#'
		DB	13,10,'#[3] show work data',60 DUP(' '),'#'
		DB	13,10,'#[4] calculate and show result',49 DUP(' '),'#'
		DB	13,10,'#[5] quit',70 DUP(' '),'#','$'
MEG6	DB	13,10,'<press any key to continue>','$'
MEG7	DB	13,10,'input illegal','$'
MEG8	DB	13,10,'#',27 DUP(' '),'Quit Program Successful',28 DUP(' '),'#','$'
MEG9	DB	13,10,'read file successful','$'
MEG10	DB	13,10,'now the file name is:','$'
MEG11	DB	13,10,'do you want change? [Y/yes][N/no]-','$'
MEG12	DB	13,10,'please input new file name:','$'
;------------------------------------程序错误提示语------------------------------------------
ERR1	DB	13,10,'ERROR:DIVISION OVERFLOW','$'
ERR2	DB	13,10,'ERROR:PLEASE INPUT DEC NUMBER','$'
ERR3	DB	13,10,'ERROR:INPUT NUMBER OUT OF RANGE(65535)','$'
ERR4	DB	13,10,'ERROR:THE LENGTH OF FILE NAME OUT OF RANGE(128)','$'
ERR5	DB	13,10,'THE ERROR CODE IS:','$'
ERR6	DB	13,10,'ERROR:FAILED TO OPEN FILE','$'
ERR7	DB	13,10,'ERROR:FAILED TO READ FILE','$'
ERR8	DB	13,10,'ERROR:FAILED TO CLOSE FILE','$'
ERR9	DB	13,10,'ERROR:THE INPUT FILE IS ILLEGAL','$'
DATA	ENDS
STACK	SEGMENT STACK 'STACK'
		DW	127 DUP(?)
TOS		DW	?
STACK	ENDS
CODE	SEGMENT
ASSUME	CS:CODE,DS:DATA,SS:STACK
;######################################
;#子程序名：	ERROR
;#子程序功能：	输出错误信息
;#程序输入参数：BX-错误类型
;#				AX-错误码
;#				DEDCOL-不利消息主题色
;######################################
ERROR	PROC	FAR
		JMP		CHOOSE
ERRTAB	DW	ERROR1,ERROR2,ERROR3,ERROR4,ERROR5,ERROR6,ERROR7,ERROR8,ERROR9,ERR_DEFAULT
CHOOSE:	
		DEC		BX
		CMP		BX,0
		JB		ERR_DEFAULT
		CMP		BX,9
		JA		ERR_DEFAULT
		SHL		BX,1
		JMP		WORD PTR CS:ERRTAB[BX]
ERR_DEFAULT:
		JMP		RET_MENU
ERROR1:
		MOV		CX,DEDCOL
		LEA		DX,ERR1
		CALL	COLORS
		JMP		RET_MENU
ERROR2:
		MOV		CX,DEDCOL
		LEA		DX,ERR2
		CALL	COLORS
		JMP		RET_MENU
ERROR3:
		MOV		CX,DEDCOL
		LEA		DX,ERR3
		CALL	COLORS
		JMP		RET_MENU
ERROR4:
		MOV		CX,DEDCOL
		LEA		DX,ERR4
		CALL	COLORS
		JMP		RET_MENU
ERROR5:
		JMP		RET_MENU
ERROR6:
		MOV		BX,AX
		MOV		CX,DEDCOL
		LEA		DX,ERR6
		CALL	COLORS
		MOV		DX,OFFSET ERR5
		CALL	COLORS
		CALL	FAR PTR DISPBXH
		JMP		RET_MENU
ERROR7:
		MOV		BX,AX
		MOV		CX,DEDCOL
		LEA		DX,ERR7
		CALL	COLORS
		MOV		DX,OFFSET ERR5
		CALL	COLORS
		CALL	FAR PTR DISPBXH
		JMP		RET_MENU
ERROR8:
		MOV		BX,AX
		MOV		CX,DEDCOL
		LEA		DX,ERR8
		CALL	COLORS
		MOV		DX,OFFSET ERR5
		CALL	COLORS
		CALL	FAR PTR DISPBXH
		JMP		RET_MENU
ERROR9:
		MOV		CX,DEDCOL
		LEA		DX,ERR9
		CALL	COLORS
		JMP		RET_MENU
RET_MENU:	
		LEA		SP,TOS
		SUB		SP,12
		JMP		WAITKEY
		RET
ERROR	ENDP
;######################################
;#子程序名：	DISPBXH
;#子程序功能：	打印有颜色的十六进制数
;#程序输入参数：BX-无符号二进制数
;#				CL-输出颜色
;######################################
DISPBXH 	PROC 	FAR
		PUSH 	AX
		PUSH 	BX
		PUSH 	CX
		PUSH 	DX
		PUSH	DI
		MOV		DI,CX
        MOV 	CH,4
        MOV 	CL,4
DISPBXH_ROTATE: 	
		ROL 	BX,CL
        MOV 	AL,BL
        AND 	AL,0FH
        ADD 	AL,30H
        CMP 	AL,3AH
        JL 		DISPBXH_PRINTCHAR
        ADD 	AL,7
DISPBXH_PRINTCHAR:
		MOV		BX,DI
		CALL	FAR PTR COLORW	
        DEC 	CH
        JNZ 	DISPBXH_ROTATE
		MOV		AL,'h'
		MOV		BX,DI
		CALL	FAR PTR COLORW
		POP		DI
		POP 	DX
		POP 	CX
		POP 	BX
		POP 	AX
        RET
DISPBXH ENDP
;######################################
;#子程序名：	DISPBXD
;#子程序功能：	打印有颜色的十进制数
;#程序输入参数：BX-无符号二进制数
;#				CL-输出颜色
;######################################
DISPBXD	PROC	FAR
		PUSH 	AX
		PUSH 	BX
		PUSH 	CX
		PUSH 	DX
		PUSH	DI
		MOV		DI,CX
		MOV		AX,BX
		MOV 	CX,0
		MOV 	BX,10
DISPBXD_DIV:	
		MOV 	DX,0
		CMP 	AX,0
		JZ 		DISPBXD_DISP0
		DIV 	BX
		PUSH 	DX
		INC 	CX
		JMP 	DISPBXD_DIV
DISPBXD_DISP0:	
		CMP 	CX,0
		JNZ 	DISPBXD_DISP1

		MOV		AL,'0'
		MOV		BX,DI
		CALL	FAR PTR COLORW

		JMP 	DISPBXD_RET
DISPBXD_DISP1:
		CMP 	CX,0
		JZ 		DISPBXD_RET
		POP 	DX

		ADD		DL,'0'
		MOV		AL,DL
		MOV		BX,DI
		CALL	FAR PTR COLORW

		DEC 	CX
		JMP 	DISPBXD_DISP1
DISPBXD_RET:
		POP		DI
		POP 	DX
		POP 	CX
		POP 	BX
		POP 	AX
		RET
DISPBXD ENDP
;######################################
;#子程序名：	COLORW
;#子程序功能：	打印有颜色的字符
;#程序输入参数：AL-输出字符的ASCII码
;#				BL-输出颜色
;######################################
COLORW	PROC	FAR
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		MOV		CX,1
		MOV		AH,09H
		MOV		BH,0
		INT		10H
		MOV		AH,3
		INT		10H
		MOV		AH,2
		INC		DL
		INT		10H
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		RET
COLORW	ENDP
;######################################
;#子程序名：	COLORS
;#子程序功能：	打印有颜色的字符串
;#程序输入参数：CL-输出颜色
;#				DX-输出字符串所在数据段首地址
;######################################
COLORS	PROC
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		PUSH	BP
		PUSH	SI

		MOV		BP,DX
		MOV		SI,0
		MOV		BL,CL
COLORS_WHILE:
		MOV		AL,DS:[BP+SI]
		CMP		AL,'$'
		JZ		COLORS_END
		CMP		AL,13
		JZ		COLORS_ELSE
		CMP		AL,10
		JZ		COLORS_ELSE
		CALL	COLORW
		INC		SI
		JMP		COLORS_WHILE
COLORS_ELSE:
		MOV		AH,2
		MOV		DL,AL
		INT		21H
		INC		SI
		JMP		COLORS_WHILE
COLORS_END:
		POP		SI
		POP		BP
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		RET
COLORS	ENDP
;######################################
;#子程序名：	CAL
;#子程序功能：	计算周工资
;#程序输入参数：ARRAY、LEN、BASE_S、BASE_Q、AWARD、DEDUCT
;#程序输出参数：SALARY
;######################################
CAL	PROC	FAR
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI	

		MOV		AX,BASE_S
		MOV		BX,LEN
		SHR		BX,1
		MUL		BX

		MOV		BX,AX
		MOV		CX,DX
		MOV		SI,0
		JMP		CAL_CONDITION
CAL_FOR:
		MOV		DX,BASE_Q
		CMP		ARRAY[SI],DX
		JA		CAL_THEN
		JB		CAL_ELSE
		JMP		CAL_FOREND
CAL_THEN:
		MOV		AX,ARRAY[SI]
		SUB		AX,BASE_Q
		MOV		DX,0
		MUL		AWARD
		ADD		BX,AX
		ADC		CX,DX
		JMP		CAL_FOREND
CAL_ELSE:
		MOV		AX,BASE_Q
		SUB		AX,ARRAY[SI]
		MOV		DX,0
		MUL		DEDUCT
		SUB		BX,AX
		SBB		CX,DX
		JMP		CAL_FOREND
CAL_FOREND:
		ADD		SI,2
CAL_CONDITION:
		CMP		SI,LEN
		JB		CAL_FOR
	
		MOV		WORD PTR SALARY,BX
		MOV		WORD PTR SALARY+2,CX

		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		RET
CAL	ENDP
;######################################
;#子程序名：	DISPS
;#子程序功能：	用中性消息主题色打印周工资 （单位：元）
;#程序输入参数：SALARY、SCOL
;######################################
DISPS	PROC	FAR
		PUSH 	AX
		PUSH 	BX
		PUSH	CX
		PUSH 	DX
	
		LEA		DX,MEG1
		MOV		AH,09H
		INT		21H

		MOV		AX,WORD PTR SALARY
		MOV		DX,WORD PTR SALARY+2
		MOV 	BX,10
		MOV		CX,0
	
		CMP		DX,BX
		JAE		DISP_ERROR1
		JMP		DISP_ERROR1_END
DISP_ERROR1:
		MOV		BX,1
		CALL	ERROR
DISP_ERROR1_END:
		DIV		BX
		PUSH	DX
		INC		CX

DISPS_DIV:
		MOV		DX,0
		CMP 	AX,0
		JZ		DISPS_DISP0
		DIV 	BX
		JC		DISP_ERROR2
		JMP		DISP_ERROR2_END
DISP_ERROR2:
		MOV		BX,1
		CALL	ERROR
DISP_ERROR2_END:
		PUSH 	DX
		INC 	CX
		JMP 	DISPS_DIV
DISPS_DISP0:	
		CMP 	CX,1
		JNZ 	DISPS_DISP1

		MOV		AL,'0'
		MOV		BX,SCOL
		CALL	COLORW
	
		MOV		AL,'.'
		MOV		BX,SCOL
		CALL	COLORW

		POP 	DX
		DEC		CX

		ADD		DL,'0'
		MOV		AL,DL
		MOV		BX,SCOL
		CALL	COLORW

		JMP 	DISPS_RET
DISPS_DISP1:
		CMP 	CX,1
		JZ 		DISPS_POINT
		POP 	DX
		DEC		CX

		ADD		DL,'0'
		MOV		AL,DL
		MOV		BX,SCOL
		CALL	COLORW

		JMP 	DISPS_DISP1
DISPS_POINT:
		MOV		AL,'.'
		MOV		BX,SCOL
		CALL	COLORW

		POP 	DX
		DEC		CX

		ADD		DL,'0'
		MOV		AL,DL
		MOV		BX,SCOL
		CALL	COLORW
DISPS_RET:	
		POP 	DX
		POP		CX
		POP 	BX
		POP 	AX
		RET
DISPS	ENDP
;######################################
;#子程序名：	INPUT
;#子程序功能：	输入每天快递量
;#程序输出参数：WEEK
;#程序输出参数：ARRAY
;######################################
INPUT	PROC	FAR
		PUSH	AX
		PUSH	BX
		PUSH	DX
		PUSH	SI

		MOV		AX,0100H
		MOV		SI,0
		MOV		BX,10
		MOV		DX,0

		PUSH	AX
		PUSH	DX
		MOV		DX,WEEK[SI]
		MOV		AH,09H
		INT		21H
		POP		DX
		POP		AX
INPUT_WHILE:
		INT		21H
		CMP		AL,13
		JZ		INPUT_THEN
		CMP		AL,20H
		JZ		INPUT_THEN
		CMP		AL,'0'
		JB		INPUT_ERROR1
		JMP		INPUT_ERROR1_END
INPUT_ERROR1:
		MOV		BX,2
		CALL	ERROR
INPUT_ERROR1_END:
		CMP		AL,'9'
		JA		INPUT_ERROR2
		JMP		INPUT_ERROR2_END
INPUT_ERROR2:
		MOV		BX,2
		CALL	ERROR
INPUT_ERROR2_END:
		PUSH	AX
		MOV		AX,DX
		MUL		BX
		CMP		DX,0
		JNE		INPUT_ERROR3
		JMP		INPUT_ERROR3_END
INPUT_ERROR3:
		MOV		BX,3
		CALL	ERROR
INPUT_ERROR3_END:
		MOV		DX,AX	
		POP		AX
		PUSH	AX
		SUB		AL,'0'
		CBW
		ADD		DX,AX
		JC		INPUT_ERROR4
		JMP		INPUT_ERROR4_END
INPUT_ERROR4:
		MOV		BX,3
		CALL	ERROR
INPUT_ERROR4_END:
		POP		AX
		JMP		INPUT_WHILE
INPUT_THEN:
		MOV		ARRAY[SI],DX
		MOV		DX,0
		ADD		SI,2
		CMP		SI,LEN
		JAE		INPUT_WHILEEND
		PUSH	AX
		PUSH	DX
		MOV		DX,WEEK[SI]
		MOV		AH,09H
		INT		21H
		POP		DX
		POP		AX
		JMP		INPUT_WHILE
INPUT_WHILEEND:
		POP		SI
		POP		DX
		POP		BX
		POP		AX	
		RET
INPUT	ENDP
;######################################
;#子程序名：	READF
;#子程序功能：	从文件中读入每天快递量
;#程序输入参数:	FILE、LEN
;#程序输出参数：ARRAY
;######################################
READF	PROC	FAR
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI

		LEA		DX,FILE
		MOV		AX,3D00H
		INT		21H
		JC		FILE_ERROR1
		JMP		FILE_ERROR1_END
FILE_ERROR1:
		MOV		BX,6
		CALL	ERROR
FILE_ERROR1_END:
		MOV		FILEID,AX

		MOV		SI,0
		MOV		BX,10
		MOV		DX,0
READ_WHILE:
		PUSH	BX
		PUSH	CX
		PUSH	DX
		MOV		AH,3FH
		LEA		DX,FILEBUF
		MOV		BX,FILEID
		MOV		CX,1
		INT		21H
		POP		DX
		POP		CX
		POP		BX
		JC		FILE_ERROR2
		JMP		FILE_ERROR2_END
FILE_ERROR2:
		MOV		BX,7
		CALL	ERROR
FILE_ERROR2_END:
		CMP		AX,0
		JZ		END_OF_FILE

		MOV		AL,FILEBUF
		CMP		AL,13
		JZ		READ_THEN
		CMP		AL,20H
		JZ		READ_THEN
		CMP		AL,'0'
		JB		FILE_ERROR3
		JMP		FILE_ERROR3_END
FILE_ERROR3:
		MOV		BX,2
		CALL	ERROR
FILE_ERROR3_END:
		CMP		AL,'9'
		JA		FILE_ERROR4
		JMP		FILE_ERROR4_END
FILE_ERROR4:
		MOV		BX,2
		CALL	ERROR
FILE_ERROR4_END:
		PUSH	AX
		MOV		AX,DX
		MUL		BX
		CMP		DX,0
		JNZ		FILE_ERROR5
		JMP		FILE_ERROR5_END
FILE_ERROR5:
		MOV		BX,3
		CALL	ERROR
FILE_ERROR5_END:
		MOV		DX,AX
		POP		AX
		PUSH	AX
		SUB		AL,'0'
		CBW
		ADD		DX,AX
		JC		FILE_ERROR6
		JMP		FILE_ERROR6_END
FILE_ERROR6:
		MOV		BX,3
		CALL	ERROR
FILE_ERROR6_END:
		POP		AX
		JMP		READ_WHILE
READ_THEN:
		MOV		ARRAY[SI],DX
		MOV		DX,0
		ADD		SI,2
		CMP		SI,LEN
		JAE		READ_WHILEEND
		JMP		READ_WHILE
END_OF_FILE:
		MOV		ARRAY[SI],DX
		MOV		DX,0
		ADD		SI,2
		CMP		SI,LEN
		JZ		END_READ
		MOV		BX,9
		CALL	ERROR
READ_WHILEEND:
		MOV		DX,OFFSET MEG2
		MOV		AH,09H
		INT		21H
		JMP		END_READ
END_READ:
		MOV		BX,FILEID
		MOV		AH,3EH
		INT 	21H
		JC		FILE_ERROR7
		JMP		FILE_ERROR7_END
FILE_ERROR7:
		MOV		BX,8
		CALL	ERROR
FILE_ERROR7_END:
		MOV		FILEID,0

		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		RET
READF	ENDP
;######################################
;#子程序名：	SETF
;#子程序功能：	设置文件名
;#程序输出参数:	FILE
;######################################
SETF	PROC	FAR
		PUSH	AX
		PUSH	BX
		PUSH	DX
		LEA		DX,MEG12
		MOV		AH,09H
		INT		21H
		MOV		BX,0
		MOV		AX,0100H
SETF_WHILE:
		INT		21H
		CMP		AL,13
		JZ		SETF_END
		MOV		FILE[BX],AL
		INC		BX
		CMP		BX,128
		JBE		SETF_WHILE
		MOV		BX,4
		CALL	ERROR
SETF_END:
		MOV		FILE[BX],0
		INC		BX
		MOV		FILE[BX],'$'
		INC		BX
		POP		DX
		POP		BX
		POP		AX
		RET
SETF	ENDP
;######################################
;#子程序名：	SHOWDATA
;#子程序功能：	打印每天的快递量，高于基准量用有利消息主题色打印，低于用不利消息主题色打印
;#程序输入参数:	SALARY、AWACOL、DEDCOL
;######################################
SHOWDATA PROC	FAR
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		MOV		SI,0
		JMP		SHOWDATA_CONDITION
SHOWDATA_WHILE:
		PUSH	AX
		PUSH	DX
		MOV		DX,WEEK[SI]
		MOV		AH,09H
		INT		21H
		POP		DX
		POP		AX
		MOV		BX,ARRAY[SI]
		CMP		BX,BASE_Q
		JA		SHOWDATA_THEN
		JB		SHOWDATA_ELSE
		MOV		CX,SCOL
		JMP		SHOWDATA_ENDIF
SHOWDATA_THEN:
		MOV		CX,AWACOL
		JMP		SHOWDATA_ENDIF
SHOWDATA_ELSE:
		MOV		CX,DEDCOL
		JMP		SHOWDATA_ENDIF
		MOV		CH,0
		MOV		CX,SCOL
SHOWDATA_ENDIF:
		CALL	DISPBXD
		ADD		SI,2
SHOWDATA_CONDITION:
		CMP		SI,LEN
		JB		SHOWDATA_WHILE
		POP		SI
		POP		DX
		POP		CX
		POP		BX
		POP		AX	
		RET
SHOWDATA ENDP
;######################################
;#子程序名：	MENU
;#子程序功能：	打印主菜单，并根据输入调用相关子程序
;######################################
MENU	PROC	FAR
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		
		JMP		MENU_WHILE
CASETAB	DW	CASE1,CASE2,CASE3,CASE4,CASE5
MENU_WHILE:
		LEA		DX,MEG3
		MOV		CX,001FH
		CALL	COLORS
		LEA		DX,MEG4
		MOV		CX,001FH
		CALL	COLORS
		LEA		DX,MEG3
		MOV		CX,001FH
		CALL	COLORS
		
		LEA		DX,MEG3
		MOV		CX,001AH
		CALL	COLORS
		LEA		DX,MEG5
		MOV		CX,001AH
		CALL	COLORS
		LEA		DX,MEG3
		MOV		CX,001AH
		CALL	COLORS

		MOV		AH,02H
		MOV		DL,13
		INT		21H
		MOV		AH,02H
		MOV		DL,10
		INT		21H
		MOV		AX,0700H
		INT		21H
		CBW
		MOV		BX,AX
		CMP		BX,'1'
		JB		DEFAULT
		CMP		BX,'5'
		JA		DEFAULT
		SUB		BX,'1'
		SHL		BX,1
		JMP		WORD PTR CS:CASETAB[BX]
CASE1:	
		CALL	INPUT
		JMP		WAITKEY
CASE2:
		LEA		DX,MEG10
		MOV		AH,09H
		INT		21H
		LEA		DX,FILE
		MOV		AH,09H
		INT		21H
		LEA		DX,MEG11
		MOV		AH,09H
		INT		21H
		
		MOV		AX,0100H
		INT		21H
		CMP		AL,'y'
		JZ		CASE2_IN
		CMP		AL,'n'
		JZ		CASE2_READ
		JMP		DEFAULT
CASE2_IN:
		CALL	SETF
CASE2_READ:
		CALL	READF
		LEA		DX,MEG9
		MOV		AH,09H
		INT		21H
		JMP		WAITKEY
CASE3:
		CALL	SHOWDATA
		JMP		WAITKEY
CASE4:
		CALL	CAL
		CALL	DISPS
		JMP		WAITKEY
CASE5:	
		JMP		END_MENU
DEFAULT:
		LEA		DX,MEG7
		MOV		AH,09H
		INT		21H
		JMP		WAITKEY
WAITKEY:
		LEA		DX,MEG6
		MOV		CX,0087H
		CALL	COLORS
		MOV		AH,02H
		MOV		DL,13
		INT		21H
		MOV		AH,02H
		MOV		DL,10
		INT		21H
		MOV		AX,0100H
		INT		21H

		MOV		AH,0FH
		INT		10H
		MOV		AH,00H
		INT		10H

		JMP	MENU_WHILE
END_MENU:
		POP		DX
		POP		CX
		POP		BX
		POP		AX
		RET
MENU	ENDP
;######################################
;#子程序名：	主程序
;#子程序功能：	完成段寄存器的设置，进入主循环，返回DOS
;######################################
MAIN:	
		MOV		AX,DATA
		MOV		DS,AX
		MOV		AX,STACK
		MOV		SS,AX
		LEA		SP,TOS	

		MOV		AH,0FH
		INT		10H
		MOV		AH,00H
		INT		10H

		CALL	MENU

		MOV		AH,0FH
		INT		10H
		MOV		AH,00H
		INT		10H

		LEA		DX,MEG3
		MOV		CX,001FH
		CALL	COLORS
		LEA		DX,MEG8
		MOV		CX,001FH
		CALL	COLORS
		LEA		DX,MEG3
		MOV		CX,001FH
		CALL	COLORS
RETDOS:
		MOV		AX,4C00H
		INT		21H		
CODE	ENDS
		END	MAIN