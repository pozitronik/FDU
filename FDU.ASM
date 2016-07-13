MODEL TINY
STACK 100h

set_screen_mode macro mode			;устанавливает режим работы с экраном
	mov ah,0
	mov al,mode
	int 10h
endm

set_svga_mode macro mode			;то же для SVGA - вдруг понадобится?
	mov ax,4f02h
	mov bx,mode
	int 10h
endm

set_position macro row,col			;устанавливает курсор в заданную позицию
	xor bx,bx
	mov dh,col
	mov dl,row
	mov ah,02h
	int 10h
endm

print macro text,length			;Печатает строку заданной длины (не используя DOS)
local povt
	mov si,offset text
	mov cx,length
	mov ah,0eh

povt:
	lodsb
	int 10h
	loop povt
endm

Print0 macro text				;Печатает строку ASCIIZ (без доса, 0 не выводим)
local povt,exit_print				;Замечена бага - 9 всё-таки выводится. Исправить.
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

paint macro x1,y1,x2,y2,color		;аналог бейсиковского line (x1,y1) - (x2,y2),color,bf
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

ascii2hex macro ascii,hexA,hexB		;переводит переданный ASCII-код в его hex-форму.
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
;Этот макрос основан на коде Mr. Alf`а

DATASEG

;------------------------------------------------------------------------------

menu1 db  '╔╥────╥═══════════════╥══╗',10,13
      db  '║║    ║ Floppy   ┌──┐ ║  ║',10,13
      db  '║║    ║ Disk     │▓▓│ ║  ║',10,13
      db  '║║    ║ Utility  │▓▓│ ║  ║',10,13
      db  '║║    ║ Ver 1.0b └──┘ ║  ║',10,13
      db  '║╠════╩═══════════════╩═╦╣',10,13
      db  '║║┌────────────────────┐║║',10,13
      db  '║║│   Создать образ    │║║',10,13	;item=7
      db  '║║│   Записать образ   │║║',10,13
      db  '║║│   Считать сектор   │║║',10,13
      db  '║║│   Записать сектор  │║║',10,13
      db  '║║│   Установить файл  │║║',10,13	;item=11
      db  '║║│   Выбрать диск     │║║',10,13	;item=12
      db  '║║│   Выход            │█║',10,13	;item=13
      db  '╚╩┴────────────────────┴╩╝',10,13
      db  '                          ',10,13

;------------------------------------------------------------------------------

item db 7

;------------------------------------------------------------------------------

menu20 db '╔═╤════════════════════╤═╗'
menu21 db '║ │ ИМЯ РАБОЧЕГО ФАЙЛА │ ║'
menu22 db '║ └────────────────────┘ ║'
menu23 db '║      IMAGE.IMG         ║'
menu24 db '╚════════════════════════╝'

menu30 db '╔═╤═══════════════╤═╗'
menu31 db '║ │ !  РАБОТАЮ  ! │ ║'
menu32 db '║ ├┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┤ ║'
menu33 db '║                   ║'
menu34 db '╚═╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧═╝'

menu40 db '╔═╤══════════════╤═╗'
menu41 db '║ ╞══════════════╡ ║'
menu42 db '║ │ X  ОШИБКА  X │ ║'
menu43 db '║ ╞══════════════╡ ║'
menu44 db '╚═╧══════════════╧═╝'

menu50 db '╔═╤══════════════╤═╗'
menu51 db '║ ╞══════════════╡ ║'
menu52 db '║ │ !  ГОТОВО  ! │ ║'
menu53 db '║ ╞══════════════╡ ║'
menu54 db '╚═╧══════════════╧═╝'

menu60 db '╔══════╤═╤═╗'
menu61 db '║ Диск:├ A ╢'
menu62 db '╠══════╧═╧═╣'
menu63 db '║    OK    ║'
menu64 db '╚══════════╝'

menu70 db '╔═══╦══╦═══╗'
menu71 db '║TRK║CL║SEC║'
menu72 db '╠╤╤═╬╤═╬╤╤═╣'
menu73 db '║01 ║0 ║01 ║'
menu74 db '╚╧╧═╩╧═╩╧╧═╝'

;------------------------------------------------------------------------------

a80 db 0h	;Дорожка
a2  db 0	;Сторона
a18 db 1h	;Сектор
sel_ db 0	;Позиция
HB db 0
LB db 0	;Хранят конвертированные байты

;------------------------------------------------------------------------------

;HINTS

hint1 db 'Создать образ диска. Образ сохраняется в указанный файл.',0
hint2 db 'Записать образ на диск. Образ берётся из указанного файла.',0
hint3 db 'Читать указанный сектор. Образ сохраняется в указанный файл.',0
hint4 db 'Писать в указанный сектор. Образ берётся из указанного файла.',0
hint5 db 'Установить имя рабочего файла.',0
hint6 db 'Выбрать рабочий диск (пока ни на что не влияет).',0
hint7 db 'Выход из программы.',0

;==============================================================================

Nhint1 db 'Установка дорожки. Используйте клавиши  и  для изменения, Tab для выбора.',0
Nhint2 db 'Установка стороны. Используйте клавиши  и  для изменения, Tab для выбора.',0
Nhint3 db 'Установка сектора. Используйте клавиши  и  для изменения, Tab для выбора.',0
Nhint4 db 'Ввод имени рабочего файла. Используйте в имени только допустимые символы!',0
Nhint5 db 'Сейчас программа создаёт образ флоппи-диска. Пожалуйста подождите.',0
Nhint6 db 'Сейчас программа восстанавливает образ флоппи-диска. Пожалуйста подождите.',0
Nhint7 db 'Выберите рабочий диск. Для выбора используйте клавиши  и .',0
;------------------------------------------------------------------------------

;error_status db 'При попытке обращения к устройству произошла неизвестная ошибка.',0
;no_device db 'Данное устройство не существует!',0
;floppy_device db 'Устройство определено как флоповод',0
;hard_device db 'Устройство определено как жёсткий диск',0
;temp db 0

;------------------------------------------------------------------------------

handle dw 0
counter db 0
prog_bar db 0
Disk db 0
failik db 'image.img',0,0,0,0
OK db 'OK'
nf db 'ERROR!'
Copyright db '(c) Павел Дубровский aka D1 2002-2003.'

;------------------------------------------------------------------------------

;data1 Db 4800h dup (0)	;флопобуфер=18*512*2 = 4800h

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
;Процедуры псевдографики, меню, перерисовки и всё такое.
;------------------------------------------------------------------------------

repaint proc			;При входе в меню рисует выделение на выбранном элементе
	set_position 0,7
	paint 4,7,22,13,40
	paint 4,item,21,item,23
	print menu1+(7*28),28*9
ret
endp

;------------------------------------------------------------------------------

Menu proc													;Само меню

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

selected:				;нарисовать меню
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

hint proc		;В зависимости от выбранного элемента меню, выводит подсказку
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

clear_progress proc				;Очищает прогрессбар, отвечает за его цвет
	paint 55,0,79,5,3
ret
endp

;------------------------------------------------------------------------------

clear_err proc			;Затирает сообщение об ошибке, отвечает за его цвет
	paint 0,15,22,20,4
ret
endp

;------------------------------------------------------------------------------

clear_good proc			;Затирает сообщение об успехе, отвечает за его цвет
	paint 0,15,22,20,2
ret
endp

;------------------------------------------------------------------------------

clear_disk_menu proc			;Очищает меню выбора диска, отвечает за его цвет
	paint 0,15,22,20,9
ret
endp

;------------------------------------------------------------------------------

;clear_1 proc					;Красная строка, если ошибка на диске
;	paint 1,17,23,17,4
;ret
;endp

;------------------------------------------------------------------------------

;clear_2 proc					;Зелёная строка, если нет ошибки
;	paint 1,17,23,17,2
;ret
;endP

;------------------------------------------------------------------------------


error_mes proc							;Выдаёт красное сообщение об ошибке
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

ok_mes proc								;выдаёт зелёное сообщение об успехе
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

progress proc											;Рисует прогрессбар
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

set_disk proc											;Менюшка выбора диска.
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
							;call disk_exists - вставить, когда будет готово
	xor ax,ax
	mov al,disk
	push ax
	add disk,41h				;Можно оптимизировать
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
	je disk_z				;убрано ограничение на 10 дисков - доступны все буквы.
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
;Обход дальнего прыжка
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
;Обход дальнего прыжка
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
;some code - декремент a2
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
;Решено пока не писать
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
;some code - декремент a80
;Пока решено не писать
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

chist_ proc					;Чистит строку. Позиция курсора остаётся прежней.
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
;Процедуры работы с диском и фаловыми системами
;------------------------------------------------------------------------------
;Не работает, потом допишу.
;disk_exists proc
;	mov dl,disk
;	mov ah,15h
;	int 13h
;	cmp ah,00
;	je no_disk
;	cmp ah,01			;Возможно различение типов флоппиков
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
;Процедуры работы с файлами
;------------------------------------------------------------------------------

create_file proc												;Создаёт файл
	mov ah,3ch
	xor cx,cx			;файл без заморочек!
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

open_file proc											;Открывает файл
	mov ax,3d02h			;разрешён полный доступ к файлу
	mov dx,offset failik
	int 21h
	jnc no_err_open
	call error_mes

no_err_open:
	mov handle,ax
ret
endp

;------------------------------------------------------------------------------

close_file proc											;Закрывает файл
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
;Процедуры доступа к диску
;------------------------------------------------------------------------------

make_image proc									;Создаёт образ флоппи-диска
	;call chist23
	set_position 0,23
	print0 Nhint5
	call create_file

count:
	mov ah,02			;function
	mov al,12h			;18 секторов на дорожке
	mov ch,counter
	mov cl,1
	mov dl,0
	mov dh,0				;0-1 -сторона
	mov bx,offset data1			;первая половина буфера - 0 головка
	int 13h				;func
	jc error_r

	mov ah,02
	mov al,12h
	mov ch,counter
	mov cl,1
	mov dl,0
	mov dh,1
	mov bx,offset [data1+2400h]	;вторая половинка буфера - 1 головка.
	int 13h
	jc error_r
	jmp exit

error_r:
	call error_mes		;Не можем читать дискету
	jmp crit_err

exit:					;Пишем в файл.
	mov cx,4800h
	mov dx,offset data1
	mov ah,40h
	mov bx,handle
	int 21h
						;Можно вставить обработчик ошибки записи
	inc counter
	call progress
	cmp counter,50h
	je conec
	jmp count

vix_osh:
	call error_mes		;разве этот код когда-нибудь выполнится?
	jmp crit_err			;зачем два обработчика ошибок?.. Оптимизировать!

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

write_image proc										;Запись образа на диск
;	call chist23
	set_position 0,23
	print0 Nhint6
	call open_file

count_w:
	mov cx,4800h					;читаем в буфер из файла
	mov dx,offset data1
	mov ax,3f00h
	mov bx,handle
	int 21h
	jc error_W					;Ошибка чтения из файла

	mov ah,03					;function
	mov al,12h					;18 секторов на дорожке
	mov ch,counter
	mov cl,1
	mov dl,0
	mov dh,0						;0-1 -сторона
	mov bx,offset data1			;первая половина буфера - 0 головка
	int 13h						;func
	jc error_w					;Ошибка записи на дискету

	mov ah,03
	mov al,12h
	mov ch,counter
	mov cl,1
	mov dl,0						;Можно ли это удалить?
	mov dh,1
	mov bx,offset [data1+2400h]	;вторая половинка буфера - 1 головка.
	int 13h
	jc error_w					;ошибка записи на дискету
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
	mov ah,02			;Чтение
	mov al,1				;Читаем только 1 сектор
	mov ch,a80			;Выбратая дорожка
	mov cl,a18			;Выбратый сектор
	mov dl,0
	mov dh,a2			;Выбратая сторона (цилиндр)
	mov bx,offset data1	;Многострадальный буфер - в него читаем.
	int 13h				;Обращаимси
	jc err_read			;Если ошибка
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

write_sector proc										;Записываем сектор
	call open_file
	mov cx,512h
	mov dx,offset data1
	mov ax,3f00h
	mov bx,handle
	int 21h
	jc not_read					;Ошибка чтения из файла
	jmp schital_blin		

not_read:
	call error_mes
	jmp nafig_vse

schital_blin:						;совершаем запись на дискету
	mov ah,03					;писать
	mov al,1						;1 сектор 
	mov ch,a80					;выбратый цилиндр
	mov cl,a18					;выбратый сектор
	mov dl,0						;диск A
	mov dh,a2					;выбратая сторона
	mov bx,offset data1			;используем тот же буфер.
	int 13h						;делаем
	jc not_read					;какая-то ошибка...
	call ok_mes
	call close_file

nafig_vse:
ret
endp

;------------------------------------------------------------------------------
;Разные процедуры
;------------------------------------------------------------------------------

read_name proc											;Ввод имени файла

	call yes_cursor
;	call chist23
	set_position 0,23
	print0 Nhint4
	set_position 35,3
	paint 35,3,46,3,30
	mov di,offset failik
	mov cx,12							;ограничение длины

naming:		
	xor ax,ax
	int 16h
;обработчики ненужных клавиш - можно вставить функции редактирования
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
;Хм... Вспомнил - были какие-то баги при повторном использовании буфера...

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

no_cursor proc	;запрещает мигание курсора, и сам курсор тоже.
	mov ch,20h
	mov ah,01h
	int 10h
ret
endp

;------------------------------------------------------------------------------

yes_cursor proc	;разрешает курсор
	mov ch,01h
	mov cl,1fh
	mov ah,01h
	int 10h
ret
endp

;------------------------------------------------------------------------------

data1 equ $+10000d		;Таким образом пишем да-а-алеко в память...

end start