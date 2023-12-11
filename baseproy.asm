title "Proyecto: Galaga" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada página de código
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 128 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Definición de constantes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Valor ASCII de caracteres para el marco del programa
marcoEsqInfIzq 		equ 	200d 	;'╚'
marcoEsqInfDer 		equ 	188d	;'╝'
marcoEsqSupDer 		equ 	187d	;'╗'
marcoEsqSupIzq 		equ 	201d 	;'╔'
marcoCruceVerSup	equ		203d	;'╦'
marcoCruceHorDer	equ 	185d 	;'╣'
marcoCruceVerInf	equ		202d	;'╩'
marcoCruceHorIzq	equ 	204d 	;'╠'
marcoCruce 			equ		206d	;'╬'
marcoHor 			equ 	205d 	;'═'
marcoVer 			equ 	186d 	;'║'
;Atributos de color de BIOS
;Valores de color para carácter
cNegro 			equ		00h
cAzul 			equ		01h
cVerde 			equ 	02h
cCyan 			equ 	03h
cRojo 			equ 	04h
cMagenta 		equ		05h
cCafe 			equ 	06h
cGrisClaro		equ		07h
cGrisOscuro		equ		08h
cAzulClaro		equ		09h
cVerdeClaro		equ		0Ah
cCyanClaro		equ		0Bh
cRojoClaro		equ		0Ch
cMagentaClaro	equ		0Dh
cAmarillo 		equ		0Eh
cBlanco 		equ		0Fh
;Valores de color para fondo de carácter
bgNegro 		equ		00h
bgAzul 			equ		10h
bgVerde 		equ 	20h
bgCyan 			equ 	30h
bgRojo 			equ 	40h
bgMagenta 		equ		50h
bgCafe 			equ 	60h
bgGrisClaro		equ		70h
bgGrisOscuro	equ		80h
bgAzulClaro		equ		90h
bgVerdeClaro	equ		0A0h
bgCyanClaro		equ		0B0h
bgRojoClaro		equ		0C0h
bgMagentaClaro	equ		0D0h
bgAmarillo 		equ		0E0h
bgBlanco 		equ		0F0h
;Valores para delimitar el área de juego
lim_superior 	equ		1
lim_inferior 	equ		23
lim_izquierdo 	equ		1
lim_derecho 	equ		39
lim_superior_s 	equ		2
lim_inferior_s 	equ		22
;Valores de referencia para la posición inicial del jugador
ini_columna 	equ 	lim_derecho/2
ini_renglon 	equ 	22

;Valores para la posición de los controles e indicadores dentro del juego
;Lives
lives_col 		equ  	lim_derecho+7
lives_ren 		equ  	4

;Scores
hiscore_ren	 	equ 	11
hiscore_col 	equ 	lim_derecho+7
score_ren	 	equ 	13
score_col 		equ 	lim_derecho+7

;Botón STOP
stop_col 		equ 	lim_derecho+10
stop_ren 		equ 	19
stop_izq 		equ 	stop_col-1
stop_der 		equ 	stop_col+1
stop_sup 		equ 	stop_ren-1
stop_inf 		equ 	stop_ren+1

;Botón PAUSE
pause_col 		equ 	stop_col+10
pause_ren 		equ 	19
pause_izq 		equ 	pause_col-1
pause_der 		equ 	pause_col+1
pause_sup 		equ 	pause_ren-1
pause_inf 		equ 	pause_ren+1

;Botón PLAY
play_col 		equ 	pause_col+10
play_ren 		equ 	19
play_izq 		equ 	play_col-1
play_der 		equ 	play_col+1
play_sup 		equ 	play_ren-1
play_inf 		equ 	play_ren+1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;////////////////////////////////////////////////////
;Definición de variables
;////////////////////////////////////////////////////
titulo 			db 		"GALAGA"
scoreStr 		db 		"SCORE"
hiscoreStr		db 		"HI-SCORE"
livesStr		db 		"LIVES"
blank			db 		"     "
player_lives 	db 		3
player_score 	dw 		0
player_hiscore 	dw 		0

player_col		db 		ini_columna 	;posicion en columna del jugador
player_ren		db 		ini_renglon 	;posicion en renglon del jugador

enemy_col		db 		ini_columna 	;posicion en columna del enemigo
enemy_ren		db 		3 				;posicion en renglon del enemigo

col_aux 		db 		0  		;variable auxiliar para operaciones con posicion - columna
ren_aux 		db 		0 		;variable auxiliar para operaciones con posicion - renglon

conta 			db 		0 		;contador

shot_col 		db 		ini_columna 		;posición en columna de disparo 
shot_ren		db      ini_renglon			;posicion en renglon de disparo

shot_col_enemigo db 0
shot_ren_enemigo db 0

;; Variables de ayuda para lectura de tiempo del sistema
tick_ms			dw 		55 		;55 ms por cada tick del sistema, esta variable se usa para operación de MUL convertir ticks a segundos
mil				dw		1000 	;1000 auxiliar para operación DIV entre 1000
diez 			dw 		10 		;10 auxiliar para operaciones
sesenta			db 		60 		;60 auxiliar para operaciones
status 			db 		0 		;0 stop, 1 play, 2 pause
ticks 			dw		0 		;Variable para almacenar el número de ticks del sistema y usarlo como referencia

;Variables que sirven de parámetros de entrada para el procedimiento IMPRIME_BOTON
boton_caracter 	db 		0
boton_renglon 	db 		0
boton_columna 	db 		0
boton_color		db 		0
boton_bg_color	db 		0


;Auxiliar para calculo de coordenadas del mouse en modo Texto
ocho			db 		8
;Cuando el driver del mouse no está disponible
no_mouse		db 	'No se encuentra driver de mouse. Presione [enter] para salir$'

;auxiliar para comprobar que exista nave enemiga
aux_enemigo_existe db 1d

;auxiliar para comprobar que exista nave enemiga
aux_jugador_existe db 1d

;Auxiliar que se activa en caso de que un disparo del jugador sea exitoso
aux_successfulShot db 0

;Auxiliar que se activa en caso de que un disparo del enemigo sea exitoso
aux_successfulShot_Enemy db 0

;Existe un disparo enemigo
aux_disparo_enemigo_existe db 0

;Existe un disparo del jugador
aux_disparo_jugador_existe db 0

;Existe un disparos simultaneos
aux_disparos_existen db 0

;Existe un disparos simultaneos
readyToErase db 0

;Bandera para la colision de ambos disparos (jugador y enemigo)
colision_disparos db 0

;Variables para pantalla de inicio
carga_inicio 	db 		'PRESIONE [ENTER] PARA COMENZAR$'
derechos      	db 		'TODOS LOS DERECHOS RESERVADOS $'	
chilaquiles  	db 		'2023 ',00B8h ,' CHILAQUILES CON POLLO$'
instrucciones 	db 		'INSTRUCCIONES$'
instruccion1	db      'MOVER A LA DERECHA: [D]$'
instruccion2	db 		'MOVER A LA IZQUIERDA: [A]$'
instruccion3	db 		'DISPARAR: [ESPACIO]$'
nota 			db 		'RECUERDA DESACTIVAR LAS MAYUSCULAS$'

;////////////////////////////////////////////////////

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Macros;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
;clear - Limpia pantalla
reboot macro
mov [aux_successfulShot],0
mov [aux_successfulShot_Enemy],0
mov [aux_disparo_enemigo_existe],0
mov [aux_disparo_jugador_existe],0
mov [aux_disparos_existen],0
mov [readyToErase],0
mov [colision_disparos],0
mov [aux_enemigo_existe],1
mov [aux_jugador_existe],1
call BORRA_JUGADOR
endm

clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h		;llama interrupcion 10h con opcion 00h. 
				;Establece modo de video limpiando pantalla
endm

;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 

;inicializa_ds_es - Inicializa el valor del registro DS y ES
inicializa_ds_es 	macro
	mov ax,@data
	mov ds,ax
	mov es,ax 		;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
endm

;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse	macro
	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;posiciona_cursor_mouse - Establece la posición inicial del cursor del mouse
posiciona_cursor_mouse	macro columna,renglon
	mov dx,renglon
	mov cx,columna
	mov ax,4		;opcion 0004h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado	macro
	mov ah,01h 		;Opcion 01h
	mov cx,2607h 	;Parametro necesario para ocultar cursor
	int 10h 		;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo	macro
	mov ax,1003h 		;Opcion 1003h
	xor bl,bl 			;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 			;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
;Los colores disponibles están en la lista a continuacion;
; Colores:
; 0h: Negro
; 1h: Azul
; 2h: Verde
; 3h: Cyan
; 4h: Rojo
; 5h: Magenta
; 6h: Cafe
; 7h: Gris Claro
; 8h: Gris Oscuro
; 9h: Azul Claro
; Ah: Verde Claro
; Bh: Cyan Claro
; Ch: Rojo Claro
; Dh: Magenta Claro
; Eh: Amarillo
; Fh: Blanco
; utiliza int 10h opcion 09h
; 'caracter' - caracter que se va a imprimir
; 'color' - color que tomará el caracter
; 'bg_color' - color de fondo para el carácter en la celda
; Cuando se define el color del carácter, éste se hace en el registro BL:
; La parte baja de BL (los 4 bits menos significativos) define el color del carácter
; La parte alta de BL (los 4 bits más significativos) define el color de fondo "background" del carácter
imprime_caracter_color macro caracter,color,bg_color
	mov ah,09h				;preparar AH para interrupcion, opcion 09h
	mov al,caracter 		;AL = caracter a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,1				;CX = numero de veces que se imprime el caracter
							;CX es un argumento necesario para opcion 09h de int 10h
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
; utiliza int 10h opcion 09h
; 'cadena' - nombre de la cadena en memoria que se va a imprimir
; 'long_cadena' - longitud (en caracteres) de la cadena a imprimir
; 'color' - color que tomarán los caracteres de la cadena
; 'bg_color' - color de fondo para los caracteres en la cadena
imprime_cadena_color macro cadena,long_cadena,color,bg_color
	mov ah,13h				;preparar AH para interrupcion, opcion 13h
	lea bp,cadena 			;BP como apuntador a la cadena a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,long_cadena		;CX = longitud de la cadena, se tomarán este número de localidades a partir del apuntador a la cadena
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse	macro
	mov ax,0003h
	int 33h
endm

;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0				;opcion 0
	int 33h					;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
							;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm
;--------------------------------------------------------------------------------
;lee la entrada por teclado y la guarda en al
lee_teclado macro 
	mov ah,08h 				;Opcion 8 para interrupción 21h (entrada por teclado)
	int 21h					;Interrupción 21h 
endm

;valida si se puede hacer movimiento a la derecha
validar_derecha macro 
	mov al, [player_col]  	;se mueve [player_col] a ax
	inc al					;se incrementa 1 a ax
	cmp al, 38				;se valida que el movimiento no sobrepase el limite derecho del juego (39-1)
endm

;Valida si el enemigo puede hacer un movimiento a la derecha
validar_derecha_enemigo macro
	mov al, [enemy_col]  	;se mueve [enemy_col] a ax
	inc al					;se incrementa 1 a ax
	cmp al, 38				;se valida que el movimiento no sobrepase el limite derecho del juego (39-1)
endm

;valida si se puede hacer movimiento a la izquierda
validar_izquierda macro
	mov al, [player_col]  	;se mueve [player_col] a ax
	dec al					;se decrementa 1 a ax
	cmp al, 2				;se valida que el movimiento no sobrepase el limite izquiedo del juego (1+1)
endm

;valida si se puede hacer movimiento a la izquierda
validar_izquierda_enemigo macro
	mov al, [enemy_col]  	;se mueve [player_col] a ax
	dec al					;se decrementa 1 a ax
	cmp al, 2				;se valida que el movimiento no sobrepase el limite izquiedo del juego (1+1)
endm

;valida si el enemigo puede hacer movimiento hacia arriba
validar_arriba_enemigo macro
	mov al, [enemy_ren]		;se mueve [enemy_ren] a ax
	inc al					;se incremente 1 a ax
	cmp al, 2				;se valida que el movimiento no sobrepase el limite superior del juego (1+1)
endm

;valida si el enemigo puede hacer movimiento hacia abajo
validar_abajo_enemigo macro
	mov al, [enemy_ren]		;se mueve [enemy_ren] a ax
	dec al					;se decrementa 1 a ax
	cmp al, 10				;se valida que el movimiento no sobrepase el limite inferior del juego establecido (10)
endm

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Fin Macros;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

	.code
inicio:								;etiqueta inicio
	inicializa_ds_es				;Inicializa el valor del registro DS y ES
	reboot
	comprueba_mouse					;macro para revisar driver de mouse
	xor ax,0FFFFh					;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_home_screen			;Si existe el driver del mouse, entonces salta a 'imprime_ui'
	;Si no existe el driver del mouse entonces se muestra un mensaje
	lea dx,[no_mouse]
	mov ax,0900h					;opcion 9 para interrupcion 21h
	int 21h							;interrupcion 21h. Imprime cadena.
	jmp teclado						;salta a 'teclado'
imprime_home_screen:				;Impresion de la pantalla al iniciar
	clear 							;limpia la pantalla 
	oculta_cursor_teclado			;oculta cursor de la pantalla
	apaga_cursor_parpadeo			;deshabilita parpadeo del cursor
	call DIBUJA_HOME_SCREEN 		;procedimiento que dibuja la pantalla de inicio del programa
	call BORRA_JUGADOR
	mov [player_col], ini_columna
	mov [player_ren], ini_renglon
	presiona_enter:					;Tecla para la pantalla de inicio
	lee_teclado						;lee la entrada del teclado
	cmp al,0Dh						;compara la entrada de teclado si fue [enter]
	jnz presiona_enter 				;Sale del ciclo hasta que presiona la tecla [enter]
	muestra_cursor_mouse
imprime_ui:
	clear 							;limpia pantalla
	oculta_cursor_teclado			;oculta cursor del mouse
	apaga_cursor_parpadeo 			;Deshabilita parpadeo del cursor
	call DIBUJA_UI 					;procedimiento que dibuja marco de la interfaz
	muestra_cursor_mouse 			;hace visible el cursor del mouse
	mov ah, 0 						;Función 0: Configurar temporizador
    int 1Ah   						;Llamar a la interrupción 1Ah
    ; Ahora, los ticks del sistema están en CX:DX
    mov ax, dx						;Mueve el valor del registro DX a AX para compararlo con la variable [ticks]
    mov [ticks], ax 				;Guardar los ticks en la variable 'ticks'
	jmp juego						;Saltamos a la etiqueta juego

juego:
	mov ah, 0Bh      				;opcion bh, para verificar si se pulso una tecla 
    int 21h							;interrupcion 21h
    cmp al, 0                       ;Compara el valor obtenido en el registro AL con 0
	je NomovimientoJuego			;En caso de que no se haya pulsado una tecla, vamos a la etiqueta NomovimientoJuego
	cmp [aux_enemigo_existe],0 		;comprueba que la nave enemiga no exista. Si es cierto y es igual a 0, no existe.
	je crearEnemigo					;Saltamos al proceso para crear enemigo
	cmp [aux_jugador_existe],0
	je crearJugador
	mov ah,2Ch					;Regresa en dl un valor de 0 a 99 dependiendo del reloj del sistema
	int 21h
	cmp dl,70d					
	ja DispararEnemigo	
	lee_teclado						;Caso contrario (que se haya pulsado alguna tecla) leeremos la entrada del teclado
	cmp al,64h						;compara que el valor ingresado sea 64h (d)
	je mueveDerecha 				;Salto a mueveDerecha si se presiono la d
	cmp al, 61h						;compara que el valor ingresado sea 61h (a)
	je mueveIzquierda				;salto a mueveIzquierda si se presiono la a
	cmp al,20h 						;Compara que el valor ingresado sea 20h (espacio)
	je Disparar						;salto a Disparar si se presiono espacio
	jmp siMovimientoJuego			;Salto a la etiqueta siMovimientoJuego para que continue el flujo
	;En caso de que no exista alguna tecla inicia la etiqueta NomovimientoJuego
	NomovimientoJuego:
		mov ah,2Ch					;Regresa en dl un valor de 0 a 99 dependiendo del reloj del sistema
		int 21h
		cmp dl,70d					
		ja DispararEnemigo

		;Movimiento fluido en el juego
		mov ecx, 1500000  			;1 segundo en microsegundos
		esperarJuego:			;Bucle que nos permite que el juego tenga su continuidad
			nop					;Es una instrucción que no realiza ninguna operación
			loop esperarJuego	;Procedemos a realizar el loop hasta que sea 0
		;Movimiento de la nave de forma aleatoria
		mov ah,2Ch					;Regresa en dl un valor de 0 a 99 dependiendo del reloj del sistema
		int 21h						;Dependiendo del valor obtenido en la linea anterior, podemos realizar el movimiento aleatorio del enemigo
		cmp dl,40d					;En caso de que dl sea menor a 40, se moverá el enemigo a la izquierda
		jb mueveIzquierdaEnemigo	;Enemigo moviendose a la izquierda
		cmp dl,80d					;En caso de que dl sea menor a 80, se moverá el enemigo a la derecha
		jb mueveDerechaEnemigo		;Enemigo moviendose a la derecha
		cmp dl,90d					;En caso de que dl sea menor a 90, se moverá el enemigo hacia arriba 
		jb mueveArribaEnemigo		;Enemigo moviendose hacia arriba
		cmp dl,100d					;En caso de que dl sea menor a 100, se moverá el enemigo hacia abajo
		jb mueveAbajoEnemigo		;Enemigo moviendose hacia abajo

		;Etiqueta en caso de que si exista un movimiento por parte del jugador usando teclado
		siMovimientoJuego:

		;Movimiento fluido en el juego
		mov ecx, 1500000  			;1 segundo en microsegundos
		esperarJuegodos:			;Bucle que nos permite que el juego tenga su continuidad
			nop					;Es una instrucción que no realiza ninguna operación
			loop esperarJuegodos	;Procedemos a realizar el loop hasta que sea 0

			;Movimiento de la nave de forma aleatoria
		mov ah,2Ch					;Regresa en dl un valor de 0 a 99 dependiendo del reloj del sistema
		int 21h						;Dependiendo del valor obtenido en la linea anterior, podemos realizar el movimiento aleatorio del enemigo
		cmp dl,40d					;En caso de que dl sea menor a 40, se moverá el enemigo a la izquierda
		jb mueveIzquierdaEnemigo	;Enemigo moviendose a la izquierda
		cmp dl,80d					;En caso de que dl sea menor a 80, se moverá el enemigo a la derecha
		jb mueveDerechaEnemigo		;Enemigo moviendose a la derecha
		cmp dl,90d					;En caso de que dl sea menor a 90, se moverá el enemigo hacia arriba 
		jb mueveArribaEnemigo		;Enemigo moviendose hacia arriba
		cmp dl,100d					;En caso de que dl sea menor a 100, se moverá el enemigo hacia abajo
		jb mueveAbajoEnemigo		;Enemigo moviendose hacia abajo


			mov ah, 0 					;Función 0: Configurar temporizador
			int 1Ah   					;Llamar a la interrupción 1Ah
			; Ahora, los ticks del sistema están en CX:DX
			mov ax, dx					;Mueve el valor del registro DX a AX para compararlo con la variable [ticks]
			cmp ax,[ticks]				;Compara el valor de AX (ticks del sistema) con el valor almacenado en la dirección de memoria [ticks]
			jne juego 					;ciclo infinito realizado con los ticks

mueveArribaEnemigo:
	validar_arriba_enemigo			;valida que no sobrepase el limite superior el enemigo
	je juego						;si sobrepasa el limite, se devuelve el flujo a juego
	CALL MUEVE_ARRIBA_ENEMIGO		;si no sobrepasa el limite, se mueve hacia arriba 
	jmp juego						;se hace salto a juego

mueveAbajoEnemigo:
	validar_abajo_enemigo			;valida que no sobrepase el limite inferior el enemigo
	je juego						;si sobrepasa el limite, se devuelve el flujo a juego
	CALL MUEVE_ABAJO_ENEMIGO		;si no sobrepasa el limite, se mueve hacia abajo 
	jmp juego						;se hace salto a juego

mueveDerecha:
	validar_derecha					;valida que no sobrepase el limite derecho
	je juego						;si sobrepasa el limite, se devuelve el flujo a juego
	CALL MUEVE_DERECHA				;si no sobrepasa el limite, se mueve a la derecha 
	jmp juego						;se hace salto a juego

mueveDerechaEnemigo:
	validar_derecha_enemigo			;valida que no sobrepase el limite derecho el enemigo
	je juego						;si sobrepasa el limite, se devuelve el flujo a juego
	CALL MUEVE_DERECHA_ENEMIGO		;si no sobrepasa el limite, se mueve a la derecha 
	jmp juego						;se hace salto a juego

mueveIzquierda:
	validar_izquierda				;valida que no sobrepese el limite izquierdo
	je juego						;si sobrepasa el limite, se devuelve el flujo a juego 
	CALL MUEVE_IZQUIERDA			;si no sobrepasa el limite, se mueve a la izquierda
	jmp juego						;se hace salto a juego

mueveIzquierdaEnemigo:
	validar_izquierda_enemigo		;valida que no sobrepese el limite izquierdo el enemigo
	je juego						;si sobrepasa el limite, se devuelve el flujo a juego 
	CALL MUEVE_IZQUIERDA_ENEMIGO	;si no sobrepasa el limite, se mueve a la izquierda
	jmp juego						;se hace salto a juego

Disparar: 
	cmp [aux_enemigo_existe],0 	;comprueba que la nave enemiga no exista. Si es cierto y es igual a 0, no existe.
	je crearEnemigo				;Saltamos al proceso para crear enemigo
	cmp [aux_jugador_existe],0
	je crearJugador
	cmp [aux_disparo_enemigo_existe],1
	je IniciarDisparo
	mov al, [player_col] 				;Copia player_col en al
	mov [shot_col], al          		;Copia [player_col] en shot_col. Posicionar la columna del disparo donde esta la nave 
	mov al, [player_ren]				;Copia player_ren en al
	sub al, 3d                 			;posiciona  la columna 1 renglon arriba de la nave
	mov [shot_ren], al          		;Copia [player_col] en shot_col. Posicionar el renglo del disparo donde esta la nave 
	call IMPRIME_DISPARO       			;imprime el disparo
	mov [aux_disparo_jugador_existe],1
	cmp [aux_disparo_enemigo_existe],1
	je Movimiento_disparos
	;Movimiento del disparo para que solo exista uno a la vez
	Movimiento_disparo:		
		cmp [aux_enemigo_existe],0 	;comprueba que la nave enemiga no exista. Si es cierto y es igual a 0, no existe.
		je crearEnemigo				;Saltamos al proceso para crear enemigo
		cmp [aux_jugador_existe],0
		je crearJugador
		CALL BORRA_DISPARO				;se borra el disparo
		dec [shot_ren]					;se decrementa el renglo del disparo, para subirlo
		CALL IMPRIME_DISPARO			;se vuele a imprimir el disparo
		CALL DISPARO_EXITOSO			;verifica si el disparo fue exitoso, para contabilizar el puntaje y llevar a cabo la destrucción y creación de nave enemiga en consecuencia
		cmp [aux_successfulShot],1d		;en caso de que el el disparo sea exitoso, [aux_successfulShot]=1
		je disparoExitoso				;si la condición anterior es cierta, interrumpe el flujo para borrar el disparo y reinicar su posición
		cmp [shot_ren], lim_superior 	;se valida que no sobrepase el limite superior
		je borrarDisparo				;si lo sobrepasa, regresa al flujo principal
		mov ah, 0Bh      				;opcion bh, para verificar si se pulso una tecla 
    	int 21h							;interrupcion 21h
    	cmp al, 0                       ;Compara el valor obtenido en el registro AL con 0
    	je Nomovimiento					;En caso de que no se haya pulsado una tecla, vamos a la etiqueta Nomovimiento
		lee_teclado						;lee teclado
		cmp al,64h						;compara que el valor ingresado sea 64h (d)
		je mueveDerechaShot 			;Salto a mueveDerecha si se presiono la d
		cmp al, 61h						;compara que el valor ingresado sea 61h (a)
		je mueveIzquierdaShot			;salto a mueveIzquierda si se presiono la a
		jmp siMovimiento				;Salto a la etiqueta siMovimiento para que continue el flujo
		;En caso de que no exista alguna tecla inicia la etiqueta Nomovimiento
		Nomovimiento:
			;Movimiento fluido en el juego
			mov ecx, 1500000  			;1 segundo en microsegundos
			esperar:					;Bucle que nos permite que el juego tenga su continuidad
				nop						;Es una instrucción que no realiza ninguna operación
				loop esperar			;Procedemos a realizar el loop hasta que sea 0
			;Movimiento de la nave de forma aleatoria una vez el jugador disparó
			mov ah,2Ch					;Regresa en dl un valor de 0 a 99 dependiendo del reloj del sistema
			int 21h						;Dependiendo del valor obtenido en la linea anterior, podemos realizar el movimiento aleatorio del enemigo
			cmp dl,35d					;En caso de que dl sea menor a 40, se moverá el enemigo a la izquierda
			jb mueveIzquierdaShotEnemigo;Enemigo moviendose a la izquierda
			cmp dl,70d					;En caso de que dl sea menor a 80, se moverá el enemigo a la derecha
			jb mueveDerechaShotEnemigo	;Enemigo moviendose a la derecha
			cmp dl,95d					;En caso de que dl sea menor a 90, se moverá el enemigo hacia arriba 
			jb mueveArribaShotEnemigo	;Enemigo moviendose hacia arriba
			cmp dl,100d					;En caso de que dl sea menor a 100, se moverá el enemigo hacia abajo
			jb mueveAbajoShotEnemigo	;Enemigo moviendose hacia abajo

		;Etiqueta en caso de que si exista un movimiento por parte del jugador usando teclado
		siMovimiento:
		
			;Movimiento fluido en el juego
			mov ecx, 1500000  			;1 segundo en microsegundos
			esperardos:					;Bucle que nos permite que el juego tenga su continuidad
				nop						;Es una instrucción que no realiza ninguna operación
				loop esperardos			;Procedemos a realizar el loop hasta que sea 0


			;Movimiento de la nave de forma aleatoria una vez el jugador disparó
			mov ah,2Ch					;Regresa en dl un valor de 0 a 99 dependiendo del reloj del sistema
			int 21h						;Dependiendo del valor obtenido en la linea anterior, podemos realizar el movimiento aleatorio del enemigo
			cmp dl,35d					;En caso de que dl sea menor a 40, se moverá el enemigo a la izquierda
			jb mueveIzquierdaShotEnemigo;Enemigo moviendose a la izquierda
			cmp dl,70d					;En caso de que dl sea menor a 80, se moverá el enemigo a la derecha
			jb mueveDerechaShotEnemigo	;Enemigo moviendose a la derecha
			cmp dl,95d					;En caso de que dl sea menor a 90, se moverá el enemigo hacia arriba 
			jb mueveArribaShotEnemigo	;Enemigo moviendose hacia arriba
			cmp dl,100d					;En caso de que dl sea menor a 100, se moverá el enemigo hacia abajo
			jb mueveAbajoShotEnemigo	;Enemigo moviendose hacia abajo

			mov ah,2Ch					;Regresa en dl un valor de 0 a 99 dependiendo del reloj del sistema
			int 21h
			cmp dl,70d					
			ja DispararEnemigo

			mov ah, 0 					;Función 0: Configurar temporizador
			int 1Ah   					;Llamar a la interrupción 1Ah
			; Ahora, los ticks del sistema están en CX:DX
			mov ax, dx					;Mueve el valor del registro DX a AX para compararlo con la variable [ticks]
			cmp ax,[ticks]				;Compara el valor de AX (ticks del sistema) con el valor almacenado en la dirección de memoria [ticks]
			jne Movimiento_disparo		;ciclo infinito realizado con los ticks

DispararEnemigo:
	cmp [aux_enemigo_existe],0 	;comprueba que la nave enemiga no exista. Si es cierto y es igual a 0, no existe.
	je crearEnemigo				;Saltamos al proceso para crear enemigo
	cmp [aux_jugador_existe],0
	je crearJugador
	cmp [aux_disparo_jugador_existe],1
	je IniciarDisparoEnemigo
	mov al, [enemy_col] 				;Copia enemy_col en al
	mov [shot_col_enemigo], al          		;Copia [enemy_col] en shot_col. Posicionar la columna del disparo donde esta la nave 
	mov al, [enemy_ren]					;Copia enemy_ren en al
	add al, 3d                 			;posiciona  la columna 1 renglon abajo de la nave enemiga
	mov [shot_ren_enemigo], al          		;Copia [player_col] en shot_col. Posicionar el renglo del disparo donde esta la nave 
	call IMPRIME_DISPARO_ENEMY       	;imprime el disparo
	mov [aux_disparo_enemigo_existe],1
	cmp [aux_disparo_jugador_existe],1
	je Movimiento_disparos
	;Movimiento del disparo para que solo exista uno a la vez
	Movimiento_disparo_enemigo:
		CALL BORRA_DISPARO_ENEMIGO			;se borra el disparo
		inc [shot_ren_enemigo]						;se incrementa el renglo del disparo, para bajarlo
		CALL IMPRIME_DISPARO_ENEMY			;se vuele a imprimir el disparo
		CALL DISPARO_EXITOSO_ENEMIGO		;verifica si el disparo fue exitoso, para la disminucion de las vidas del jugador
		cmp [aux_successfulShot_Enemy],1d		;en caso de que el el disparo sea exitoso, [aux_successfulShot]=1
		je disparoExitosoEnemigo				;si la condición anterior es cierta, interrumpe el flujo para borrar el disparo y reinicar su posición
		cmp [shot_ren_enemigo], lim_inferior 	;se valida que no sobrepase el limite inferior
		je borrarDisparoEnemigo				;si lo sobrepasa, regresa al flujo principal
		mov ah, 0Bh      				;opcion bh, para verificar si se pulso una tecla 
    	int 21h							;interrupcion 21h
    	cmp al, 0                       ;Compara el valor obtenido en el registro AL con 0
		je NomovimientoDisparoEnemigo	;En caso de que no se haya pulsado una tecla, vamos a la etiqueta Nomovimiento
		lee_teclado						;lee teclado
		cmp al,64h						;compara que el valor ingresado sea 64h (d)
		je mueveDerechaShotDisparar 			;Salto a mueveDerecha si se presiono la d
		cmp al, 61h						;compara que el valor ingresado sea 61h (a)
		je mueveIzquierdaShotDisparar			;salto a mueveIzquierda si se presiono la a
		cmp al, 20h
		je Disparar
		jmp siMovimientoDisparoEnemigo				;Salto a la etiqueta siMovimiento para que continue el flujo
		NomovimientoDisparoEnemigo:

		;Movimiento fluido en el juego
			mov ecx, 1500000  			;1 segundo en microsegundos
			esperarDispararEnemigo:					;Bucle que nos permite que el juego tenga su continuidad
				nop						;Es una instrucción que no realiza ninguna operación
				loop esperarDispararEnemigo			;Procedemos a realizar el loop hasta que sea 0
			;Movimiento de la nave de forma aleatoria una vez el jugador disparó
			mov ah,2Ch					;Regresa en dl un valor de 0 a 99 dependiendo del reloj del sistema
			int 21h						;Dependiendo del valor obtenido en la linea anterior, podemos realizar el movimiento aleatorio del enemigo
			cmp dl,35d					;En caso de que dl sea menor a 40, se moverá el enemigo a la izquierda
			jb mueveIzquierdaShotEnemigoDisparar;Enemigo moviendose a la izquierda
			cmp dl,70d					;En caso de que dl sea menor a 80, se moverá el enemigo a la derecha
			jb mueveDerechaShotEnemigoDisparar	;Enemigo moviendose a la derecha
			cmp dl,95d					;En caso de que dl sea menor a 90, se moverá el enemigo hacia arriba 
			jb mueveArribaShotEnemigoDisparar	;Enemigo moviendose hacia arriba
			cmp dl,100d					;En caso de que dl sea menor a 100, se moverá el enemigo hacia abajo
			jb mueveAbajoShotEnemigoDisparar	;Enemigo moviendose hacia abajo

		siMovimientoDisparoEnemigo:

		;Movimiento fluido en el juego
			mov ecx, 1500000  			;1 segundo en microsegundos
			esperarDispararEnemigodos:					;Bucle que nos permite que el juego tenga su continuidad
				nop						;Es una instrucción que no realiza ninguna operación
				loop esperarDispararEnemigodos			;Procedemos a realizar el loop hasta que sea 0

		;Movimiento de la nave de forma aleatoria una vez el jugador disparó
			mov ah,2Ch					;Regresa en dl un valor de 0 a 99 dependiendo del reloj del sistema
			int 21h						;Dependiendo del valor obtenido en la linea anterior, podemos realizar el movimiento aleatorio del enemigo
			cmp dl,35d					;En caso de que dl sea menor a 40, se moverá el enemigo a la izquierda
			jb mueveIzquierdaShotEnemigoDisparar;Enemigo moviendose a la izquierda
			cmp dl,70d					;En caso de que dl sea menor a 80, se moverá el enemigo a la derecha
			jb mueveDerechaShotEnemigoDisparar	;Enemigo moviendose a la derecha
			cmp dl,95d					;En caso de que dl sea menor a 90, se moverá el enemigo hacia arriba 
			jb mueveArribaShotEnemigoDisparar	;Enemigo moviendose hacia arriba
			cmp dl,100d					;En caso de que dl sea menor a 100, se moverá el enemigo hacia abajo
			jb mueveAbajoShotEnemigoDisparar	;Enemigo moviendose hacia abajo

		;Etiqueta en caso de que si exista un movimiento por parte del jugador usando teclado
			mov ah, 0 					;Función 0: Configurar temporizador
			int 1Ah   					;Llamar a la interrupción 1Ah
			; Ahora, los ticks del sistema están en CX:DX
			mov ax, dx					;Mueve el valor del registro DX a AX para compararlo con la variable [ticks]
			cmp ax,[ticks]				;Compara el valor de AX (ticks del sistema) con el valor almacenado en la dirección de memoria [ticks]
			jne Movimiento_disparo_enemigo		;ciclo infinito realizado con los ticks
DispararEnemigos:
	IniciarDisparo:
		cmp [aux_enemigo_existe],0 	;comprueba que la nave enemiga no exista. Si es cierto y es igual a 0, no existe.
		je crearEnemigo				;Saltamos al proceso para crear enemigo
		cmp [aux_jugador_existe],0
		je crearJugador
		mov [aux_disparo_jugador_existe],1
		mov al, [player_col] 				;Copia player_col en al
		mov [shot_col], al          		;Copia [player_col] en shot_col. Posicionar la columna del disparo donde esta la nave 
		mov al, [player_ren]				;Copia player_ren en al
		sub al, 3d                 			;posiciona  la columna 1 renglon arriba de la nave
		mov [shot_ren], al          		;Copia [player_col] en shot_col. Posicionar el renglo del disparo donde esta la nave 
		call IMPRIME_DISPARO       			;imprime el disparo
		CALL BORRA_DISPARO_COLISION
		cmp [colision_disparos], 1
		je borrarAmbosDisparosColision
		jmp Movimiento_disparos
	IniciarDisparoEnemigo:
		cmp [aux_enemigo_existe],0 	;comprueba que la nave enemiga no exista. Si es cierto y es igual a 0, no existe.
		je crearEnemigo				;Saltamos al proceso para crear enemigo
		cmp [aux_jugador_existe],0
		je crearJugador
		mov [aux_disparo_enemigo_existe],1
		mov al, [enemy_col] 				;Copia enemy_col en al
		mov [shot_col_enemigo], al          		;Copia [enemy_col] en shot_col. Posicionar la columna del disparo donde esta la nave 
		mov al, [enemy_ren]					;Copia enemy_ren en al
		add al, 3d                 			;posiciona  la columna 1 renglon abajo de la nave enemiga
		mov [shot_ren_enemigo], al          		;Copia [player_col] en shot_col. Posicionar el renglo del disparo donde esta la nave 
		call IMPRIME_DISPARO_ENEMY       	;imprime el disparo
		CALL BORRA_DISPARO_COLISION
		cmp [colision_disparos], 1
		je borrarAmbosDisparosColision
		jmp Movimiento_disparos
	Movimiento_disparos:
		cmp [aux_enemigo_existe],0 	;comprueba que la nave enemiga no exista. Si es cierto y es igual a 0, no existe.
		je crearEnemigo				;Saltamos al proceso para crear enemigo
		cmp [aux_jugador_existe],0
		je crearJugador
		cmp [shot_ren], lim_superior
		je borrarDisparo_s
		cmp [shot_ren_enemigo], lim_inferior 	;se valida que no sobrepase el limite inferior
		je borrarDisparoEnemigo_s
		CALL BORRA_DISPARO
		CALL BORRA_DISPARO_ENEMIGO
		dec [shot_ren]
		inc [shot_ren_enemigo]
		CALL BORRA_DISPARO_COLISION
		cmp [colision_disparos], 1
		je borrarAmbosDisparosColision
		CALL DISPARO_EXITOSO_s
		cmp [aux_successfulShot],1d
		je disparoExitoso
		CALL DISPARO_EXITOSO_ENEMIGO_s
		cmp [aux_successfulShot_Enemy],1d
		je disparoExitosoEnemigo
		CALL IMPRIME_DISPARO
		CALL IMPRIME_DISPARO_ENEMY
		cmp [shot_ren], lim_superior_s
		je borrarDisparo_s
		cmp [shot_ren_enemigo], lim_inferior_s 	;se valida que no sobrepase el limite inferior
		je borrarDisparoEnemigo_s
		mov ah, 0Bh      				;opcion bh, para verificar si se pulso una tecla 
		int 21h							;interrupcion 21h
		cmp al, 0                       ;Compara el valor obtenido en el registro AL con 0
		je NomovimientoAmbos
		lee_teclado
		cmp al,64h						;compara que el valor ingresado sea 64h (d)
		je mueveDerechaShots 			;Salto a mueveDerecha si se presiono la d
		cmp al, 61h						;compara que el valor ingresado sea 61h (a)
		je mueveIzquierdaShots
		jmp siMovimientoAmbos
		NomovimientoAmbos:
			mov ecx, 1500000  			;1 segundo en microsegundos
				esperarAmbos:					;Bucle que nos permite que el juego tenga su continuidad
					nop						;Es una instrucción que no realiza ninguna operación
					loop esperarAmbos
			mov ah,2Ch					;Regresa en dl un valor de 0 a 99 dependiendo del reloj del sistema
			int 21h						;Dependiendo del valor obtenido en la linea anterior, podemos realizar el movimiento aleatorio del enemigo
			cmp dl,35d
			jb mueveIzquierdaShotsEnemigo;Enemigo moviendose a la izquierda
			cmp dl,70d					;En caso de que dl sea menor a 80, se moverá el enemigo a la derecha
			jb mueveDerechaShotsEnemigo	;Enemigo moviendose a la derecha
			cmp dl,95d					;En caso de que dl sea menor a 90, se moverá el enemigo hacia arriba 
			jb mueveArribaShotsEnemigo	;Enemigo moviendose hacia arriba
			cmp dl,100d					;En caso de que dl sea menor a 100, se moverá el enemigo hacia abajo
			jb mueveAbajoShotsEnemigo
		siMovimientoAmbos:

;Movimiento fluido en el juego
			mov ecx, 1500000  			;1 segundo en microsegundos
			esperarAmbosdos:					;Bucle que nos permite que el juego tenga su continuidad
				nop						;Es una instrucción que no realiza ninguna operación
				loop esperarAmbosdos			;Procedemos a realizar el loop hasta que sea 0


			mov ah,2Ch					;Regresa en dl un valor de 0 a 99 dependiendo del reloj del sistema
			int 21h						;Dependiendo del valor obtenido en la linea anterior, podemos realizar el movimiento aleatorio del enemigo
			cmp dl,35d
			jb mueveIzquierdaShotsEnemigo;Enemigo moviendose a la izquierda
			cmp dl,70d					;En caso de que dl sea menor a 80, se moverá el enemigo a la derecha
			jb mueveDerechaShotsEnemigo	;Enemigo moviendose a la derecha
			cmp dl,95d					;En caso de que dl sea menor a 90, se moverá el enemigo hacia arriba 
			jb mueveArribaShotsEnemigo	;Enemigo moviendose hacia arriba
			cmp dl,100d					;En caso de que dl sea menor a 100, se moverá el enemigo hacia abajo
			jb mueveAbajoShotsEnemigo


			mov ah, 0 					;Función 0: Configurar temporizador
			int 1Ah   					;Llamar a la interrupción 1Ah
				; Ahora, los ticks del sistema están en CX:DX
			mov ax, dx					;Mueve el valor del registro DX a AX para compararlo con la variable [ticks]
			cmp ax,[ticks]				;Compara el valor de AX (ticks del sistema) con el valor almacenado en la dirección de memoria [ticks]
			jne Movimiento_disparos

borrarAmbosDisparosColision:
	mov [colision_disparos], 0
	mov [aux_disparo_jugador_existe],0
	mov [aux_disparo_enemigo_existe],0
	CALL BORRA_DISPARO
	CALL BORRA_DISPARO_ENEMIGO
	jmp juego

borrarDisparo: ;borrar el disparo, para que no quede en la pantalla y regresa al flujo principal 
	mov [aux_disparo_jugador_existe],0
	call BORRA_DISPARO
	jmp juego

borrarDisparoEnemigo:
	mov [aux_disparo_enemigo_existe],0
	call BORRA_DISPARO_ENEMIGO
	jmp juego

borrarDisparo_s: ;borrar el disparo, para que no quede en la pantalla y regresa al flujo principal 
	mov [aux_disparo_jugador_existe],0
	call BORRA_DISPARO
	jmp Movimiento_disparo_enemigo

borrarDisparoEnemigo_s:
	mov [aux_disparo_enemigo_existe],0
	call BORRA_DISPARO_ENEMIGO 
	jmp Movimiento_disparo

mueveDerechaShot:
	validar_derecha					;valida que no sobrepase el limite derecho
	je Movimiento_disparo			;si sobrepasa el limite, se devuelve el flujo a juego
	CALL MUEVE_DERECHA          	;si no sobrepasa el limite, se mueve a la derecha 
	jmp Movimiento_disparo			;se hace salto

mueveDerechaShots:
	validar_derecha					;valida que no sobrepase el limite derecho
	je siguiente_derecha			;si sobrepasa el limite, se devuelve el flujo a juego
	CALL MUEVE_DERECHA
	siguiente_derecha:
	validar_derecha
	je Movimiento_disparos
	call MUEVE_DERECHA
	jmp Movimiento_disparos

mueveDerechaShotDisparar:
	validar_derecha					;valida que no sobrepase el limite derecho
	je Movimiento_disparo_enemigo			;si sobrepasa el limite, se devuelve el flujo a juego
	CALL MUEVE_DERECHA          	;si no sobrepasa el limite, se mueve a la derecha 
	jmp Movimiento_disparo_enemigo			;se hace salto

mueveDerechaShotEnemigo:
	validar_derecha_enemigo			;valida que no sobrepase el limite derecho del enemigo
	je Movimiento_disparo			;si sobrepasa el limite, se devuelve el flujo a juego
	CALL MUEVE_DERECHA_ENEMIGO		;si no sobrepasa el limite, se mueve a la derecha 
	jmp Movimiento_disparo			;se hace salto

mueveDerechaShotsEnemigo:
	validar_derecha_enemigo
	je siguiente_derecha_enemigo
	call MUEVE_DERECHA_ENEMIGO
	siguiente_derecha_enemigo:
	validar_derecha_enemigo
	je Movimiento_disparos
	CALL MUEVE_DERECHA_ENEMIGO
	jmp Movimiento_disparos

mueveDerechaShotEnemigoDisparar:
	validar_derecha_enemigo			;valida que no sobrepase el limite derecho del enemigo
	je Movimiento_disparo_enemigo			;si sobrepasa el limite, se devuelve el flujo a juego
	CALL MUEVE_DERECHA_ENEMIGO		;si no sobrepasa el limite, se mueve a la derecha 
	jmp Movimiento_disparo_enemigo			;se hace salto

mueveIzquierdaShot:
	validar_izquierda				;valida que no sobrepase el limite izquierdo
	je Movimiento_disparo			;si sobrepasa el limite, se devuelve el flujo a juego 
	CALL MUEVE_IZQUIERDA			;si no sobrepasa el limite, se mueve a la izquierda 
	jmp Movimiento_disparo			;se hace salto

mueveIzquierdaShots:
	validar_izquierda					;valida que no sobrepase el limite derecho
	je siguiente_izquierda			;si sobrepasa el limite, se devuelve el flujo a juego
	CALL MUEVE_IZQUIERDA
	siguiente_izquierda:
	validar_izquierda
	je Movimiento_disparos
	call MUEVE_IZQUIERDA
	jmp Movimiento_disparos

mueveIzquierdaShotDisparar:
	validar_izquierda				;valida que no sobrepase el limite izquierdo
	je Movimiento_disparo_enemigo			;si sobrepasa el limite, se devuelve el flujo a juego 
	CALL MUEVE_IZQUIERDA			;si no sobrepasa el limite, se mueve a la izquierda 
	jmp Movimiento_disparo_enemigo			;se hace salto 

mueveIzquierdaShotEnemigo:
	validar_izquierda_enemigo		;valida que no sobrepase el limite derecho del enemigo
	je Movimiento_disparo			;si sobrepasa el limite, se devuelve el flujo a juego 
	CALL MUEVE_IZQUIERDA_ENEMIGO	;si no sobrepasa el limite, se mueve a la izquierda 
	jmp Movimiento_disparo			;se hace salto

mueveIzquierdaShotsEnemigo:
	validar_izquierda_enemigo
	je siguiente_izquierda_enemigo
	call MUEVE_IZQUIERDA_ENEMIGO
	siguiente_izquierda_enemigo:
	validar_izquierda_enemigo
	je Movimiento_disparos
	CALL MUEVE_IZQUIERDA_ENEMIGO
	jmp Movimiento_disparos

mueveIzquierdaShotEnemigoDisparar:
	validar_izquierda_enemigo		;valida que no sobrepase el limite derecho del enemigo
	je Movimiento_disparo_enemigo			;si sobrepasa el limite, se devuelve el flujo a juego 
	CALL MUEVE_IZQUIERDA_ENEMIGO	;si no sobrepasa el limite, se mueve a la izquierda 
	jmp Movimiento_disparo_enemigo			;se hace salto

mueveArribaShotEnemigo:
	validar_arriba_enemigo			;valida que no sobrepase el limite superior del enemigo
	je Movimiento_disparo			;si sobrepasa el limite, se devuelve el flujo a juego 
	CALL MUEVE_ARRIBA_ENEMIGO		;si no sobrepasa el limite, se mueve hacia arriba
	jmp Movimiento_disparo			;se hace salto

mueveArribaShotsEnemigo:
	validar_arriba_enemigo
	je siguiente_arriba_enemigo
	call MUEVE_ARRIBA_ENEMIGO
	siguiente_arriba_enemigo:
	validar_arriba_enemigo
	je Movimiento_disparos
	CALL MUEVE_ARRIBA_ENEMIGO
	jmp Movimiento_disparos

mueveArribaShotEnemigoDisparar:
	validar_arriba_enemigo			;valida que no sobrepase el limite superior del enemigo
	je Movimiento_disparo_enemigo			;si sobrepasa el limite, se devuelve el flujo a juego 
	CALL MUEVE_ARRIBA_ENEMIGO		;si no sobrepasa el limite, se mueve hacia arriba
	jmp Movimiento_disparo_enemigo			;se hace salto

mueveAbajoShotEnemigo:
	validar_abajo_enemigo			;valida que no sobrepase el limite inferior del enemigo
	je Movimiento_disparo			;si sobrepasa el limite, se devuelve el flujo a juego 
	CALL MUEVE_ABAJO_ENEMIGO		;si no sobrepasa el limite, se mueve hacia abajo
	jmp Movimiento_disparo			;se hace salto

mueveAbajoShotsEnemigo:
	validar_abajo_enemigo
	je siguiente_abajo_enemigo
	call MUEVE_ABAJO_ENEMIGO
	siguiente_abajo_enemigo:
	validar_abajo_enemigo
	je Movimiento_disparos
	CALL MUEVE_ABAJO_ENEMIGO
	jmp Movimiento_disparos

mueveAbajoShotEnemigoDisparar:
	validar_abajo_enemigo			;valida que no sobrepase el limite inferior del enemigo
	je Movimiento_disparo_enemigo			;si sobrepasa el limite, se devuelve el flujo a juego 
	CALL MUEVE_ABAJO_ENEMIGO		;si no sobrepasa el limite, se mueve hacia abajo
	jmp Movimiento_disparo_enemigo			;se hace salto

disparoExitoso: 					;proceso que se lleva a cabo cuando un disparo es exitoso
	call BORRA_ENEMIGO				;llama a la función para borrar al enemigo
	call BORRA_DISPARO				;llama a la función para borrar el disparo
	mov [aux_enemigo_existe],0		;apaga la variable que indica la existencia del enemigo
	mov [aux_successfulShot],0d		;reinicia (apaga) la variable que indica un disparo exitoso
	cmp [aux_successfulShot_Enemy],1d
	je disparoExitosoEnemigo
	jmp juego						;retoma el flujo en juego

disparoExitosoEnemigo:
	call BORRA_JUGADOR
	call BORRA_DISPARO_ENEMIGO
	mov [aux_jugador_existe],0
	mov [aux_successfulShot_Enemy],0d		;reinicia (apaga) la variable que indica un disparo exitoso
	dec [player_lives]
	cmp [player_lives],0
	je inicio
	jmp juego
	
crearEnemigo: ;imprime la nave enemiga en caso de que no exista. La variable [aux_enemigo_existe] se vuelve 1 para indicar que la nave enemiga sí existe.
	CALL NUEVO_ENEMIGO
	mov [aux_enemigo_existe],1d
	jmp juego

crearJugador: ;imprime la nave enemiga en caso de que no exista. La variable [aux_enemigo_existe] se vuelve 1 para indicar que la nave enemiga sí existe.
	CALL NUEVO_JUGADOR
	mov [aux_jugador_existe],1d
	jmp juego

;En "mouse_no_clic" se revisa que el boton izquierdo del mouse no esté presionado
;Si el botón está suelto, continúa a la sección "mouse"
;si no, se mantiene indefinidamente en "mouse_no_clic" hasta que se suelte
mouse_no_clic:
	lee_mouse
	test bx,0001h
	jnz mouse_no_clic
;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse:
	lee_mouse
conversion_mouse:
	;Leer la posicion del mouse y hacer la conversion a resolucion
	;80x25 (columnas x renglones) en modo texto
	mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

	mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

	;Aquí se revisa si se hizo clic en el botón izquierdo
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aqui va la lógica de la posicion del mouse;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Si el mouse fue presionado en el renglon 0
	;se va a revisar si fue dentro del boton [X]
	cmp dx,0
	je boton_x

	jmp mouse_no_clic
boton_x:
	jmp boton_x1

;Lógica para revisar si el mouse fue presionado en [X]
;[X] se encuentra en renglon 0 y entre columnas 76 y 78
boton_x1:
	cmp cx,76
	jge boton_x2
	jmp mouse_no_clic
boton_x2:
	cmp cx,78
	jbe boton_x3
	jmp mouse_no_clic
boton_x3:
	;Se cumplieron todas las condiciones
	jmp salir

mas_botones:
	jmp mouse_no_clic

;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
teclado:
	mov ah,08h
	int 21h
	cmp al,0Dh		;compara la entrada de teclado si fue [enter]
	jnz teclado 	;Sale del ciclo hasta que presiona la tecla [enter]

salir:				;inicia etiqueta salir
	clear 			;limpia pantalla
	mov ax,4C00h	;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
	int 21h			;señal 21h de interrupción, pasa el control al sistema operativo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DIBUJA_UI proc
		;imprimir esquina superior izquierda del marco
		posiciona_cursor 0,0
		imprime_caracter_color marcoEsqSupIzq,cAmarillo,bgNegro
		
		;imprimir esquina superior derecha del marco
		posiciona_cursor 0,79
		imprime_caracter_color marcoEsqSupDer,cAmarillo,bgNegro
		
		;imprimir esquina inferior izquierda del marco
		posiciona_cursor 24,0
		imprime_caracter_color marcoEsqInfIzq,cAmarillo,bgNegro
		
		;imprimir esquina inferior derecha del marco
		posiciona_cursor 24,79
		imprime_caracter_color marcoEsqInfDer,cAmarillo,bgNegro
		
		;imprimir marcos horizontales, superior e inferior
		mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh 
	marcos_horizontales:
		mov [col_aux],cl
		;Superior
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		
		mov cl,[col_aux]
		loop marcos_horizontales

		;imprimir marcos verticales, derecho e izquierdo
		mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h 
	marcos_verticales:
		mov [ren_aux],cl
		;Izquierdo
		posiciona_cursor [ren_aux],0
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor [ren_aux],79
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Limite mouse
		posiciona_cursor [ren_aux],lim_derecho+1
		imprime_caracter_color marcoVer,cAmarillo,bgNegro

		mov cl,[ren_aux]
		loop marcos_verticales

		;imprimir marcos horizontales internos
		mov cx,79-lim_derecho-1 		
	marcos_horizontales_internos:
		push cx
		mov [col_aux],cl
		add [col_aux],lim_derecho
		;Interno superior 
		posiciona_cursor 8,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro

		;Interno inferior
		posiciona_cursor 16,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro

		mov cl,[col_aux]
		pop cx
		loop marcos_horizontales_internos

		;imprime intersecciones internas	
		posiciona_cursor 0,lim_derecho+1
		imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
		posiciona_cursor 24,lim_derecho+1
		imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro

		posiciona_cursor 8,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
		posiciona_cursor 8,79
		imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro

		posiciona_cursor 16,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
		posiciona_cursor 16,79
		imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro

		;imprimir [X] para cerrar programa
		posiciona_cursor 0,76
		imprime_caracter_color '[',cAmarillo,bgNegro
		posiciona_cursor 0,77
		imprime_caracter_color 'X',cRojoClaro,bgNegro
		posiciona_cursor 0,78
		imprime_caracter_color ']',cAmarillo,bgNegro

		;imprimir título
		posiciona_cursor 0,37
		imprime_cadena_color [titulo],6,cAmarillo,bgNegro

		call IMPRIME_ESTRELLAS

		call IMPRIME_TEXTOS

		call IMPRIME_BOTONES

		call IMPRIME_DATOS_INICIALES

		call IMPRIME_SCORES

		call IMPRIME_LIVES

		ret
	endp

	IMPRIME_TEXTOS proc
		;Imprime cadena "LIVES"
		posiciona_cursor lives_ren,lives_col
		imprime_cadena_color livesStr,5,cGrisClaro,bgNegro

		;Imprime cadena "SCORE"
		posiciona_cursor score_ren,score_col
		imprime_cadena_color scoreStr,5,cGrisClaro,bgNegro

		;Imprime cadena "HI-SCORE"
		posiciona_cursor hiscore_ren,hiscore_col
		imprime_cadena_color hiscoreStr,8,cGrisClaro,bgNegro
		ret
	endp

	IMPRIME_BOTONES proc
		;Botón STOP
		mov [boton_caracter],254d		;Carácter '■'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],stop_ren 	;Renglón en "stop_ren"
		mov [boton_columna],stop_col 	;Columna en "stop_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		;Botón PAUSE
		mov [boton_caracter],19d 		;Carácter '‼'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],pause_ren 	;Renglón en "pause_ren"
		mov [boton_columna],pause_col 	;Columna en "pause_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		;Botón PLAY
		mov [boton_caracter],16d  		;Carácter '►'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],play_ren 	;Renglón en "play_ren"
		mov [boton_columna],play_col 	;Columna en "play_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		ret
	endp

	IMPRIME_SCORES proc
		;Imprime el valor de la variable player_score en una posición definida
		call IMPRIME_SCORE
		;Imprime el valor de la variable player_hiscore en una posición definida
		call IMPRIME_HISCORE
		ret
	endp

	IMPRIME_SCORE proc
		;Imprime "player_score" en la posición relativa a 'score_ren' y 'score_col'
		mov [ren_aux],score_ren
		mov [col_aux],score_col+20
		mov bx,[player_score]
		call IMPRIME_BX
		ret
	endp

	IMPRIME_HISCORE proc
	;Imprime "player_score" en la posición relativa a 'hiscore_ren' y 'hiscore_col'
		mov [ren_aux],hiscore_ren
		mov [col_aux],hiscore_col+20
		mov bx,[player_hiscore]
		call IMPRIME_BX
		ret
	endp

	;BORRA_SCORES borra los marcadores numéricos de pantalla sustituyendo la cadena de números por espacios
	BORRA_SCORES proc
		call BORRA_SCORE
		call BORRA_HISCORE
		ret
	endp

	BORRA_SCORE proc
		posiciona_cursor score_ren,score_col+20 		;posiciona el cursor relativo a score_ren y score_col
		imprime_cadena_color blank,5,cBlanco,bgNegro 	;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
		ret
	endp

	BORRA_HISCORE proc
		posiciona_cursor hiscore_ren,hiscore_col+20 	;posiciona el cursor relativo a hiscore_ren y hiscore_col
		imprime_cadena_color blank,5,cBlanco,bgNegro 	;imprime cadena blank (espacios) para "borrar" lo que está en pantalla
		ret
	endp

	;Imprime el valor del registro BX como entero sin signo (positivo)
	;Se imprime con 5 dígitos (incluyendo ceros a la izquierda)
	;Se usan divisiones entre 10 para obtener dígito por dígito en un LOOP 5 veces (una por cada dígito)
	IMPRIME_BX proc
		mov ax,bx
		mov cx,5
	div10:
		xor dx,dx
		div [diez]
		push dx
		loop div10
		mov cx,5
	imprime_digito:
		mov [conta],cl
		posiciona_cursor [ren_aux],[col_aux]
		pop dx
		or dl,30h
		imprime_caracter_color dl,cBlanco,bgNegro
		xor ch,ch
		mov cl,[conta]
		inc [col_aux]
		loop imprime_digito
		ret
	endp

	IMPRIME_DATOS_INICIALES proc
		call DATOS_INICIALES 		;inicializa variables de juego
		;imprime la 'nave' del jugador
		;borra la posición actual, luego se reinicia la posición y entonces se vuelve a imprimir
		call BORRA_JUGADOR
		mov [player_col], ini_columna
		mov [player_ren], ini_renglon
		;Imprime jugador
		call IMPRIME_JUGADOR

		;Borrar posicion actual del enemigo y reiniciar su posicion

		;Imprime enemigo
		call IMPRIME_ENEMIGO

		ret
	endp

	;Inicializa variables del juego
	DATOS_INICIALES proc
		mov [player_score],0
		mov [player_lives], 3
		ret
	endp

	;Imprime los caracteres ☻ que representan vidas. Inicialmente se imprime el número de 'player_lives'
	IMPRIME_LIVES proc
		xor cx,cx
		mov di,lives_col+20
		mov cl,[player_lives]
	imprime_live:
		push cx
		mov ax,di
		posiciona_cursor lives_ren,al
		imprime_caracter_color 2d,cCyanClaro,bgNegro
		add di,2
		pop cx
		loop imprime_live
		ret
	endp

	BORRA_LIVES proc
		xor cx,cx
		mov di,lives_col+20
		mov cl,3
	borra_live:
		push cx
		mov ax,di
		posiciona_cursor lives_ren,al
		imprime_caracter_color 219,cNegro,bgNegro
		add di,2
		pop cx
		loop borra_live
		ret
	endp

	;Imprime la nave del jugador, que recibe como parámetros las variables ren_aux y col_aux, que indican la posición central inferior
	PRINT_PLAYER proc

		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		add [ren_aux],2
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		inc [ren_aux]
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		inc [ren_aux]
		
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cBlanco,bgNegro
		ret
	endp

	;Borra la nave del jugador, que recibe como parámetros las variables ren_aux y col_aux, que indican la posición central de la barra
	DELETE_PLAYER proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		add [ren_aux],2
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		inc [ren_aux]
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		inc [ren_aux]
		
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		
		ret
	endp

	;Imprime la nave del enemigo
	PRINT_ENEMY proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		sub [ren_aux],2
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		dec [ren_aux]
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		dec [ren_aux]
		
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cRojo,bgNegro
		ret
	endp

	;Borra la nave del enemigo
	DELETE_ENEMY proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		sub [ren_aux],2
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		dec [ren_aux]
		
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		dec [ren_aux]
		
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219,cNegro,bgNegro
		ret
	endp

	;procedimiento IMPRIME_BOTON
	;Dibuja un boton que abarca 3 renglones y 5 columnas
	;con un caracter centrado dentro del boton
	;en la posición que se especifique (esquina superior izquierda)
	;y de un color especificado
	;Utiliza paso de parametros por variables globales
	;Las variables utilizadas son:
	;boton_caracter: debe contener el caracter que va a mostrar el boton
	;boton_renglon: contiene la posicion del renglon en donde inicia el boton
	;boton_columna: contiene la posicion de la columna en donde inicia el boton
	;boton_color: contiene el color del boton
	IMPRIME_BOTON proc
	 	;background de botón
		mov ax,0600h 		;AH=06h (scroll up window) AL=00h (borrar)
		mov bh,cRojo	 	;Caracteres en color amarillo
		xor bh,[boton_color]
		mov ch,[boton_renglon]
		mov cl,[boton_columna]
		mov dh,ch
		add dh,2
		mov dl,cl
		add dl,2
		int 10h
		mov [col_aux],dl
		mov [ren_aux],dh
		dec [col_aux]
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [boton_caracter],cRojo,[boton_color]
	 	ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento UI para el ensamblador
	
	BORRA_JUGADOR proc
		mov al,[player_col]
		mov ah,[player_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call DELETE_PLAYER
		ret
	endp

	BORRA_ENEMIGO proc
		mov al,[enemy_col]
		mov ah,[enemy_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call DELETE_ENEMY
		ret
	endp

	IMPRIME_JUGADOR proc
		mov al,[player_col]
		mov ah,[player_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call PRINT_PLAYER
		ret
	endp

	IMPRIME_ENEMIGO proc
		mov al,[enemy_col]
		mov ah,[enemy_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call PRINT_ENEMY
		ret
	endp

;---------------------------------------------------------------
	MUEVE_ARRIBA_ENEMIGO proc
		call DELETE_ESTRELLAS	;borra las estrellas 
		call BORRA_ENEMIGO		;si no lo sobrepasa, hará el movimiento, para ello primero se borra el jugador
		call BORRA_JUGADOR		;si no lo sobrepasa, hará el movimiento, para ello despues se borra el jugador	
		dec [enemy_ren]			;se decrementa 1 a [enemy_ren]
		call IMPRIME_ESTRELLAS	;imprime las estrellas antes de la nave
		call IMPRIME_ENEMIGO	;se vuelve a imprimir enemigo
		call IMPRIME_JUGADOR	;se vuelve a imprimir jugador 
		ret
	endp

	MUEVE_ABAJO_ENEMIGO proc
		call DELETE_ESTRELLAS	;borra las estrellas 
		call BORRA_ENEMIGO		;si no lo sobrepasa, hará el movimiento, para ello primero se borra el jugador
		call BORRA_JUGADOR		;si no lo sobrepasa, hará el movimiento, para ello despues se borra el jugador	
		inc [enemy_ren]			;se incrementa 1 a [enemy_ren]
		call IMPRIME_ESTRELLAS	;imprime las estrellas antes de la nave
		call IMPRIME_ENEMIGO	;se vuelve a imprimir enemigo
		call IMPRIME_JUGADOR	;se vuelve a imprimir jugador 
		ret
	endp

	MUEVE_DERECHA proc
		call DELETE_ESTRELLAS	;borra las estrellas 
		call BORRA_JUGADOR		;si no lo sobrepasa, hará el movimiento, para ello primero se borra el jugador
		call BORRA_ENEMIGO		;si no lo sobrepasa, hará el movimiento, para ello despues se borra el ememigo	
		inc [player_col]		;se incrementa 1 a [player_col]
		call IMPRIME_ESTRELLAS 	;imprime las estrellas antes de la nave
		call IMPRIME_JUGADOR	;se vuelve a imprimri jugador 
		call IMPRIME_ENEMIGO	;se vuelve a imprimir enemigo
		ret
	endp

	MUEVE_DERECHA_ENEMIGO proc
		call DELETE_ESTRELLAS	;borra las estrellas
		call BORRA_ENEMIGO		;si no lo sobrepasa, hará el movimiento, para ello primero se borra el ememigo	
		call BORRA_JUGADOR		;si no lo sobrepasa, hará el movimiento, para ello despues se borra el enemigo
		inc [enemy_col]			;se incrementa 1 a [enemy_col]
		call IMPRIME_ESTRELLAS	;imprime las estrellas antes de la nave
		call IMPRIME_ENEMIGO	;se vuelve a imprimir enemigo
		call IMPRIME_JUGADOR	;se vuelve a imprimir jugador 
		ret
	endp

	MUEVE_IZQUIERDA proc
		call DELETE_ESTRELLAS	;borra las estrellas
		call BORRA_JUGADOR		;si no lo sobrepasa, hará el movimiento, para ello primero se borra el jugador
		call BORRA_ENEMIGO		;si no lo sobrepasa, hará el movimiento, para ello despues se borra el enemigo
		dec [player_col]		;se decrementa 1 a [player_col]
		call IMPRIME_ESTRELLAS 	;imprime las estrellas antes de la nave
		call IMPRIME_JUGADOR	;se vuelve a imprimir jugador 
		call IMPRIME_ENEMIGO	;se vuelve a imprimir enemigo
		ret 
	endp

	MUEVE_IZQUIERDA_ENEMIGO proc
		call DELETE_ESTRELLAS	;borra las estrellas
		call BORRA_ENEMIGO		;si no lo sobrepasa, hará el movimiento, para ello primero se borra el jugador	
		call BORRA_JUGADOR		;si no lo sobrepasa, hará el movimiento, para ello despues se borra el jugador
		dec [enemy_col]			;se decrementa 1 a [enemy_col]
		call IMPRIME_ESTRELLAS	;imprime las estrellas antes de la nave
		call IMPRIME_ENEMIGO	;se vuelve a imprimir enemigo
		call IMPRIME_JUGADOR	;se vuelve a imprimir jugador 
		ret
	endp

	;manda a imprimir el disparo. Se auxilia de col_aux y ren_aux
	IMPRIME_DISPARO proc
		mov al,[shot_col]
		mov ah,[shot_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		CALL PRINT_SHOT 
		ret
	endp

	;manda a imprimir el disparo enemigo. Se auxilia de col_aux y ren_aux
	IMPRIME_DISPARO_ENEMY proc
		mov al,[shot_col_enemigo]
		mov ah,[shot_ren_enemigo]
		mov [col_aux],al
		mov [ren_aux],ah
		CALL PRINT_SHOT_ENEMY
		ret
	endp

	;se imprime el disparo 
	PRINT_SHOT_ENEMY proc 
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 254d,cVerde,bgNegro
		ret 
	endp

	;se imprime el disparo 
	PRINT_SHOT proc 
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 254d,cAzulClaro,bgNegro
		ret 
	endp

	;Manda a borrar el disparo. Se auxilia de col_aux y ren_aux
	BORRA_DISPARO proc
		mov al,[shot_col]
		mov ah,[shot_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call DELETE_SHOT	
		ret
	endp

	;Manda a borrar el disparo enemigo. Se auxilia de col_aux y ren_aux
	BORRA_DISPARO_ENEMIGO proc
		mov al,[shot_col_enemigo]
		mov ah,[shot_ren_enemigo]
		mov [col_aux],al
		mov [ren_aux],ah
		call DELETE_SHOT_ENEMY	
		ret
	endp

	BORRA_DISPARO_COLISION proc
		mov al,[shot_col]
		mov ah,[shot_ren]
		cmp al,[shot_col_enemigo]
		je mismoColumna
		ret
		mismoColumna:
			cmp ah,[shot_ren_enemigo]
			je colision
			ret
				colision:
				mov [colision_disparos], 1d
				ret
	endp
		


	;borra el disparo. Se auxilia de col_aux y ren_aux
	DELETE_SHOT proc 
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cNegro,bgNegro
		ret 
	endp

	;borra el disparo. Se auxilia de col_aux y ren_aux
	DELETE_SHOT_ENEMY proc 
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 178,cNegro,bgNegro
		ret 
	endp


	;Verifica si el disparo se encuentra en la misma columna que la nave enemiga. Se auxilia de col_aux y ren_aux
	;En este procedimiento se obtiene la ubicación de la nave enemiga para posteriormente convocar al procedimiento que realizará la verificación a través del recorrido correspondiente
	;Ya que no deseamos modificar las coordenadas originales del enemigo, emplearemos a [col_aux] y a [ren_aux] para llevarlo a cabo
	DISPARO_EXITOSO proc
		mov al,[enemy_col]
		mov ah,[enemy_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call SUCCESFUL_SHOT
		ret
	endp

	DISPARO_EXITOSO_s proc
		mov al,[enemy_col]
		mov ah,[enemy_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		dec [ren_aux]
		call SUCCESFUL_SHOT
		ret
	endp

	DISPARO_EXITOSO_ENEMIGO proc
		mov al,[player_col]
		mov ah,[player_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call SUCCESFUL_SHOT_ENEMY
		ret
	endp

	DISPARO_EXITOSO_ENEMIGO_s proc
		mov al,[player_col]
		mov ah,[player_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		inc [ren_aux]
		call SUCCESFUL_SHOT_ENEMY
		ret
	endp

	;Realiza el recorrido del espacio que ocupa la nave enemiga. 
	;En caso de que el disparo comparta la misma posición que alguna parte de la nave enemiga, activa la bandera [aux_successfulShot]
	SUCCESFUL_SHOT proc
		
		CALL SUCCESSFUL_SHOT_COL_REN	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		inc [ren_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		inc [ren_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		sub [ren_aux],2					;línea para realizar el recorrido del espacio que ocupa la nave enemiga
		dec [col_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		inc [ren_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		dec [ren_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga
		dec [col_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento
		
		add [col_aux],3					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		inc [ren_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		dec [ren_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga
		inc [col_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		successful_shot_end:
		ret
	endp

	SUCCESFUL_SHOT_ENEMY proc
		
		CALL SUCCESSFUL_SHOT_COL_REN_ENEMY	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot_Enemy],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end_enemy			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		dec [ren_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN_ENEMY	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot_Enemy],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end_enemy			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		dec [ren_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN_ENEMY	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot_Enemy],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end_enemy			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		add [ren_aux],2					;línea para realizar el recorrido del espacio que ocupa la nave enemiga
		dec [col_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN_ENEMY	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot_Enemy],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end_enemy			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		dec [ren_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN_ENEMY	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot_Enemy],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end_enemy			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		inc [ren_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga
		dec [col_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN_ENEMY	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot_Enemy],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end_enemy			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento
		
		add [col_aux],3					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN_ENEMY	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot_Enemy],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end_enemy			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		dec [ren_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN_ENEMY	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot_Enemy],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end_enemy			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		inc [ren_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga
		inc [col_aux]					;línea para realizar el recorrido del espacio que ocupa la nave enemiga

		CALL SUCCESSFUL_SHOT_COL_REN_ENEMY	;llama al procedimiento que realiza las comparaciones para comprobar si el disparo fue exitoso
		cmp [aux_successfulShot_Enemy],1		;Esta comparación verifica que [aux_succesfulShot]=1, lo que indica que el disparo fue exitoso
		je successful_shot_end_enemy			;en caso de que la condición ([aux_succesfulShot]=1) de la comparación anterior se cumpla, salta al final del procedimiento

		successful_shot_end_enemy:
		ret
	endp

	;realiza las comparaciones pertintentes entre las coordenadas del disparo y de la nave enemiga
	;se ocupa a [col_aux] y a [col_ren] para representar la columna y renglón del enemigo
    SUCCESSFUL_SHOT_COL_REN proc
        mov al,[shot_col]				;al=columna que ocupa el disparo
        cmp al,[col_aux]				;¿al=columna que ocupa el enemigo?
        je clear_shot_col				;si lo anterior es cierto, la primer condición del disparo exitoso se cumple y saltamos a la siguiente comprobación
        jmp get_out_failure				;si no fue cierto, el disparo falló y saltamos al final fallido
        clear_shot_col:					;sección donde la columna de disparo es la misma que la nave enemiga
            mov ah,[shot_ren]			;ah=renglón que ocupa el disparo
            cmp ah,[ren_aux]			;¿ah=renglón que ocupa el enemigo?
            je get_out_success			;si lo anterior es cierto, la segunda y última condición del disparo exitoso se cumple y saltamos al final exitoso
            jmp get_out_failure			;si no fue cierto, el disparo falló y saltamos al final fallido
        get_out_success:				;final exitoso
            mov [aux_successfulShot],1	;activamos la variable que representa el éxito en el disparo del jugador
            ret						
        get_out_failure:				;final fallido
            mov [aux_successfulShot],0	;mantenemos apagada a la variable que representa el éxito en el disparo del jugador
            ret
    endp

	SUCCESSFUL_SHOT_COL_REN_ENEMY proc
        mov al,[shot_col_enemigo]				;al=columna que ocupa el disparo
        cmp al,[col_aux]				;¿al=columna que ocupa el JUGADOR?
        je clear_shot_col_enemy				;si lo anterior es cierto, la primer condición del disparo exitoso se cumple y saltamos a la siguiente comprobación
        jmp get_out_failure_enemy			;si no fue cierto, el disparo falló y saltamos al final fallido
        clear_shot_col_enemy:					;sección donde la columna de disparo es la misma que la nave enemiga
            mov ah,[shot_ren_enemigo]			;ah=renglón que ocupa el disparo
            cmp ah,[ren_aux]			;¿ah=renglón que ocupa el JUGADOR?
            je get_out_success_enemy			;si lo anterior es cierto, la segunda y última condición del disparo exitoso se cumple y saltamos al final exitoso
            jmp get_out_failure_enemy			;si no fue cierto, el disparo falló y saltamos al final fallido
        get_out_success_enemy:				;final exitoso
            mov [aux_successfulShot_Enemy],1	;activamos la variable que representa el éxito en el disparo del ENEMIGO
            ret						
        get_out_failure_enemy:				;final fallido
            mov [aux_successfulShot_Enemy],0	;mantenemos apagada a la variable que representa el éxito en el disparo del ENEMIGO
            ret
    endp

	;procedimiento que se lleva a cabo en caso de que se requiera un nuevo enemigo
	NUEVO_ENEMIGO proc
		add [player_score],100			;se aumenta la puntuación del jugador
		call IMPRIME_NUEVO_ENEMIGO		;se solicita la impresión de un nuevo enemigo
		call IMPRIME_SCORE				;se solicita la impresión del marcador actualizado
		mov ax,[player_score]			;ax=puntuación del jugador
		cmp ax,[player_hiscore]			;se compara la puntuación actual y la máxima
		ja new_hiscore					;si la puntuación actual es mayor que la máxima, saltamos a la sección de actualización
		ret
		new_hiscore:					;sección de actualización de la puntuación máxima
		mov [player_hiscore],ax			;puntuación máxima = puntuación actual
		call IMPRIME_HISCORE			;se imprime en pantalla dicha puntuación máxima
		ret
	endp

	NUEVO_JUGADOR proc
		call IMPRIME_NUEVO_JUGADOR		;
		call BORRA_LIVES
		CALL IMPRIME_LIVES
		ret
	endp

	;Imprime al enemigo nuevamente
	IMPRIME_NUEVO_ENEMIGO proc
		;Borrar posicion actual del enemigo y reiniciar su posicion
		;Imprime enemigo
		call IMPRIME_ENEMIGO
		ret
	endp


	IMPRIME_NUEVO_JUGADOR proc
		call IMPRIME_JUGADOR
		ret
	endp

	;procedimiento para imprimir la pantalla de inicio del juego 
	DIBUJA_HOME_SCREEN proc
		;imprimir esquina superior izquierda del marco
		posiciona_cursor 0,0
		imprime_caracter_color marcoEsqSupIzq,cAmarillo,bgNegro
		
		;imprimir esquina superior derecha del marco
		posiciona_cursor 0,79
		imprime_caracter_color marcoEsqSupDer,cAmarillo,bgNegro
		
		;imprimir esquina inferior izquierda del marco
		posiciona_cursor 24,0
		imprime_caracter_color marcoEsqInfIzq,cAmarillo,bgNegro
		
		;imprimir esquina inferior derecha del marco
		posiciona_cursor 24,79
		imprime_caracter_color marcoEsqInfDer,cAmarillo,bgNegro
		
		;imprimir marcos horizontales, superior e inferior
		mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh 
		horizontales:
		mov [col_aux],cl
		;Superior
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		
		mov cl,[col_aux]
		loop horizontales

		;imprimir marcos verticales, derecho e izquierdo
		mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h 
		verticales:
		mov [ren_aux],cl
		;Izquierdo
		posiciona_cursor [ren_aux],0
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor [ren_aux],79
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Limite mouse
		posiciona_cursor [ren_aux],lim_derecho+1
		imprime_caracter_color marcoVer,cAmarillo,bgNegro

		mov cl,[ren_aux]
		loop verticales

		;imprime intersecciones interna	
		posiciona_cursor 0,lim_derecho+1
		imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
		posiciona_cursor 24,lim_derecho+1
		imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro

		;imprimir [X] para cerrar programa
		posiciona_cursor 0,76
		imprime_caracter_color '[',cAmarillo,bgNegro
		posiciona_cursor 0,77
		imprime_caracter_color 'X',cRojoClaro,bgNegro
		posiciona_cursor 0,78
		imprime_caracter_color ']',cAmarillo,bgNegro

		;imprimir título
		posiciona_cursor 9,17
		imprime_cadena_color [titulo],6,cAzulClaro,bgNegro

		;imprimir mensaje de inicio
		posiciona_cursor 11,6
		imprime_cadena_color [carga_inicio],30,cCyan,bgNegro

		;imprime leyenda 
		posiciona_cursor 13,7
		imprime_cadena_color [chilaquiles],28,cBlanco,bgNegro
		posiciona_cursor 15,6
		imprime_cadena_color [derechos],29,cBlanco,bgNegro

		;imprimir instrucciones
		posiciona_cursor 2,lim_derecho+13
		imprime_cadena_color [instrucciones],13,cCyan,bgNegro

		posiciona_cursor 4,lim_derecho+3
		imprime_cadena_color [instruccion1],23,cBlanco,bgNegro

		posiciona_cursor 6,lim_derecho+3
		imprime_cadena_color [instruccion2],25,cBlanco,bgNegro

		posiciona_cursor 8,lim_derecho+3
		imprime_cadena_color [instruccion3],19,cBlanco,bgNegro

		;imprimir nota 
		posiciona_cursor 11,lim_derecho+3
		imprime_cadena_color [nota],34,cMagentaClaro,bgNegro

		;imprimiendo estrellas 
		call IMPRIME_ESTRELLAS
		call IMPRIME_JUGADOR
		ret 
	endp

	IMPRIME_ESTRELLAS proc
		posiciona_cursor 2,6
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 2,20
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 3,30
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 4,10
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 4,26
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 5,37
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 6,5
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 6,15
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 7,24
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 8,2
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 8,34
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 9,7
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 10,21
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 10,32
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 11,3
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 12,38
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 12,12
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 12,26
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 14,6
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 15,2
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 14,34
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 14,17
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 16,10
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 16,25
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 17,4
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 17,34
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 18,19
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 18,30
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 19,7
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 19,37
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 20,12
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 20,22
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 20,32
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 21,3
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 21,27
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 22,8
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		posiciona_cursor 22,35
		imprime_caracter_color 254d,cGrisClaro,bgNegro
		ret
	endp

	DELETE_ESTRELLAS proc
		posiciona_cursor 2,6
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 2,20
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 3,30
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 4,10
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 4,26
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 5,37
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 6,5
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 6,15
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 7,24
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 8,2
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 8,34
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 9,7
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 10,21
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 10,32
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 11,3
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 12,38
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 12,12
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 12,26
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 14,6
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 15,2
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 14,34
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 14,17
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 16,10
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 16,25
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 17,4
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 17,34
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 18,19
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 18,30
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 19,7
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 19,37
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 20,12
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 20,22
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 20,32
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 21,3
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 21,27
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 22,8
		imprime_caracter_color 254d,cNegro,bgNegro
		posiciona_cursor 22,35
		imprime_caracter_color 254d,cNegro,bgNegro
		ret
	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;FIN PROCEDIMIENTOS;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end inicio			;fin de etiqueta inicio, fin de programa
