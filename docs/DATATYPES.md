<!---------------------------------------------------------------------------->
# Data Types
<!---------------------------------------------------------------------------->

## Primative Types

- NULL
    - an undefined value
- BOOL
    - two instances of this, TRUE and FALSE
- CHAR
    - a single character, this is still a numeric type
- INT
    - basic integer, we ignore sizes for now
- FLOAT
    - basic float, also ignore sizes for now
- ADDRESS
    - Some kind of address that points to something else
- TAG
    - this is just an INT underneath, but the
      name is also associated with it and both
      must match. This is for tags and singals.
- STRING
    - this is really a compound type, but can be treated
      as a single value

- VOID
    - used for returning nothing from a function
- PID
    - this is a ref for a Process

<!---------------------------------------------------------------------------->
## Data Operations
<!---------------------------------------------------------------------------->

All types can be compared for equality.

- EQ_NULL/1
- EQ_TRUE/1
- EQ_FALSE/1
- EQ_CHAR/2
- EQ_INT/2
- EQ_FLOAT/2
- EQ_TAG/2
- EQ_ADDRESS/2
- EQ_STRING/2
- EQ_VOID/1
- EQ_PID/2

All numeric based types (CHAR, INT, FLOAT, ADDRESS) can be compared to one another.

- LT_CHAR/2
- GT_CHAR/2

- LT_INT/2
- GT_INT/2

- LT_FLOAT/2
- GT_FLOAT/2

- LT_ADDRESS/2
- GT_ADDRESS/2

These types can also be incremented/decremented to traverse the range of values.

- INC_CHAR/1
- INC_INT/1
- INC_FLOAT/1
- INC_ADDRESS/1

- DEC_CHAR/1
- DEC_INT/1
- DEC_FLOAT/1
- DEC_ADDRESS/1

The actual numeric types (INT, FLOAT) can do math operations

- ADD_INT/2
- SUB_INT/2
- MUL_INT/2
- DIV_INT/2
- MOD_INT/2

- ADD_FLOAT/2
- SUB_FLOAT/2
- MUL_FLOAT/2
- DIV_FLOAT/2
- MOD_FLOAT/2

Strings have a seperate set of operations

- FORMAT_STRING/n
- CONCAT_STRING/2
- ...












<!---------------------------------------------------------------------------->
