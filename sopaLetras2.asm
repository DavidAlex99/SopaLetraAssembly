INCLUDE "emu8086.inc"
name "Sopa de letras"
org 100h  

;-----------------  SECCION DATA 
.data
    matriz DB 'A','B','C','D','E', 'A','B','C','D','E', 'A','B','C','D','E', 'A','B','C','D','E', '1','1','1','1','1'
    matriz_length db 25 ; 5 filas * 5 columnas  
    
    entradabf DB 16, ?, 14 dup(0)  
    row_length db 5 
    numeroFila DB 0
    iteraLetrasFila db 0   ;una suma [SI] para la comparacion de las letras
    iteraLetrasMatriz db 0 ;la iteracion normal de las letras de la matriz 
    contadorFilas DB 0     ;variable temporal para almacenar el umero restante de filas
    
    iteraLetrasGlobal db 0  ;iterador de las letras de toda la matriz (REVISION)
    letraIteracion DB 0    ; variable de la letra que se va iterando  (REVISION)
;---------------- SECCION CODE
.code
;start:
    mov bx, offset matriz ; BX apunta al inicio de la matriz.
    mov ch, 5             ; CH es el número de filas.
    mov cl, row_length    ; CL es el número de columnas.  
    mov iteraLetrasFila, 0      ;iterador que cuenta el indicede  las letras de la matriz
    mov iteraLetrasMatriz, 0    ;iterador que iterar por el indice e los conruentes
    mov iteraLetrasGlobal, 0
    mov numeroFila, 0

print_matriz:
    push cx               ; Guardar CX porque lo usaremos para el bucle interno.
    mov cx, 5            ; Restablecer el contador de columnas para el bucle interno.
    
print_fila:
    mov dl, [bx]          ; DL es el carácter actual a imprimir.
    mov ah, 2             ; Función del servicio de interrupción para imprimir el carácter.
    int 21h               ; Realiza la interrupción.
    inc bx                ; Mueve BX al siguiente carácter.
    loop print_fila       ; Repite el bucle hasta que se hayan impreso todos los caracteres de la fila.

    ; Imprimir salto de línea después de cada fila.
    mov dl, 13            ; Carácter de retorno de carro.
    int 21h
    mov dl, 10            ; Carácter de nueva línea.
    int 21h
    
    pop cx                ; Recupera el contador original de filas y columnas.
    dec ch                ; Decrementa el contador de filas.
    jnz print_matriz      ; Continúa imprimiendo si aún hay filas.
    jmp game_loop
    
    PRINTN
    ret
    
    startl:
        mov ah, 1
        mov ch, 2bh
        mov cl, 0bh
        int 10h  
       
    game_loop:
        ;llamado del INPUT palabra del usuario
        call read_input
;end start

 
;------------- PROCEDIMIENTOS----------   
read_input:
        mov ah, 0Ah
        mov dx, offset entradabf
        int 21h  
           
    ;--- busqueda horizzontal 
    ;--- se empiezapor la primera fila            
    

; Buscar horizontalmente en la matriz
buscar_horizontal:
    mov bx, offset matriz ; BX apunta al inicio de la matriz.
    mov dl, 5 ; DL es la cantidad de filas.

recorrer_matriz_horizontal:
    mov cl, 0 ; CL sera la posicion de la letra de la fila que se esta tratando
    mov di, bx ; DI apunta al inicio de la fila actual para las comparaciones.

comparar_fila_actual:  
    cmp cl, 5
    je siguiente_fila
    ; Aquí iría el código para comparar la palabra ingresada con la parte de la fila
    ; Este código debería incluir la lógica para la comparación letra por letra y el manejo del stack si encuentras una coincidencia.
    ; ...
    CALL comparar_palabra
    
    
    ;ste valor esta gurdado en iteraLetrasMatriz
    ;Incrementa CL para moverse a la siguiente letra en la fila.
    inc cl
    mov iteraLetrasMatriz, cl                        
            
    
    ;jl comparar_fila_actual ; Si no es el final, sigue comparando en la fila actual.
    jmp comparar_fila_actual

comparar_palabra:
    ;se guarda el valor de CL (que es para iterar las letras en la fila de la matriz)
    mov iteraLetrasFila, cl
    mov contadorFilas, dl
    
    ;DL indice para comparar las letras dentro de comparar_palabra (no de fila)
    ;xor di, di 

    ;e CL solo se encuentra la iteracion de las letras de la matriz
    ;mov si, cx
    
    
    xor si, si
    xor di, di
    xor cx, cx
    cmp si, 0
    je itera_si
    
    jmp comparar_siguiente_letra  
    
    
itera_SI:
    ;se va a usar el SI para iterar las letras pero en comparar_palabra
    ;ya no en iterar pakabras pero de la fila (por el momento) 
    
    
    mov si, OFFSET entradabf 
    
    ;iteraLetrasMatriz tiene el valor del indice de la matriz general (la letra que esta iterando)
    mov al, iteraLetrasMatriz
    xor ah, ah
    mov di, OFFSET matriz
    add di, ax 
    ; de esta manera se asegura que el mismo indice que iteraLetrasMatriz sea el mismo para DI
    
    ;Para ir al tercer byte de entradabf que es donde empieza la palabra input
    add si, 2  
    ;CH sse guarda la longitud del input, cambiando a CH de CX aanterior
    mov ch, [entradabf + 1] 
    
    
comparar_siguiente_letra:
    ; se compara CL=letra que se va iterando (indice de la matriz)    
    ; CH= logitud del input
    cmp cl, ch 
    je todas_letras_coinciden 
    
    ;iteracion en la fila, BX es la direccion del princiipio matriz
    ; (despues ese BX) se sumaara para iterar a la sgt posicion caracter 
    mov al, [di] 
    
    ;---PRUEBA
    ;mov ah,2
    ;mov dl, al
    ;int 21h
    ;---PRUEBA
    
    mov dl, [si]
    
    ;---PRUEBA
    ;mov ah,2
    ;int 21h
    ;---PRUEBA
    
    ;se comparan los dos valores, NO SUS DIRECCIONES
    cmp al, dl
    
    ;se llama cuando las letras ya no coiciden 
    jne no_coincide   
    xor ah, ah   
    
    ;para que se guarde la memoria de la letra de la matriz 
    lea ax, [di]
    push ax
    inc di  
    inc si
    ;suma de las coincidencias
    add cl, 1
    ;ITERACION DE LAS LETRAS CUANDO SE BUSCA UNA PALABRA   
    mov iteraLetrasFila, cl
    jmp comparar_siguiente_letra
   
todas_letras_coinciden:
    ; Resaltar letras usando direcciones en el stack
    xor ch, ch      ; Recargar la longitud de la palabra ingresada, reset a 0
resaltar_letra:
    dec cl
    js fin_comparacion           ; Saltar si hemos resaltado todas las letras
    pop ax                       ; Sacar dirección de memoria de la letra
    ; Aqui el codigo para resaltar la letra en 'ax'
    ; ...
    jmp resaltar_letra

no_coincide:
    ; Vaciar el stack si no hay coincidencia completa 
    ; CL tiene la catidad de letras que se ingreso hasta este momento
    mov ch, [entradabf + 1]  
    ;se vuelve a comparar_fila_actual  
    ;pero antes reestablecemos valores de variables
    
    
    
vaciar_stack:
    dec cl
    js fin_comparacion           ; Saltar si el stack está vacío
    pop ax                       ; Sacar dirección del stack
    jmp vaciar_stack

fin_comparacion:  
    ;iteraletrasMatriz recordar que tiene la posicion de la letra que se estaba tratando actualmente
    ;para hacer la comparacion en ecorrer_fila_actual
    mov cl, iteraLetrasMatriz 
    
    ;sumar una unidad a iteraLetrasMatriz para comparar os consiguientes de la proxima letra
    ; de la fila que se esta tratando
    mov al, iteraLetrasMatriz
    add al, 1
    mov iteraLetrasMatriz, al
    xor al, al    
    
    ;recoradr que DI se usar para recorrer en el INPUT, suma posiciones, en la comparacion
    xor di, di 
    ;reestablecemos el cotador de fila
    mov dl, contadorFilas
    
    ;se vuelve a la funcion compara_fil_actual, para iterar la sgt letra    
    ret
     
siguiente_fila:   
    ;iteraLetrasMatriz es la ietaracion normal de las letras de la matroz de manera general
    ;cuando se llega a la fila, se suma 1 unidad para que haga cuenta de la proxima fila 
    ;mov al, iteraLetrasMatriz
    ;add al, 1 
    ;mov iteraLetrasMatriz, al  
    
    
    ;se obtiene la direcciones del 19 elemento de la matriz
    cmp bx, offset matriz[19]
    jle siguiente_fila_act  
    
    ; PENDIENTE
    ;que cuando se recorra los 5 elementos de la ultima fila que haga terminar la busqueda
    ;horizontal y empiece la vertical

    ret ; Terminamos la búsqueda horizontal. (PENDIENTE)

siguiente_fila_act:
    ;se suma el umero de elementos para bx, lo que signiifca 'ir a la siguiente fila' 
    xor cx, cx 
    xor di, di
    mov di, 7 ;numero de filas (TRATAMIENTO)  
    add bx, di  
    ; si aun no se llega a la ultima fila, pero antes devolvemos el valor
    ; a DL, que es el contador defilas
    mov dl, contadorFilas
    sub dl, 1 ; Decrementamos el contador de filas. 
    jmp comparar_fila_actual