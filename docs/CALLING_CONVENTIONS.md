
<!---------------------------------------------------------------------------->
# Calling Conventions
<!---------------------------------------------------------------------------->

Everything happens within the context of a process, meaning that there are
no globals, everything is stored in the process, it's registers, it's stack
and it's heap.

<!---------------------------------------------------------------------------->
## Process creation/destruction
<!---------------------------------------------------------------------------->

- SPAWN /process, `argc`
    - basically just syncronously calls the `.spawn` label of a `/process` namespace
        - the first argument will be the parent process
        - the argc tells how many additional arguments to send to `.spawn`
        - returns the process "ref" (or pointer)
    - if the process accepts %STARTING it will be sent to the process

- DESPAWN $ref
    - calls `.despawn` syncronously with the process
    - sends %TERMINATED to all processes that watched it

- Process can be in one of these states
    - READY     ... running
    - YEILDED   ... idling while waiting for sig/msg
    - BLOCKED   ... blocked, no msg, only sigs
    - SUSPENDED ... blocked, no msg, only sigs

- a process starts out in a YEILDED state where it is idle
    - if a signal or message is sent a process, it is places in the READY state

- when in the READY state
    - if there is a signal
        - jump to the `.signal` label and start running code
            - return control when either a SIG_IGNORE or SIG_RESUME is reached
            - ideally a singal handler is a simple bit of code (ex - to initialize variables)
            - but sometimes it must block (to WAIT), but it cannot YIELD, STOP or RESTART
    - if there is a message
        - jump to the process ENTRY address and start running code
            - return control when it encounters
                - YIELD
                    - make the process idle and waiting for a sig/msg
            - or block the process if it encounters
                - WAIT
                    - waiting for %TERMINATED signals from a process on the top of the stack
                    - this is a blocking state, nothing is processed until the
                      %TERMINATED signal is recieved
                - WAIT_ALL
                    - same as WAIT, but for all the process children
            - or suspend a process so that it can do internal stuff
                - STOP
                    - stop the actor from processing any more messages
                    - this sends the %STOPPING signal to the actor
                        - to do cleanup (maybe WAIT_CHILDREN)
                        - and should call DESPAWN on itself as the last thing
                            - which will send %TERMINATED signals
                - RESTART
                    - restart the actor
                    - this sends the %RESTARTING signal to the actor
                        - it can copy local state to the HEAP, etc.
                        - possibly call WAIT_CHILDREN if needed
                        -

<!---------------------------------------------------------------------------->
## Asyncronous Signals
<!---------------------------------------------------------------------------->

%STARTING   - sent when a process is first added to the VM
%STOPPING   - send when a process is going to stop
%RESTARTING - send when a process is restarted (by a supervisor)
%TERMINATED - send when a process is stopped to its parent process

Signals are processed asyncronously, but are delivered at the start of
every tick.

- NOTIFY ^SIGNAL
    - POP to
    - PUSH ^SIGNAL and to to the Signal bus

- SIG_RECV
    - if no signal
        - this will never really happen ...
    - if signal
        - sets the process to ready
        - POP ^SIGNAL from input
        - PUSH ^SIGNAL

Since signals have no body, there is nothing to put on the stack, etc.
And unlike messages, signals do not need to be accepted explicitly.

Once a SIG_RECV happens, and the signal handler is called, one of two
actions can be taken.

- SIG_IGNORE
    - ignores the signal and the processing resumes
- SIG_RESUME
    - the signal has been handled and processing resumes

When processing is resumed, if there is another signal it will be
processed before the messages can be processed.

<!---------------------------------------------------------------------------->
## Asyncronous Message Passing
<!---------------------------------------------------------------------------->

- SEND(^tag, argc)
    - POP to
    - POP the stack `argc` times and PUSH to output stack
    - PUSH `argc` to output stack
    - PUSH ^tag to output stack
    - PUSH `to` to the output stack

The runtime will remove the output from the sending process
and packages it into a msg on the communication bus.

The runtime advances to the next tick.

The runtime will take msg from the communication bus, peek
at the first item (the process), swaps it with the ^tag and
pushes it to the input stack for that process.

- RECV
    - if no input
        - set the process to yielded
        - will return to this address
    - if input
        - sets the process to ready
        - POP ^tag from input
        - PUSH ^tag

With the ^tag on the top of the stack, we can test it to
find which label to jump to. Since it is just an integer
it can be tested with those ops.

From here the message either needs to be accepted or rejected
which is done with the following ...

- MSG_REJECT
    - POP process from input
    - POP argc from input
    - POP from input `argc` times
    - send this all to the dead-letter-queue

- MSG_ACCEPT
    - POP process from input
    - POP argc from input
    - POP from input `argc` times
    - PUSH all the args
    - PUSH argc
    - PUSH the sender
    - set the MP (current message pointer)
        - this keeps track of where it is

From here the message can be inspect with:

- MSG_SENDER
    - reads mp - 1
- MSG_GET idx
    - reads (mp - 2) - idx


Once a message is processed, it should be discarded to clear
up the stack.

- MSG_DISCARD
    - this is like a commit point, the message must be at the
      top of the stack (MP == SP), and then we remove it.

<!---------------------------------------------------------------------------->
## Syncronous (Function) calls
<!---------------------------------------------------------------------------->

Functions can not be called from the top level, they can only be called
from within

- CALL(#label, argc)
    - PUSH argc
    - PUSH fp
    - PUSH pc
    - fp = sp
    - pc = #label

- RETURN
    - POP return_val
    - sp = fp
    - pc = POP pc
    - fp = POP fp
    - sp = sp - POP argc
    - PUSH return_val

- LOAD_ARG(idx)
    - PUSH stack[ (fp - 3) - idx ]

<!---------------------------------------------------------------------------->
## System calls
<!---------------------------------------------------------------------------->

- SYS_CALL(#name, argc)


<!---------------------------------------------------------------------------->


