
.is_even
    LOAD_ARG 0
    PUSH i(2)
    MOD_INT
    JUMP_IF_ZERO &is_even.true
        PUSH s("false")
    .is_even.true
        PUSH s("true")
        JUMP &is_even.return
    .is_even.return
        RETURN

.adder
    LOAD_ARG 0
    LOAD_ARG 1
    ADD_INT
    RETURN

.main
    PUSH i(2)
    PUSH i(2)
    CALL &adder, 2
    CALL &is_even, 1

    EXIT
