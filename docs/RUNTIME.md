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

<!---------------------------------------------------------------------------->
## Component Design
<!---------------------------------------------------------------------------->

VM -> TimerWheel -> Scheduler -> RunQueue -> CPU

- VM
    - manages TimerWheel
    - manages Processes
        - create/destroy
    - manages CommunicationBus
        - how processes talk to one another
    - manages Scheduler
        - schedules processes to run, etc.
    - manages RunQueue
        - the work to be done
    - manages ProcessingEngine(s)
        - one or more virtual CPUs
        - executes work from the RunQueue

- TimerWheel
    - drives main clock cycle
    - handles timer events

- Process
    - has it's own program counter
    - has it's own Stack and Heap
    - has it's own input/output port for communication

- Communication Bus
    - a buffer managed by the VM to facilitate passing of messages

- Process Scheduler
    - groups things into different queues
        - READY   - will scehdule to run
        - YIELDED - waiting for a message
        - STOPPED - stopped and can be reaped

- RunQueue
    - this is a list of things to run on the processing engine (CPU)

- Processing Engine (CPU)
    - has Microcode instance
        - this determines the capabilities of the CPU
    - a Virtual CPU that can run code
    - given a Process to run ...
        - gets program counter from process
        - uses process's heap & stack
        - recieves messages from input-port
        - sends messsages to output-port

- Microcode
    - the actual instructions of the CPU
