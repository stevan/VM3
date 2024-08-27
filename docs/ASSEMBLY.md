<!---------------------------------------------------------------------------->
# Assembly
<!---------------------------------------------------------------------------->

<!---------------------------------------------------------------------------->
## Simplest Example
<!---------------------------------------------------------------------------->

```

.main
    PUSH s("Hello World ")        # [ "Hello World" ]
    SYS_CALL ::say, 2             # []
    EXIT


```

<!---------------------------------------------------------------------------->
## Less Simple Example
<!---------------------------------------------------------------------------->

Shortened Example with different assembler syntax, the `:actor` directive basically
desugars into the code immediately below it, and is compiled as a module.

```

:actor /greeter
    ^hello
        RECV                          # [ ^hello ]                                         MP = -1
        MSG_ACCEPT                    # [ "World", 1, \&main, ^hello ]                     MP = 3
        MSG_GET 0                     # [ "World", 1, \&main, ^hello, "World" ]            MP = 3
        PUSH s("Hello ")              # [ "World", 1, \&main, ^hello, "World", "Hello " ]  MP = 3
        SYS_CALL ::say, 2             # [ "World", 1, \&main, ^hello ]                     MP = 3
        MSG_DISCARD                   # []                                                 MP = -1
        STOP                          # []                                                 MP = -1
:end

.main
    SPAWN /greeter, 0             # [ \&greeter ]
    DUP                           # [ \&greeter, \&greeter ]
    PUSH s("World")               # [ \&greeter, \&greeter, "World" ]
    SWAP                          # [ \&greeter, "World", \&greeter ]
    SEND ^/greeter/hello, 1       # [ \&greeter ]
    WAIT                          # []

    PUSH s("Goodbye ")            # [ "Goodbye!" ]
    SYS_CALL ::say, 2             # []
    EXIT


```

```
:module /greeter

:header
    @tags = (
        ^hello
    )
:end

:function .spawn
    LOAD_ARG 0
    ALLOC_PROCESS
    SET_ENTRY &loop
    RETURN
:end

:function .despawn
    FREE_PROCESS
    RETURN
:end

:behavior

    # since we only have one tag, then we do not need a jump table
    # since it will always be 0 and so we can just process the message

    .loop
        RECV                          # [ ^hello ]                                         MP = -1
        MSG_ACCEPT                    # [ "World", 1, \&main, ^hello ]                     MP = 3
        MSG_GET 0                     # [ "World", 1, \&main, ^hello, "World" ]            MP = 3
        PUSH s("Hello ")              # [ "World", 1, \&main, ^hello, "World", "Hello " ]  MP = 3
        SYS_CALL ::say, 2             # [ "World", 1, \&main, ^hello ]                     MP = 3
        MSG_DISCARD                   # []                                                 MP = -1
        STOP                          # []                                                 MP = -1
:end

:end

.main
    SPAWN /greeter, 0             # [ \&greeter ]
    DUP                           # [ \&greeter, \&greeter ]
    PUSH s("World")               # [ \&greeter, \&greeter, "World" ]
    SWAP                          # [ \&greeter, "World", \&greeter ]
    SEND ^/greeter:hello, 1       # [ \&greeter ]
    WAIT                          # []

    PUSH s("Goodbye ")            # [ "Goodbye" ]
    SYS_CALL ::say, 2             # []

    EXIT                          # []


```

<!---------------------------------------------------------------------------->
## Complex Example
<!---------------------------------------------------------------------------->

### Usage of the module below ...

```

.main
    PUSH i(10)                     # [ 10 ]
    SPAWN /ping-pong, 1            # [ \&ping-pong[1] ]

    PUSH i(10)                     # [ \&ping-pong[1], 10 ]
    SPAWN /ping-pong, 1            # [ \&ping-pong[1], \&ping-pong[2] ]

    LOAD_LOCAL 0                   # [ \&ping-pong[1], \&ping-pong[2] ]
    SEND ^/ping-pong:new_game, 1   # []

    WAIT_CHILDREN                  # []
    EXIT                           # []

```

```
:module /ping-pong

:header

    @public '.spawn',   &spawn         # map the .spawn/.despawn functions
    @public '.despawn', &despawn       # to the internal addresses

    @signals = (
        %STARTING                      # ordering is important as this creates
        %RESTARTING                    # the jump table to be used by the sig_handler
    )

    @tags = (
        ^new_game                      # ordering here is important as well
        ^ping                          # because it too will be used to construct
        ^pong                          # the jump table used below
        ^end_game
        ^game_over
    )

:end

:function .spawn
    LOAD_ARG 0                         # the first arg is the parent process
    ALLOC_PROCESS                      # create a new child process of the parent

    ALLOC_LOCAL $max                   # allocate any local variables
    ALLOC_LOCAL $pings                 # on the process stack
    ALLOC_LOCAL $restarts              # ...

    LOAD_ARG 1                         # get the args to .spawn
    STORE_LOCAL $max                   # and store it in $max

    PUSH i(0)                          # set the initial value
    STORE_LOCAL $restarts

    SET_SIG_HANDLER &signal            # sets the sig handler entry address
    SET_ENTRY       &loop              # set the process entry address

    RETURN                             # and now return the new process
:end

:function .despawn
    FREE_LOCAL $max                    # locals are basically preserved areas
    FREE_LOCAL $pings                  # of the stack, so these are basically
    FREE_LOCAL $restarts               # just POP operations
    FREE_PROCESS                       # this removes it from the VMs process pool
    RETURN
:end

:behavior

.signal                                # a signal has arrived, and the tag is top of the stack
    DUP                                # duplicate it so we can use it to test ..

    NUM_SIGNALS                        # this should be 1 + the max index of SIGNALS
    LT_INT                             # if sig_tag is less than sig_count
    JUMP_IF_TRUE &_NO_SIG_MATCH        # jump to _NO_SIG_MATCH

    PUSH i(2)                          # since each `JUMP <addr>` expression in the table is 2 instructions
    MUL_INT                            # then we must multiply the tag to get the correct distance to jump
    ADVANCE_BY                         # now advance the $pc by the value on the stack (the sig tag)
        JUMP &STARTING                 # sig_tag = 0 * 2 = 0
        JUMP &RESTARTING               # sig_tag = 1 * 2 = 2

    ._NO_SIG_MATCH                     # If there was no match for the tag
        SIG_IGNORE                        # ignore the signal and do nothing ...
    .STARTING                          # If we have been started (.load was called)
        PUSH i(0)                      # initialize the local
        SET_LOCAL $pings               # for each new process
        SIG_RESUME
    .RESTARTING
        PUSH i(0)                      # re-initalize the bounce counter
        SET_LOCAL $pings               # ...
        GET_LOCAL $restarts            # but increment the restarts
        INC_INT                        # counter and then save it
        SET_LOCAL $restarts            # in the locals
        SIG_RESUME

.loop
    RECV                               # a message has arrived, and the tag is on the stack
    DUP                                # duplicate so we can use it in a test

    NUM_MESSAGES                       # this should be 1+ the max index of MESSAGES
    LT_INT                             # if msg_tag < max_messages
    JUMP_IF_TRUE &_NO_MSG_MATCH        # go to the _NO_MSG_MATCH

    PUSH i(2)                          # since each `JUMP <addr>` expression in the table is 2 instructions
    MUL_INT                            # then we must multiply the tag to get the correct distance to jump
    ADVANCE_BY                         # now advance the PC by msg_tag
        JUMP &new_game                 # jump table below, as with signals
        JUMP &ping                     # these must be in the same order as
        JUMP &pong                     # the regisgtered messages
        JUMP &end_game
        JUMP &game_over

    ._NO_MSG_MATCH                     # If there was no match for the msg_tag
        MSG_REJECT                     # reject the message (send to dead-letter-queue)
        YIELD &loop                    # yield back to the &loop

    .new_game #(PID)
        MSG_ACCEPT                     # accept the message
            MSG_GET, 0                 # get the other player
            SEND ^ping, 0              # construct a new ^ping message, with 0 body elements
        MSG_DISCARD                    # we are done with the message, this is like a `commit` statement
        YIELD &loop                    # yield back to the &loop

    .ping
        MSG_ACCEPT                     # accept the message
        MSG_SENDER                     # extract the sender

        CALL &pings_remaining, 0       # call the sub to see if we can still keep going
        JUMP_IF_FALSE &ping.max        # and if not, go to &ping.max

        SEND ^pong, 0                  # send ^pong to the SENDER
        JUMP &ping.commit              # jump the commit point

        .ping.max_reached              # if we reach the $max of $pings we are here
            SEND ^end_game, 0          # so we can just send ^end_game to the sender
                                       # and fall through into ping.commit
        .ping.commit
            MSG_DISCARD                # commit the message
            YIELD &loop

    .pong
        MSG_ACCEPT                    # accept the message
            MSG_SENDER                # get the sender from the message at the top of our stack
            SEND ^ping, 0             # make a new ^ping and send it ...
        MSG_DISCARD
        YIELD &loop

    .end_game
        MSG_ACCEPT                    # accept the message and send
            MSG_SENDER                # a ^game_over to the sender
            SEND ^game_over, 0
        MSG_DISCARD

        SELF                          # and a ^game_over to ourselves
        SEND ^game_over, 0

        YIELD &loop

    .game_over
        MSG_ACCEPT
        MSG_DISCARD
        STOP

:end

## Utility Functions ...

:function .pings_remaining
        LOAD_LOCAL $pings        # get the value of $pings   local
        INC_INT                  # increment it
        DUP                      # duplicate it for our test below
        STORE_LOCAL $pings       # store the new value in $pings

        LOAD_LOCAL $max          # load the constant $max
        LT_INT                   # and see if $pings   is less than $max
        RETURN                   # and return that boolean
:end

:end

```

<!---------------------------------------------------------------------------->
## Syntax Notes
<!---------------------------------------------------------------------------->

- `^tag`
    - tags are just offsets used internally by the process to dispatch
    - they must be exported by the process namespace
- `%SIGNAL`
    - there is a fixed set of signals for all processes
- `.label`
    - labels are absolute addresss into the code of a process
- `&label`
    - the address of the label, can be passed as an operand
- `/name/space`
    - the namespace of the code to call for the actor
        - this is kind of the address of a particular chunk of code
- `$var`
    - a name for a variable, is translated to idx for LOCAL values
- `:directive`
    - a directive is extra information for the assembler, such
      as `:module`, `:function` etc. along with a generic `:end`
      directive which will end the current directive
- `@public` & `@tags` & `@signals`
    - is a list of labels and tags to export, as well as signals to accept

