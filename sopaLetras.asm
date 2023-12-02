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
    mov bx, offset matriz0 ;se empieza desde la primera fila
    mov si, 0              ;indice primerizo para comenzar          
              
recorrer_fila:  
    ;comprobacio si se llego al finl de la linea
    cmp si, 7
    je siguiente_fila
    
    
    inc si  ;incremeto del indice para el siguiente elemento  
            ;hasta que si no sea mayor que 7 se ejecutaara recorrer_fila
    jmp recorrer_fila  
    
siguiente_fila:
    ;prueba. aqui se esta tomao como que cada fila tiee 7 elementos
    add bx, 7 ;suma de 7 posiciones en la memoria
    mov si, 0    ;reestablecimiento del indice
    ; Comprobacion si se recorrio todas las filas
    cmp bx, offset matriz6+7  
    jle recorrer_fila





    ;---  busqueda verticla

;buscar_vertical:

    
    ;---- busqueda diagonal
;buscar diagonal:  





actTablero PROC near   
;para leer la entrada del usuario
    

actTablero ENDP


    

