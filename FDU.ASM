MODEL TINY
STACK 100h

set_screen_mode macro mode			;��⠭�������� ०�� ࠡ��� � ��࠭��
	mov ah,0
	mov al,mode
	int 10h
endm

set_svga_mode macro mode			;� �� ��� SVGA - ���� �����������?
	mov ax,4f02h
	mov bx,mode
	int 10h
endm

set_position macro row,col			;��⠭�������� ����� � �������� ������
	xor bx,bx
	mov dh,col
	mov dl,row
	mov ah,02h
	int 10h
endm

print macro text,length			;���⠥� ��ப� �������� ����� (�� �ᯮ���� DOS)
local povt
	mov si,offset text
	mov cx,length
	mov ah,0eh

povt:
	lodsb
	int 10h
	loop povt
endm

Print0 macro text				;���⠥� ��ப� ASCIIZ (��� ���, 0 �� �뢮���)
local povt,exit_print				;����祭� ���� - 9 ���-⠪� �뢮�����. ��ࠢ���.
	mov si,offset text
	mov ah,0eh

povt:
	cmp al,0
	je exit_print
	lodsb
	int 10h
	jmp povt
exit_print:
endm

paint macro x1,y1,x2,y2,color		;������ ���ᨪ��᪮�� line (x1,y1) - (x2,y2),color,bf
	mov bh,color
	mov ch,y1
	mov cl,x1
	mov dh,y2
	mov dl,x2
	mov ah,06h
	int 10h
endm

out_ macro symbol,x,y,atr
	set_position x,y
	mov cx,1
	mov bh,0
	mov bl,atr
	mov ah,09
	mov al,symbol
	int 10h
endm

ascii2hex macro ascii,hexA,hexB		;��ॢ���� ��।���� ASCII-��� � ��� hex-���.
local sign,next,sign1,next1
	mov al,ascii
	mov ah,0
	shl ax,4
	shr al,4
	cmp al,0ah
	jb sign
	add al,37h
	jmp next

sign:
	add al,30h

next:
	cmp ah,0ah
	jb sign1
	add ah,37h
	jmp next1

sign1:
	add ah,30h
next1:
	mov hexA,ah
	mov hexB,al
endm
;��� ����� �᭮��� �� ���� Mr. Alf`�

DATASEG

;------------------------------------------------------------------------------

menu1 db  '������������������������ͻ',10,13
      db  '��    � Floppy   ��Ŀ �  �',10,13
      db  '��    � Disk     ���� �  �',10,13
      db  '��    � Utility  ���� �  �',10,13
      db  '��    � Ver 1.0b ���� �  �',10,13
      db  '������������������������˹',10,13
      db  '����������������������Ŀ��',10,13
      db  '���   ������� ��ࠧ    ���',10,13	;item=7
      db  '���   ������� ��ࠧ   ���',10,13
      db  '���   ����� ᥪ��   ���',10,13
      db  '���   ������� ᥪ��  ���',10,13
      db  '���   ��⠭����� 䠩�  ���',10,13	;item=11
      db  '���   ����� ���     ���',10,13	;item=12
      db  '���   ��室            �ۺ',10,13	;item=13
      db  '������������������������ʼ',10,13
      db  '                          ',10,13

;------------------------------------------------------------------------------

item db 7

;------------------------------------------------------------------------------

menu20 db '������������������������ͻ'
menu21 db '� � ��� �������� ����� � �'
menu22 db '� ���������������������� �'
menu23 db '�      IMAGE.IMG         �'
menu24 db '������������������������ͼ'

menu30 db '�������������������ͻ'
menu31 db '� � !  �������  ! � �'
menu32 db '� ���������������´ �'
menu33 db '�                   �'
menu34 db '�������������������ͼ'

menu40 db '������������������ͻ'
menu41 db '� ��������������͵ �'
menu42 db '� � X  ������  X � �'
menu43 db '� ��������������͵ �'
menu44 db '������������������ͼ'

menu50 db '������������������ͻ'
menu51 db '� ��������������͵ �'
menu52 db '� � !  ������  ! � �'
menu53 db '� ��������������͵ �'
menu54 db '������������������ͼ'

menu60 db '����������ͻ'
menu61 db '� ���:� A �'
menu62 db '����������͹'
menu63 db '�    OK    �'
menu64 db '����������ͼ'

menu70 db '����������ͻ'
menu71 db '�TRK�CL�SEC�'
menu72 db '����������͹'
menu73 db '�01 �0 �01 �'
menu74 db '����������ͼ'

;------------------------------------------------------------------------------

a80 db 0h	;��஦��
a2  db 0	;��஭�
a18 db 1h	;�����
sel_ db 0	;������
HB db 0
LB db 0	;�࠭�� �������஢���� �����

;------------------------------------------------------------------------------

;HINTS

hint1 db '������� ��ࠧ ��᪠. ��ࠧ ��࠭���� � 㪠����� 䠩�.',0
hint2 db '������� ��ࠧ �� ���. ��ࠧ ������� �� 㪠������� 䠩��.',0
hint3 db '����� 㪠����� ᥪ��. ��ࠧ ��࠭���� � 㪠����� 䠩�.',0
hint4 db '����� � 㪠����� ᥪ��. ��ࠧ ������� �� 㪠������� 䠩��.',0
hint5 db '��⠭����� ��� ࠡ�祣� 䠩��.',0
hint6 db '����� ࠡ�稩 ��� (���� �� �� �� �� �����).',0
hint7 db '��室 �� �ணࠬ��.',0

;==============================================================================

Nhint1 db '��⠭���� ��஦��. �ᯮ���� ������  �  ��� ���������, Tab ��� �롮�.',0
Nhint2 db '��⠭���� ��஭�. �ᯮ���� ������  �  ��� ���������, Tab ��� �롮�.',0
Nhint3 db '��⠭���� ᥪ��. �ᯮ���� ������  �  ��� ���������, Tab ��� �롮�.',0
Nhint4 db '���� ����� ࠡ�祣� 䠩��. �ᯮ���� � ����� ⮫쪮 �����⨬� ᨬ����!',0
Nhint5 db '����� �ணࠬ�� ᮧ���� ��ࠧ 䫮���-��᪠. �������� ��������.',0
Nhint6 db '����� �ணࠬ�� ����⠭�������� ��ࠧ 䫮���-��᪠. �������� ��������.',0
Nhint7 db '�롥�� ࠡ�稩 ���. ��� �롮� �ᯮ���� ������  � .',0
;------------------------------------------------------------------------------

;error_status db '�� ����⪥ ���饭�� � ���ன��� �ந��諠 �������⭠� �訡��.',0
;no_device db '������ ���ன�⢮ �� �������!',0
;floppy_device db '���ன�⢮ ��।����� ��� 䫮�����',0
;hard_device db '���ன�⢮ ��।����� ��� ���⪨� ���',0
;temp db 0

;------------------------------------------------------------------------------

handle dw 0
counter db 0
prog_bar db 0
Disk db 0
failik db 'image.img',0,0,0,0
OK db 'OK'
nf db 'ERROR!'
Copyright db '(c) ����� ��஢᪨� aka D1 2002-2003.'

;------------------------------------------------------------------------------

;data1 Db 4800h dup (0)	;䫮������=18*512*2 = 4800h

;------------------------------------------------------------------------------

CODESEG
	ASSUME ds:@data,es:@data
start:
	mov ax,@data
	mov ds,ax
	mov es,ax

	Set_screen_mode 0
	call no_cursor
	paint 3,7,22,13,40
	paint 4,7,21,7,23
	set_position 0,0
	print menu1,28*16
	call clear_progress
	call hint
	set_position 28,0
	print menu20,26
	set_position 28,1
	print menu21,26
	set_position 28,2
	print menu22,26
	set_position 28,3
	print menu23,26
	set_position 28,4
	print menu24,26
	call menu
	set_screen_mode 8
	print copyright,38
	mov ah,4Ch
	int 21h

;------------------------------------------------------------------------------
;��楤��� �ᥢ����䨪�, ����, ����ᮢ�� � ��� ⠪��.
;------------------------------------------------------------------------------

repaint proc			;�� �室� � ���� ���� �뤥����� �� ��࠭��� �������
	set_position 0,7
	paint 4,7,22,13,40
	paint 4,item,21,item,23
	print menu1+(7*28),28*9
ret
endp

;------------------------------------------------------------------------------

Menu proc													;���� ����

select:
	xor ax,ax
	int 16h
	cmp ah,1ch
	je vvod_est
	cmp al,0
	je al_0
	jmp select

al_0: 
	cmp ah,50h
	je down_
	cmp ah,48h
	je up_
	jmp select

down_:
	cmp item,13
	jne down_item
	mov item,7
	jmp selected

down_item:
	inc item
	jmp selected

up_: 
	cmp item,7
	jne up_item
	mov item,13
	jmp selected

up_item:
	dec item

selected:				;���ᮢ��� ����
	call repaint
	call hint
	jmp select

vvod_est:
	set_position 0,7
	paint 4,7,22,13,40
	print menu1+(7*28),28*9
	cmp item,7
	je e_7
	cmp item,8
	je e_8
	cmp item,9
	je e_9
	cmp item,10
	je e_10
	cmp item,11
	je e_11
	cmp item,12
	je e_12
	cmp item,13
	je e_13

e_7:
	call make_image
	jmp select

e_8:
	call write_image
	jmp select

e_9:
	call set_sector
	call chist23
	call read_sector
	call repaint
	call hint
	jmp select

e_10:
	call set_sector
	call chist23
	call write_sector
	call repaint
	call hint
	jmp select

e_11:
	call read_name
	jmp select

e_12:
	call set_disk
	jmp select

e_13:
ret
endp

;------------------------------------------------------------------------------

chist23 proc
	set_position 0,23
	call chist_
ret
endp

;------------------------------------------------------------------------------

hint proc		;� ����ᨬ��� �� ��࠭���� ������� ����, �뢮��� ���᪠���
	set_position 0,23
	cmp item,7
	je i_7
	cmp item,8
	je i_8
	cmp item,9
	je i_9
	cmp item,10
	je i_10
	cmp item,11
	je i_11
	cmp item,12
	je i_12
	cmp item,13
	je i_13

i_7:
	print0 hint1
	jmp end_hint

i_8:
	print0 hint2
	jmp end_hint

i_9:
	print0 hint3
	jmp end_hint

i_10:
	print0 hint4
	jmp end_hint

i_11:
	print0 hint5
	jmp end_hint

i_12:
	print0 hint6
	jmp end_hint

i_13:
	print0 hint7

end_hint:
	call chist_
ret
endp

;------------------------------------------------------------------------------

clear_progress proc				;��頥� �ண��ᡠ�, �⢥砥� �� ��� 梥�
	paint 55,0,79,5,3
ret
endp

;------------------------------------------------------------------------------

clear_err proc			;���ࠥ� ᮮ�饭�� �� �訡��, �⢥砥� �� ��� 梥�
	paint 0,15,22,20,4
ret
endp

;------------------------------------------------------------------------------

clear_good proc			;���ࠥ� ᮮ�饭�� �� �ᯥ�, �⢥砥� �� ��� 梥�
	paint 0,15,22,20,2
ret
endp

;------------------------------------------------------------------------------

clear_disk_menu proc			;��頥� ���� �롮� ��᪠, �⢥砥� �� ��� 梥�
	paint 0,15,22,20,9
ret
endp

;------------------------------------------------------------------------------

;clear_1 proc					;��᭠� ��ப�, �᫨ �訡�� �� ��᪥
;	paint 1,17,23,17,4
;ret
;endp

;------------------------------------------------------------------------------

;clear_2 proc					;����� ��ப�, �᫨ ��� �訡��
;	paint 1,17,23,17,2
;ret
;endP

;------------------------------------------------------------------------------


error_mes proc							;�뤠�� ��᭮� ᮮ�饭�� �� �訡��
	;call clear_err
	paint 0,15,22,20,4
	set_position 3,15	
	print menu40,20
	set_position 3,16
	print menu41,20
	set_position 3,17
	print menu42,20
	set_position 3,18
	print menu43,20
	set_position 3,19
	print menu44,20
	xor ax,ax
	int 16h
	call clear_err
ret
endp

;------------------------------------------------------------------------------

ok_mes proc								;�뤠�� ���񭮥 ᮮ�饭�� �� �ᯥ�
	call clear_good
	set_position 3,15
	print menu50,20
	set_position 3,16
	print menu51,20
	set_position 3,17
	print menu52,20
	set_position 3,18
	print menu53,20
	set_position 3,19
	print menu54,20
	xor ax,ax
	int 16h
	call clear_good
ret
endp

;------------------------------------------------------------------------------

progress proc											;����� �ண��ᡠ�
	set_position 56,0
	print menu30,21
	set_position 56,1
	print menu31,21
	set_position 56,2
	print menu32,21
	set_position 56,3
	print menu33,21
	set_position 56,4
	print menu34,21
	mov prog_bar,5
	xor ax,ax
	mov al,counter
	div prog_bar
	mov prog_bar,al
	add prog_bar,58
	paint 58,3,prog_bar,3,30
ret
endp

;------------------------------------------------------------------------------

set_disk proc											;����誠 �롮� ��᪠.
;	call chist23
	set_position 0,23
	print0 Nhint7
	call clear_disk_menu
	set_position 6,15
	print menu60,12
	set_position 6,16
	print menu61,12
	set_position 6,17
	print menu62,12
	set_position 6,18
	print menu63,12
	set_position 6,19
	print menu64,12
	
select_disk:
							;call disk_exists - ��⠢���, ����� �㤥� ��⮢�
	xor ax,ax
	mov al,disk
	push ax
	add disk,41h				;����� ��⨬���஢���
	set_position 15,16
	print disk,1
	pop ax
	mov disk,al

	xor ax,ax
	int 16h
	cmp ah,1ch
	je end_set
	cmp al,0
	je al_Z
	jmp select_disk

al_Z: 
	cmp ah,4bh
	je left_
	cmp ah,4dh
	je right_
	jmp select_disk
	
left_:
	cmp disk,0h
	je disk_z				;�࠭� ��࠭�祭�� �� 10 ��᪮� - ����㯭� �� �㪢�.
	dec disk
	jmp select_disk

disk_z:
	mov disk,19h
	jmp select_disk

right_:		
	cmp disk,19h
	je disk_zero
	inc disk
	jmp select_disk

disk_zero:
	mov disk,0
	jmp select_disk
	
end_set:
	call clear_disk_menu
	call repaint
	call hint
ret
endp

;------------------------------------------------------------------------------

clear_sec_p proc
	paint 0,15,20,20,9
ret
endp

;------------------------------------------------------------------------------

repaint_setting proc
	paint 8,18,10,18,9
	paint 12,18,13,18,9
	paint 15,18,17,18,9
	ascii2hex a80,HB,LB
	out_ HB,8,18,2h
	out_ LB,9,18,2h
	ascii2hex a2,HB,LB
	out_ LB,12,18,2h
	ascii2hex a18,HB,LB
	out_ HB,15,18,2h
	out_ LB,16,18,2h
	set_position 0,23
ret
endp

;------------------------------------------------------------------------------

set_sector proc
	call chist23
	call clear_sec_p
	set_position 7,15
	print menu70,12
	set_position 7,16
	print menu71,12
	set_position 7,17
	print menu72,12
	set_position 7,18
	print menu73,12
	set_position 7,19
	print menu74,12
	
ready_:
	call repaint_setting
	cmp sel_,0
	je s80
	cmp sel_,1
	je s2
	print0 Nhint3
	paint 17,18,17,18,30
	jmp next_pressed

s80:	
	print0 Nhint1
	paint 10,18,10,18,30
	jmp next_pressed

;------------------------
;��室 ���쭥�� ��릪�
reding_:
	jmp ready_

;------------------------

s2:
	print0 Nhint2
	paint 13,18,13,18,30

next_pressed:
	xor ax,ax
	int 16h
	cmp ah,1ch
	jne ruled
	call clear_sec_p
	call repaint
	ret

ruled:
	cmp ah,0fh
	je tabed
	cmp al,0
	jne reding_
	cmp ah,48h
	je up_pressed_
	cmp ah,50h
	je down_pressed_
	jmp ready_

up_pressed_:
	cmp sel_,0
	je i80
	cmp sel_,1
	je i2

i18:
	cmp a18,18
	je zeroa18
	inc a18
	jmp ready_

zeroa18: 
	mov a18,1
	jmp i2
	jmp ready_

i80:
	cmp a80,79
	je zeroa80
	inc a80
	jmp ready_

zeroa80:
	mov a80,0
	jmp ready_

i2:
	cmp a2,1
	je zeroa2
	inc a2
	jmp ready_

zeroa2:
	mov a2,0
	jmp i80
	jmp ready_

;---------------------
;��室 ���쭥�� ��릪�
tabed:
	jmp tab_pressed_
;---------------------

down_pressed_:
	cmp sel_,0
	je i80_
	cmp sel_,1
	je i2_

i18_:
	cmp a18,1
	je ada18
	dec a18
	jmp ready_

ada18:
	mov a18,18
;-------------------------
;some code - ���६��� a2
;	cmp a2,0
;	je deca2
;	dec a2	
;deca2:
;	mov a2,1
;	cmp a80,1
;	je deca80
;	dec a80
;	jmp ready_
;deca80:
;	mov a80,79
;��襭� ���� �� �����
;-------------------------
	jmp ready_

i80_:
	cmp a80,0
	je ada80
	dec a80
	jmp ready_

ada80:
	mov a80,79
	jmp ready_	

i2_:
	cmp a2,0
	je ada2
	dec a2
	jmp ready_

ada2:
	mov a2,1
;some code - ���६��� a80
;���� �襭� �� �����
	jmp ready_

tab_pressed_:
	cmp sel_,2
	je sel2
	inc sel_
	jmp ready_

sel2:
	mov sel_,0
	jmp ready_

exitx_:
ret
endp

;------------------------------------------------------------------------------

chist_ proc					;����� ��ப�. ������ ����� ������� �०���.
	xor bx,bx
	mov ah,03
	int 10h
	push dx
	mov cx,50h
	mov ah,0eh
	mov al,0

chist:
	int 10h
	loop chist
	pop dx
	mov ah,02
	int 10h
ret
endp

;------------------------------------------------------------------------------
;��楤��� ࠡ��� � ��᪮� � 䠫��묨 ��⥬���
;------------------------------------------------------------------------------
;�� ࠡ�⠥�, ��⮬ ������.
;disk_exists proc
;	mov dl,disk
;	mov ah,15h
;	int 13h
;	cmp ah,00
;	je no_disk
;	cmp ah,01			;�������� ࠧ��祭�� ⨯�� 䫮������
;	je floppy
;	cmp ah,02
;	je floppy
;	cmp ah,03
;	je hard
;	set_position 0,22
;	print0 error_status
;	call clear_1
;	set_position 38,8
;	print nf,6
;	jmp exit_proc
;no_disk:
;	set_position 0,22
;	print0 no_device
;
;floppy:
;	set_position 0,22
;	print0 floppy_device
;hard:
;	set_position 0,22
;	print0 hard_device

;exit_proc:
;ret
;endp

;------------------------------------------------------------------------------
;��楤��� ࠡ��� � 䠩����
;------------------------------------------------------------------------------

create_file proc												;������� 䠩�
	mov ah,3ch
	xor cx,cx			;䠩� ��� �����祪!
	mov dx,offset failik
	int 21h
	jnc no_err_create
	call error_mes
	call menu	

no_err_create:
	mov handle,ax
ret
endp

;------------------------------------------------------------------------------

open_file proc											;���뢠�� 䠩�
	mov ax,3d02h			;ࠧ��� ����� ����� � 䠩��
	mov dx,offset failik
	int 21h
	jnc no_err_open
	call error_mes

no_err_open:
	mov handle,ax
ret
endp

;------------------------------------------------------------------------------

close_file proc											;����뢠�� 䠩�
	mov ah,3eh
	mov bx,handle
	int 21h
	jnc no_err_close
	call error_mes
	call menu

No_err_close:
	mov handle,0
ret
endp

;------------------------------------------------------------------------------
;��楤��� ����㯠 � ����
;------------------------------------------------------------------------------

make_image proc									;������� ��ࠧ 䫮���-��᪠
	;call chist23
	set_position 0,23
	print0 Nhint5
	call create_file

count:
	mov ah,02			;function
	mov al,12h			;18 ᥪ�஢ �� ��஦��
	mov ch,counter
	mov cl,1
	mov dl,0
	mov dh,0				;0-1 -��஭�
	mov bx,offset data1			;��ࢠ� �������� ���� - 0 �������
	int 13h				;func
	jc error_r

	mov ah,02
	mov al,12h
	mov ch,counter
	mov cl,1
	mov dl,0
	mov dh,1
	mov bx,offset [data1+2400h]	;���� ��������� ���� - 1 �������.
	int 13h
	jc error_r
	jmp exit

error_r:
	call error_mes		;�� ����� ���� ��᪥��
	jmp crit_err

exit:					;��襬 � 䠩�.
	mov cx,4800h
	mov dx,offset data1
	mov ah,40h
	mov bx,handle
	int 21h
						;����� ��⠢��� ��ࠡ��稪 �訡�� �����
	inc counter
	call progress
	cmp counter,50h
	je conec
	jmp count

vix_osh:
	call error_mes		;ࠧ�� ��� ��� �����-����� �믮������?
	jmp crit_err			;��祬 ��� ��ࠡ��稪� �訡��?.. ��⨬���஢���!

conec:
	call ok_mes

crit_err:
	call close_file				
	mov counter,0
	call clear_progress
	call repaint
	call hint
ret
endp

;------------------------------------------------------------------------------

write_image proc										;������ ��ࠧ� �� ���
;	call chist23
	set_position 0,23
	print0 Nhint6
	call open_file

count_w:
	mov cx,4800h					;�⠥� � ���� �� 䠩��
	mov dx,offset data1
	mov ax,3f00h
	mov bx,handle
	int 21h
	jc error_W					;�訡�� �⥭�� �� 䠩��

	mov ah,03					;function
	mov al,12h					;18 ᥪ�஢ �� ��஦��
	mov ch,counter
	mov cl,1
	mov dl,0
	mov dh,0						;0-1 -��஭�
	mov bx,offset data1			;��ࢠ� �������� ���� - 0 �������
	int 13h						;func
	jc error_w					;�訡�� ����� �� ��᪥��

	mov ah,03
	mov al,12h
	mov ch,counter
	mov cl,1
	mov dl,0						;����� �� �� 㤠����?
	mov dh,1
	mov bx,offset [data1+2400h]	;���� ��������� ���� - 1 �������.
	int 13h
	jc error_w					;�訡�� ����� �� ��᪥��
	inc counter
	call progress
	jmp exit_w

error_w:
	call error_mes
	jmp conec_w

exit_w:
	cmp counter,50h
	je vix_osh_w
	jmp count_w

vix_osh_w:
	call ok_mes

conec_w:
	call close_file
	mov counter,0
	call clear_progress
	call repaint
	call hint
ret
endp

;------------------------------------------------------------------------------

read_sector proc
	mov ah,02			;�⥭��
	mov al,1				;��⠥� ⮫쪮 1 ᥪ��
	mov ch,a80			;����� ��஦��
	mov cl,a18			;����� ᥪ��
	mov dl,0
	mov dh,a2			;����� ��஭� (樫����)
	mov bx,offset data1	;�������ࠤ���� ���� - � ���� �⠥�.
	int 13h				;���頨��
	jc err_read			;�᫨ �訡��
	call create_file
	jmp k_vihodu

err_read:
	call error_mes
	jmp vse_nafig

k_vihodu:
	mov cx,512
	mov dx,offset data1
	mov ah,40h
	mov bx,handle
	int 21h
	jc err_read
	call ok_mes
	call close_file

vse_nafig:
ret
endp

;------------------------------------------------------------------------------

write_sector proc										;�����뢠�� ᥪ��
	call open_file
	mov cx,512h
	mov dx,offset data1
	mov ax,3f00h
	mov bx,handle
	int 21h
	jc not_read					;�訡�� �⥭�� �� 䠩��
	jmp schital_blin		

not_read:
	call error_mes
	jmp nafig_vse

schital_blin:						;ᮢ��蠥� ������ �� ��᪥��
	mov ah,03					;�����
	mov al,1						;1 ᥪ�� 
	mov ch,a80					;����� 樫����
	mov cl,a18					;����� ᥪ��
	mov dl,0						;��� A
	mov dh,a2					;����� ��஭�
	mov bx,offset data1			;�ᯮ��㥬 �� �� ����.
	int 13h						;������
	jc not_read					;�����-� �訡��...
	call ok_mes
	call close_file

nafig_vse:
ret
endp

;------------------------------------------------------------------------------
;����� ��楤���
;------------------------------------------------------------------------------

read_name proc											;���� ����� 䠩��

	call yes_cursor
;	call chist23
	set_position 0,23
	print0 Nhint4
	set_position 35,3
	paint 35,3,46,3,30
	mov di,offset failik
	mov cx,12							;��࠭�祭�� �����

naming:		
	xor ax,ax
	int 16h
;��ࠡ��稪� ���㦭�� ������ - ����� ��⠢��� �㭪樨 ।���஢����
	cmp ah,1ch
	je end_naming
	cmp al,20h
	jbe naming
	stosb
	mov ah,0eh
	int 10h
	loop naming

end_naming:
	cmp cx,12
	je naming
	mov al,0
	stosb
	
no_err:
	call no_cursor
	call repaint
	call hint
ret
endp

;------------------------------------------------------------------------------
;��... �ᯮ���� - �뫨 �����-� ���� �� ����୮� �ᯮ�짮����� ����...

clear_buf proc
	mov cx,4800h
	mov di,offset data1
	mov al,0
	clearing:
	stosb
	loop clearing
ret
endp

;------------------------------------------------------------------------------

no_cursor proc	;����頥� ������� �����, � ᠬ ����� ⮦�.
	mov ch,20h
	mov ah,01h
	int 10h
ret
endp

;------------------------------------------------------------------------------

yes_cursor proc	;ࠧ�蠥� �����
	mov ch,01h
	mov cl,1fh
	mov ah,01h
	int 10h
ret
endp

;------------------------------------------------------------------------------

data1 equ $+10000d		;����� ��ࠧ�� ��襬 ��-�-����� � ������...

end start