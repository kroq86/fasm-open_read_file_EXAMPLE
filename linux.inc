; Copyright 2024 Alexey Kutepov <reximkut@gmail.com>
; Permission is hereby granted, free of charge, to any person obtaining
; a copy of this software and associated documentation files (the
; "Software"), to deal in the Software without restriction, including
; without limitation the rights to use, copy, modify, merge, publish,
; distribute, sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so, subject to
; the following conditions:

; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

SYS_read equ 0
SYS_write equ 1
SYS_exit equ 60
SYS_accept equ 43
SYS_close equ 3

STDOUT equ 1
STDERR equ 2

EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1

macro funcall1 func, a
{
    mov rdi, a
    call func
}

macro funcall2 func, a, b
{
    mov rdi, a
    mov rsi, b
    call func
}

macro funcall4 func, a, b, c, d
{
    mov rdi, a
    mov rsi, b
    mov rdx, c
    mov r10, d
    call func
}

macro syscall1 number, a
{
    mov rax, number
    mov rdi, a
    syscall
}

macro syscall2 number, a, b
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    syscall
}

macro syscall3 number, a, b, c
{
    mov rax, number
    mov rdi, a
    mov rsi, b
    mov rdx, c
    syscall
}


macro exit code
{
    mov rax, SYS_exit
    mov rdi, code
    syscall
}
