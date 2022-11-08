define exit
    monitor quit
    quit
end

target remote localhost:1234
b test_main
c

