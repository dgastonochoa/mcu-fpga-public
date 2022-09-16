target remote localhost:1234
b _start
c
tui reg general

define exit
    monitor quit
    quit
end