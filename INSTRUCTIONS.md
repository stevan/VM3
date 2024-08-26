<!---------------------------------------------------------------------------->
# Instruction Set
<!---------------------------------------------------------------------------->

## Stack Ops

- PUSH
- POP
- PEEK
- SWAP
- DUP

## Const Ops

- CONST_NULL
- CONST_TRUE
- CONST_FALSE
- CONST_INT
- CONST_FLOAT
- CONST_CHAR
- CONST_STRING
- CONST_ARRAY

## Maths

- {ADD, SUB, MUL, DIV, MOD} for INT and FLOAT
- {INC, DEC} for INT, FLOAT and CHAR
- {INC_BY, DEC_BY} for INT, FLOAT and CHAR

## Equality

- EQ_{NULL,TRUE,FALSE,INT,FLOAT,CHAR}

## Comparisons

- LT_{INT,FLOAT,CHAR}
- LTE_{INT,FLOAT,CHAR}
- GT_{INT,FLOAT,CHAR}
- GTE_{INT,FLOAT,CHAR}

## Logical

- AND
- OR
- NOT

## Branching

- JUMP
- JUMP_IF_TRUE
- JUMP_IF_FALSE

- ADVANCE_BY

## Local Stack Access

- ALLOC_LOCAL
- FREE_LOCAL
- LOAD_LOCAL
- STORE_LOCAL

## Memory Ops

- ALLOC_MEM
- FREE_MEM

- LOAD_MEM
- STORE_MEM
- CLEAR_MEM
- COPY_MEM

## Module loader ops

- PUBLIC
- USE_SIGNAL
- EXPORT_TAG

## Process Ops

- ALLOC_PROCESS
- FREE_PROCESS

- SET_SIG_HANDLER

- ALLOC_CONSTANT
- FREE_CONSTANT

- SELF

- NUM_SIGNALS
- NUM_MESSAGES

## Function Call Ops

- LOAD_ARG
- CALL
- TAIL_CALL
- RETURN

## Async Call Ops

- SPAWN
- DESPAWN

- NEW_MSG
- SEND

- CMP_TAG

- RECV
- PEEK_MSG

- MSG_ACCEPT
- MSG_REJECT

- MSG_SENDER
- MSG_GET

- YIELD
- WAIT
- STOP

## Signal Ops

- SIG_RECV
- SIG_RESUME
- SIG_IGNORE

- NOTIFY

## Other stuff

- EXIT

<!---------------------------------------------------------------------------->


