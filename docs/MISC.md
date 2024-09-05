
```
    fun int-stream {
        var x = 0;
        while (1) {
            yield $x;
            $x++;
        }
    }

    var s = int-stream()
    say s.call() # 0
    say s.call() # 1
    say s.call() # 2
    say s.call() # 3
```

```
    .int-stream
        ALLOCATE_LOCALS 1     ; allocate a local for our iterator
        STORE 0, i(0)         ; store int(0) into the first local
        .loop                 ; top of the loop
            LOAD 0            ; load the first local variable onto the stack
            YIELD             ; yield the value at the top of the stack
            SUSPEND           ; suspend the function
            ; resume here
            LOAD 0            ; load the first local variable (our counter)
            INC_INT           ; increment that value
            STORE 0           ; store the value
            JUMP &loop        ; now we loop again


    .main
        ALLOCATE_LOCALS 1     ; allocate a local for our async frame

        ASYNC &int-stream, 0  ; call int-stream async
        STORE 0               ; store the returned async frame

        LOAD 0                ; load the call frame
        AWAIT                 ; await a yielded value = 1

        LOAD 0                ; load the call frame
        RESUME                ; resume the call frame

        LOAD 0                ; load the call frame
        AWAIT                 ; await a value = 2
```
