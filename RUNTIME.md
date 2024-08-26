<!---------------------------------------------------------------------------->
# Runtime
<!---------------------------------------------------------------------------->

The default entry point of the main executable is always `.main` and it should
always be an async function which is the single entry point.

The creation of the `/main` process is implicit within the VM, and serves as
the parent process for all subsequent processes.

The `/main` process cannot do much, if you want it to do more, make a module.

The `/main` process can accept messages, but you will need to make your own
jump tables for these. Again, it is recommended to not do this and to make
a module instead.

You can basically think of the `/main` process as being a module with the
`.main` label being the ENTRY point. The `.spawn` and `.despawn` functions
are handled internally since this process is special. There are no signal
handlers either, because no signals will be sent to it.

## Messages send to /main

When messages are sent to main, they can be inspected using the CMP_TAG op.

```

.main
    SPAWN /name/space
    SEND ^/name/space:request, 0

    RECV

    DUP
    PUSH ^/name/space:response
    CMP_TAG
    JUMP_IF_TRUE &handle_response
    MSG_REJECT
    JUMP &exit

    .handle_response
        MSG_ACCEPT
        # ... do something with the message
        MSG_DISCARD
        JUMP &exit

    .exit
        EXIT

```

