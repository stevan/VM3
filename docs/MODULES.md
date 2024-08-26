<!---------------------------------------------------------------------------->
# Modules
<!---------------------------------------------------------------------------->

Modules are bundles of code, and need to be assembled first.

The Assembler will create an `executable` format, which can be either
bytes in a file, or some internal VM structure. This document does not
concern itself with the bytecode, as it would end up being loaded into
some kind of VM structure anyway.

<!---------------------------------------------------------------------------->
## Directives
<!---------------------------------------------------------------------------->

- `:module /name/space`
    - this sets the namespace for this module to be used when assembling
      other modules that use this namespace

- `:header` ... `:end`
    - this is the header section which contains the following directives

    - `@public '.label', &address`
        - creates a public label for a module function to be called
        - despite being public, this label is not exported
            - so it must be fully qualified when called
                - ex: `CALL &/name/space:label, 0`
        - if a label is not public, it cannot be called from outside

    - `@signals = ( ... )`
        - this is basically an enumeration of the signals to be used
        - signals are universal, so nothing needs to be qualified
        - the ordering is important
            - because it dictates the jump table used by the signal handler

    - `@tags = ( ... )`
        - this is an enumeration of the tags that can be used
        - ordering is also important, because of the message handler jump table
        - same as `@public`, it is not an export
            - so it must be fully qualified when called
                - ex: `SEND ^/name/space:tag, 0`

- `:function .label` ... `:end`
    - this just tells where a function starts and ends
        - it does not affect execution at all, just notation

- `:behavior` ... `:end`
    - this contains all the asnyc code
        - typically just the signal and message handler
        - but no reason it can't be more stuff ...
    - this also does not really affect execution, just notation

### Fully Qualified Names

Outside of a module you must use fully-qualified addressing ...

- `^/name/space:tag`
    - to refer to a tag from another namespace ...
- `&/name/space:label`
    - to refer to a label from another namespace ...

Signals are universal, so they do not need to be qualified. You cannot
create a label in another namespace, so there is no need for a `.` version.
You cannot access a variable from another namespace, so no need for a
`$` version.

<!---------------------------------------------------------------------------->
## Executable Format
<!---------------------------------------------------------------------------->

This will basically be an array in Perl

```
<p:address of spawn>
<p:address of despawn>
<i:num_signals>
%SIGNAL1
%SIGNAL2
<i:num_tags>
^tag1
^tag2
^tag3
<i:code_length>
@code ...
```

Since we have the code length here, we can also include other stuff later, but this is good for now.








