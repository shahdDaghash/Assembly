;Names:
;1191068 Tala AlSweiti
;1191448 Shahd Abu-Daghash

.model small

.data



; stating the sentences used to enter the 6 numbers
pleaseEnter6 db 0dh,0ah,"Please Enter 6 number:",0dh,0ah,"$"
pleaseEnter db 0dh,0ah,"please enter a number: ","$"
newLine db 0dh,0ah,"$"


;defining a variable num1 that stores the value to test if it's a number of one digit
num1 db ?                                                                            
;defining an array of length 6 that will store the numbers read
arr db 6 dup (?)

;defining variables needed when computing values
sum db 0
avg db 0
sdsum db 0
variance db 0
cnt db 0

;sentences needed when printing for clarification
summationstr db 0dh,0ah,"The sum is: ","$"
averagestr db 0dh,0ah,"The average is: ","$"
standarddeviation db 0dh,0ah,"The standard deviation is: ","$"

count equ 5 ;one less than array size to use it in bubble sorting
ascendingSort db 0dh,0ah,"Numbers in ascending order: ","$"
descendingSort  db 0dh,0ah,"Numbers in descending order: ","$"
maximum  db 0dh,0ah,"The max number is: ","$"
minimum  db 0dh,0ah,"The min number is: ","$"



; defining the error message for numbers
numError db 0dh,0ah,"The number you entered is not in the range from 0 to 9",0dh,0ah,"$"
;defining thank you for entering message
thanksForEntering db 0dh,0ah,"Thank you for entering all numbers",0dh,0ah,"$"
;defining choose operation sentence and the menu of the valid characters
selectTheOp db 0dh,0ah,"Please select the operation you need (v,x,n,d,a,e,s,l,q,r or ? for help): ","$"
menu db 0dh,0ah,"v for average",0dh,0ah,"x for max",0dh,0ah,"n for min",0dh,0ah,"e for standard deviation",0dh,0ah,"a to show numbers in ascending order",0dh,0ah,"d to show numbers in descending order",0dh,0ah,"s summation of all numbers",0dh,0ah,"l for all above",0dh,0ah,"q to quit",0dh,0ah,"r to enter 6 new numbers",0dh,0ah,"? for help",0dh,0ah,"$"
notChar db "Unrecognized character",0dh,0ah,"$"
sqrt db "sqrt(","$"





.stack 200
.code   
.startup  



 
;start by reading the six numbers   
call readnumbers
;here we find the sum and store it so it can be used in different places
call findTheSum

;this segment will be repeated until we q is ordered so we exit the program
begin:
;ask user to enter an operation
lea dx, selectTheOp
call printString

;reading the character entered by the user
call readchar
;value is stored in al

;check if the character equals the listed operations and go to the suitable procedure
cmp al,76h
je average
cmp al, 78h
je max
cmp al, 6Eh
je min
cmp al, 65h
je standard
cmp al, 61h
je ascending
cmp al, 64h
je descending
cmp al, 73h
je summation
cmp al, 6Ch
je all
cmp al, 71h
je quit
cmp al,72h
je new
cmp al,3Fh
je help

;if it's none of the above characters an error message will be printed
lea dx, notChar
call printString

;repeat the procedure
jmp begin

;if v was entered, the program will jump to this label and call the procedure
;then after finishing it will jump to the beginning to recieve a new character
;this goes same for the rest of operations
average:
call averagev
jmp begin

max:
call maxm
jmp begin

min:
call minn
jmp begin

standard:
call standarde
jmp begin

ascending:
call ascendinga
jmp begin

descending:
call descendingd
jmp begin

summation:
call summations
jmp begin

;here we call all the methods needed
all:
call averagev
call maxm
call minn
call standarde
call ascendinga
call descendingd
call summations
jmp begin

new:
call readnumbers
call findTheSum
jmp begin



help:
lea dx,menu
call printString
jmp begin 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;printing a string procedure
printString proc
    mov ah,09h
    int 21h
    ret
printString endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;reading a character procedure
readChar proc
    mov ah,01h
    int 21h
    ret
readChar endp


    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;reading all the 6 numbers
readnumbers proc
    ;we initialize the variables so there won't be false computations
    mov sum,0
    mov avg ,0
    mov sdsum,0
    mov variance,0
    mov cnt,0
    
    
    mov ax,@data
    mov ds,ax

    ;set cx to 6 to read 6 numbers through loop
    mov cx,6 
    ;storing the offset in an index register si to go throught the array
    mov si, offset arr

    ;sentence to ask the user to enter a new number
    lea dx,pleaseEnter6
    call printString   

    

    loop1:


    again:
    
    lea dx,pleaseEnter
    call printString


    call readChar
    sub al,30h
    mov num1,al


    call readChar
    ;compare the second reading with (enter) , if they're eqaul the first enterd number may be right , else it wont
    cmp al,13
    je valid   
    
    lea dx,numError
    call printString


    jmp again
    
    
    ; compare it with zero   
    valid:
    mov bl,num1
    cmp bl,0
    ; if the entered number equals 0 or is greater than 0 go to the next test
    jg test9
    je test9 
    
    ;else the number is less than 0 and so not a one digit number
    lea dx,numError
    call printString
    ;enter another number
    jmp again
    
    
    ;test if less than 9
    test9:
    cmp bl,9
    ;if the number is less than or equals 9 then it's valid since it's greater than 0
    jl valid1    
    je valid1
    ;else it's greater than 9 so we take another number
    lea dx,numError
    call printString
    ;enter another number
    jmp again
    
    
    ;one digit number greater than or equal to 0 and less than or equal to 9
    valid1:
    ;save it to the array
    mov [si],bl
    ;increment si by one to save the next number in the array
    inc si 
    
    mov dl,10
    mov ah,02h
    int 21h
    
    loop loop1
    
    
    
    mov dl,10
    mov ah,02h
    int 21h
    
    mov dl,13
    mov ah,02h
    int 21h
    
    ;after completing all the numbers we thank the user for entering all the numbers
    lea dx, thanksForEntering
    call printString
    
    ret
readnumbers endp            

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

findTheSum proc
    
    ;set cx to 6 to loop through the numbers and calculate the sum
    mov cx,6
    ;storing the offset in an index register si to go throught the array
    mov si,offset arr
    summ:
    ;move the value in the array to the register al in order to add it to the sum
    mov al,[si]
    ;add the value placed in al to the sum
    add sum,al
    ;increment si to go to the next value
    inc si
    
    ;repeat sum 6 times
    loop summ
    
    ret
findTheSum endp 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

summations proc
    
    ;print new line
    lea dx, newLine
    call printString
    
    ;print the statement for clarifications
    lea dx ,summationstr     
    call printString
    
    ;printing the value stored in sum(could be two digit number
    mov dh,0
    mov dl,sum
    mov ax,dx
    aam
    mov bx,ax  
    
    ;print char (the ten's digits)
    mov ah,02h 
    mov dl,bh
    add dl,30h 
    int 21h
    
    ;print the other digit 
    mov ah,02h
    mov dl,bl
    add dl,30h
    int 21h
       
    ;printing a new line
    lea dx,newLine
    call printString
    
    ret
summations endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


averagev proc
    
    
    ;printing a new line
    lea dx, newLine
    call printString
    
    lea dx ,averagestr     
    call printString
    
    
    ;set bl to 6 so we use it for division
    mov bl,6
    ;move the sum to al
    mov al,sum
    mov ah,0
    ; dividing al/bl and the value is stored in ah
    div bl
    ;move the value to the variable avg
    mov avg,ah
    
    ;print the number
    add al,30h
    mov ah,02h
    mov dl,al
    int 21h   
    
    lea dx,newLine
    call printString
    
    ret
averagev endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

standarde proc
    
    lea dx, newLine
    call printString
         
    ;loop 6 times
    mov cx,6
    mov si,offset arr
    
    ;setting sdsum to 0
    mov sdsum,0
    
    loops:
    ;compute the average
    mov bl,6
    mov al,sum
    mov ah,0
    div bl
    mov avg,al 
    
    mov bl,[si]
    
    ;avg-(array element)
    sub al,bl
    ;multiplying al*al and it will be saved in al as well
    mul al                               
    ;saving the value to sdsum that will be devided by 6 later on
    add sdsum,al
    ;incrementing si to dgo to the next element
    inc si
    
    
    loop loops
    
    ;;;;;;;;;;
    
    ;sdsum/6
    mov bl,6
    mov al,sdsum
    mov ah,0
    div bl
    ;save the result to the variable variance
    mov variance,al
    
    ;finding the root of the variance to get the standard deviation
    
    ;setting the loop to go until finding the root
    mov cl,variance
    ;set count to 0(this is the result since it's the square root
    mov cnt,0
    
    root:
    ;check if cnt*cnt==the variance
    ;then the value is the standard deviation
    mov al,cnt
    mul al
    cmp al,variance
    je yes
    inc cnt
    
    loop root
    
    ;if no number was found
    no:
    
    lea dx ,standarddeviation     
    call printString
    
    lea dx,sqrt
    call printString
    
    mov dh,0
    mov dl,variance
    mov ax,dx
    aam
    mov bx,ax
    mov ah,02h
    mov dl,bh
    add dl,30h
    int 21h 
    mov ah,02h
    mov dl,bl
    add dl,30h
    int 21h
    
    mov al,29h
    mov ah,02h
    mov dl,al
    int 21h
    
    lea dx,newLine
    call printString 
    
    jmp done
    
    
    ;if there exists a root
    yes:   
    lea dx ,standarddeviation     
    call printString
    
    ;print the value
    mov dh,0
    mov dl,cnt
    mov ax,dx
    aam
    mov bx,ax
    mov ah,02h
    mov dl,bh
    add dl,30h
    int 21h 
    mov ah,02h
    mov dl,bl
    add dl,30h
    int 21h
    
    lea dx,newLine
    call printString
    jmp done
    
    done:
    ret
standarde endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                              
;ascending order

ascendinga proc 
        
   mov dx, count
        oloop:
          mov cx, count
          lea si, arr
                                              
                                             
          bubbleSort:
             mov al, [si]                 ; Because compare can't have both memory locations
             cmp al, [si+1]
             jl noSwap                      ; if al is less than [si+1] Skip the below two lines for swapping.
             xchg al, [si+1]
             mov [si], al                    ; Coz we can't use two memory locations in xchg directly.
    
             noSwap:
               INC si
               loop bubbleSort
    
             dec dx
        jnz oloop
    
        mov dl,10
        mov ah,02h
        int 21h
        
        mov dl,13
        mov ah,02h
        int 21h
          
       lea dx ,ascendingSort     
       call printString  
       
       
       call printArray
    
    ret
    
ascendinga endp

;----------
     
;descending order

descendingd proc
    
        mov dx, count
        dloop:
            mov cx, count
            lea si, arr
                                              
                                             
            bubbleSortd:
                mov al, [si]                 
                cmp al, [si+1]
                jg noSwapd                      ; if al is greater than [si+1] Skip the below two lines for swapping.
                xchg al, [si+1]
                mov [si], al                    
    
                noSwapd:
                    INC si
                    loop bubbleSortd
    
          dec dx
          jnz dloop
    
       mov dl,10
       mov ah,02h
       int 21h
        
       mov dl,13
       mov ah,02h
       int 21h
          
       lea dx , descendingSort     
       call printString  
       
       
       call printArray
    
    
     ret
descendingd endp

;----------

;maximum proc

maxm proc
  
  ;use the descending sort code  
  mov dx, count
        maxloop:
            mov cx, count
            lea si, arr
                                              
                                             
            bubbleSortdmax:
                mov al, [si]                 
                cmp al, [si+1]
                jg noSwapmax                      
                xchg al, [si+1]
                mov [si], al                    
    
                noSwapmax:
                    INC si
                    loop bubbleSortdmax
    
          dec dx
          jnz maxloop
    
        mov dl,10
        mov ah,02h
        int 21h
        
        mov dl,13
        mov ah,02h
        int 21h  
        
    lea dx,maximum 
    call printString    
    
    ;print the first number after descending sorting 
    mov si,offset arr 
    mov dl,[si]  
    add dl,30h 
    mov ah,02h  
    int 21h  
     
    mov dl,10
    mov ah,02h
    int 21h
           
    ret
      
maxm endp
              

;----------              
 
;minimum proc
              
  minn proc
       ;use the ascending sort code 
       mov dx, count
        minloop:
            mov cx, count
            lea si, arr
                                              
                                             
            bubbleSortmin:
                mov al, [si]                
                cmp al, [si+1]
                jl noSwapmin                     
                xchg al, [si+1]
                mov [si], al                   
    
                noSwapmin:
                    INC si
                    loop bubbleSortmin
    
          dec dx
          jnz minloop
    
        mov dl,10
        mov ah,02h
        int 21h
        
        mov dl,13
        mov ah,02h
        int 21h
    
        lea dx,minimum 
        call printString 
        
    ;print the first number after ascending sorting 
        mov si,offset arr 
        mov dl,[si]  
        add dl,30h 
        mov ah,02h  
        int 21h  
    
    mov dl,10
    mov ah,02h
    int 21h
       
    ret
    
minn endp
        
        

;----------              
         
;to print the array                     
printArray proc

        
mov si,offset arr
mov cx,6
 
loop2:
    mov dl,[si] 
    add dl,30h
    mov ah,02h
    int 21h
    
    mov dl,32
    mov ah,02h
    int 21h
    
    inc si
    loop loop2
        
    mov dl,10
    mov ah,02h
    int 21h
        
    ret
printArray endp                                              
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

quit:
.exit
end 
