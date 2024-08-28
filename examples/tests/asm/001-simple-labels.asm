
.adder
    LOAD_ARG 0
    LOAD_ARG 1
    ADD_INT
    RETURN

.main
    PUSH i(2)
    PUSH i(2)
    CALL &adder, 2

    EXIT
