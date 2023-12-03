INCLUDE "emu8086.inc"
name "Sopa de letras"
org 100h  
;-----------------  SECCION DATA 
.data
    
    ; buffer que contedra la etrada del usuario           
    ;el primer byte, 16 es para la catidad maxima de caracteres menos 1 para el nulo
    ;el segundo byte es para la logitud del input
    ;14 bytes restantes es para el input que se ingresa
    entradabf DB 16, 0 
    
    matriz db 5*5 DUP(?)

    ; filas de la matriz 
    matriz0 DB '1','1','1','1','1','1','1'
    matriz1 DB '1','A','B','C','D','E','1'
    matriz2 DB '1','A','B','C','D','E','1'
    matriz3 DB '1','A','B','C','D','E','1'
    matriz4 DB '1','A','B','C','D','E','1'
    matriz5 DB '1','A','B','C','D','E','1'
    matriz6 DB '1','1','1','1','1','1','1'  
        ;Iteradores temporales
    iteraFilas DW 0
    iteraLetras DW 0
;----------------              
 
;---------------- SECCION CODE
.code

    ;ANTES DE ESTO PAA PONER MENSAJES 
    ;CALL CLEAR_SCREEN      
    pmatriz0:
        lea si, matriz0
        call print 
        
    pmatriz1:
        lea si, matriz1
        call print
        
    pmatriz2:
        lea si, matriz2
        call print
        
    pmatriz3:
        lea si, matriz3
        call print
        
    pmatriz4:
        lea si, matriz4
        call  print
        
    pmatriz5:
        lea si, matriz5
        call print
        
    pmatriz6:
        lea si, matriz6
        call print 
    
    ;cuado ya se termie de imprimiir el tablero, salta a este    
    endd:
        jmp game_loop
        
    ; rutina print en el que se imprime la matrizz, los 1 son paredes
    print:  
        mov cx, 7
        
    fila:
        cmp [si], '1'
        je pared
        PUTC [si]
        ;para aumentar el indice de la fila actual
        jmp indexPlus          
         
    pared:
        PUTC 219
        
    indexPlus:
        inc si
        
    loop fila
    
    PRINTN
    ret        

;-------------- CORAZON DEL JUEGO ----          
    startl:
        mov ah, 1
        mov ch, 2bh
        mov cl, 0bh
        int 10h  
       
    game_loop:
        ;llamado del INPUT palabra del usuario
        call read_input

; Para finalizar el juego cuando el usuario ingrese el boton ESC
    ;stop_game:
    ;    mov ah, 1
    ;    mov ch, 0bh
    ;    mov cl, 0bh
    ;    int 10h
    ;    ret

;-------------- FIN CORAZON DEL JUEGO ----------

;------------- PROCEDIMIENTOS----------   
read_input:
        mov ah, 0Ah
        mov dx, offset entradabf
        int 21h  
           
    ;--- busqueda horizzontal 
    ;--- se empiezapor la primera fila      
     
buscar_horizotal:   
    ; BX DIRECCION DE MEMORIA DE LA FILA PRIMERA
    mov bx, offset matriz0 ;se empieza desde la primera fila
    ; SI VARIABLE PARA ITEAR ELEMENTOS DE LA FILA (NO COMPARAR)
    mov si, 0              ;indice primerizo para comenzar          
              
recorrer_fila:  
    ;comprobacio si se llego al finl de la linea
    cmp si, 7
    je siguiente_fila
    
    ;aqui se hace la comparacion de la primera letra
    CALL comparar_palabra
    
    inc si  ;incremeto del indice para el siguiente elemento  
            ;hasta que si no sea mayor que 7 se ejecutaara recorrer_fila
    jmp recorrer_fila  

;para verificar si la lommgitud restane de la fila es myor que el del
;input del usuario    
verifica_longitud: 


; Asumiendo que BX apunta al inicio de la fila actual en la matriz
; y SI es el índice de la columna actual en esa fila
comparar_palabra:    

    ;guardamos el valor de si en iteraLetras para luego recuperarlo
    mov iteraLetras, si 
    
    ; INICIALIZAR CONTADORES 
    mov cl, [entradabf + 1]      ; CL = longitud de la palabra ingresada (si funciona)
    
    ;--PRUEBA ENSENANDO LONGITUD DEL INPUT
    mov ah, 02h 
    mov dl, cl 
    add dl, 30h  
    int 21h      
    ;--PRUEBA
    
    mov di, si                   ; DI = indice para seguir comparando en la matriz
    xor si, si
    mov si, 2                 ; reseteamos si para usar como valor iterador en la matriz
    xor ch, ch                   ; CH = contador de coincidencias

comparar_siguiente_letra:
    cmp ch, cl
    je todas_letras_coinciden    ; Si CH == CL, toda la palabra coincide 
    
    ;acceder     
    mov si, OFFSET entradabf
    add si, 2
    mov al, [si]
    
    
    ;--PRUEBA ENSENANDO LA  PRIMERA LETRA
    mov ah, 02h 
    mov dl, al 
    int 21h      
    ;--PRUEBA
    
    ;iteracio letra por  letra
    ;SI ahora tiene la direccion del INPUT  
    mov si, OFFSET entradabf
    add si, 3
    ;add si, di  
    ;--PRUEBA ENSENANDO SEGUNDA LETRA
    mov al, [si]
    mov ah, 02h 
    mov dl, al  
    int 21h      
    ;--PRUEBA

    cmp al, dl 
    xor ah, ah
    jne no_coincide
    ; Guardar dirección en el stack
    lea ax, [si]
    push ax
    inc di                       ; incrementa la siguiente letra en la misma ila, por funcion palabra
    inc ch                       ;incrementa en una unidad la coincidencia
    jmp comparar_siguiente_letra 
    
aumentar_iteracion:
    add si, 1
    

todas_letras_coinciden:
    ; Resaltar letras usando direcciones en el stack
    mov ch, [entradabf + 1]      ; Recargar la longitud de la palabra ingresada
resaltar_letra:
    dec ch
    js fin_comparacion           ; Saltar si hemos resaltado todas las letras
    pop ax                       ; Sacar dirección de memoria de la letra
    ; Aqui el codigo para resaltar la letra en 'ax'
    ; ...
    jmp resaltar_letra

no_coincide:
    ; Vaciar el stack si no hay coincidencia completa
    mov ch, [entradabf + 1]
vaciar_stack:
    dec ch
    js fin_comparacion           ; Saltar si el stack está vacío
    pop ax                       ; Sacar dirección del stack
    jmp vaciar_stack

fin_comparacion:   
    mov si, iteraLetras
    ret                          ;aqui se tedria que mover a recorrer_fila

    
    
siguiente_fila:
    ;prueba. aqui se esta tomao como que cada fila tiee 7 elementos
    add bx, 7 ;suma de 7 posiciones en la memoria
    mov si, 0    ;reestablecimiento del indice
    ; Comprobacion si se recorrio todas las filas
    cmp bx, offset matriz6+7  
    jle recorrer_fila


    

