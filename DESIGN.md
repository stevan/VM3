

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









