<!---------------------------------------------------------------------------->
# TODO
<!---------------------------------------------------------------------------->

- make a compilation unit structure
    - look at Java class file structure
    - should be like:
        - module namespace
        - public labels
        - signals used
        - tags exported
        - const data
            - const strings, arrays, etc.
        - typedefs
        - functions
            - function name
            - sub-labels
            - stack frame requirements
            - parameter requirements
            - local variable requirements
            - code
        - behavior block
            - sub-labels
            - code




- make tests of the examples/tests/asm files
    - so that we can also run them after the parser tests

- add `ALLOC_LOCAL <slot>` opcode
    - needs to be called before using locals

- add `EXIT`
- add `SYSCALL`
- add `*_INT` opcodes
- add `JUMP_*` opcodes

<!---------------------------------------------------------------------------->
## Target Language
<!---------------------------------------------------------------------------->

```lisp


(:process (PingPong)




)







```















```lisp
;; type names are defined wihtin parens
(SomeName)
;; field/var names are defined within parens with type definition
(field_name <- int)

;; later those types can be referred too with a ^ prefix
[^SomeName]       ;; for typeclass definitions
(x <- ^SomeName)  ;; for argument or struct/class field definitions
.field_name       ;; fields are


<value> := <value> ;; assignment
 <name> <- <type>  ;; type definition

 :keyword ;; keywords start with a colon
 call:    ;; function calls end with a colon

;; struct
(:struct (<name>)
    (<field> <- <type>)
    ...)

;; function definition
(:fun <name> [ <arg> <- <type>, ... ] -> (<type>)
    (<body>))

;; typeclass
(:typeclass [<type>]
    (<method>)
    ...)

;; class
(:class (<name>)
    (<field> <- <type>)
    ...

    (<constructor>)

    (<method | public-method>)
    ...
)

;; method defintion (typeclass public, class private)
(<name> (<instance>) [ <arg> <- <type>, ... ] -> (<type>)
    (<body>))

;; class public method
(:pub <name> (<instance>) [ <arg> <- <type>, ... ] -> (<type>)
    (<body>))

;; constructors
;; if a name is given it is just a variable,
;; but if it is a field (prefixed with .) then
;; it will be automatically assigned to that field
(:new (<instance>) [<name|field> <- <type>] -> <type>
    (<body>))


```

```lisp
(:module (PingPong))

;; public struct
;; All fields are public
(:struct (Player)
    (name   <- *str)
    (score  <- *int)
    (wins   <- *int)
    (losses <- *int))

;; typeclass to operate on the struct type,
;; there is no way to directly instantiate this
;; only if you do it with the struct type
;; in square brackets (see below)
;; All methods are public and the fields
;; of the struct must be addressed through
;; the instance
(:typeclass [^Player]
    (inc-score (p) [] -> ()
        (p.score := (add: p.score 1)))

    (set-score (p) [ score <- *int ] -> () (p.score := score))
    (set-name  (p) [ name  <- *str ] -> () (p.name  := name ))
)

;; creating a struct instance, cannot call method on it ...
(:let (player_struct) := (new: ^Player (.name "One") (.score 0)))

;; creating a struct instance wrapped in a typeclass, and so
;; methods can be called on it ...
(:let (player_object) := (new: [^Player] (.name "One") (.score 0)))

;; call methods as normal
(player_object.inc-score)
;; the above implies this ...
(.inc-score: player_object ())
;; the typeclass is inferred from the player_object

;; and similarly
(player_object.set-score(10))
;; implies this
(.set-score player_object (10))

;; wrap struct instance with typeclass for this call
([player_struct].inc-score)
;; the same transform applies here
(.inc-score [player_struct] ())

;; note that this also works
(:let (p) := [player_struct])

;; wrap both of these ideas all into one, now the
;; class holds the struct state and methods internally
;; and it is no longer visible to the outside.
;;
;; In contrast to the struct/typeclass example, with
;; a class, you have chosen encapsulated storage, so
;; by default nothing is public and if you want it
;; to be public it must have the :pub keyword attached.
;;
;; within class methods you can use the .field shortcut
;; to implictly address the field via the current instance
;;
;; classes can also have a constructor, which is a nameless
;; method prefixed with the :new keyword. The first parameter
;; to this method is the already constructed instance and
;; it will be automatically returned from this method.
;;
(:class (Player)
    (name   <- *str)
    (score  <- *int)

    (:new (p) [.name <- *str] -> ^Player
        (.score  := 0))

    (:pub get-name   (p) [] -> () (.name))
    (:pub get-score  (p) [] -> () (.score))

    (:pub inc-score (p) [] -> ()
        (.score := (+: .score 1)))

    (:pub dec-score (p) [] -> ()
        (.score := (-: .score 1)))
)

;; a Player instance can be constructed with new:
(:let (player_object) := (new: ^Player (.name "One")))

(:class (Game)
    (player1   <- ^Player)
    (player2   <- ^Player)
    (game-over <- *bool)

    (:new (p) [] -> ^Game)

    (:pub start-game (g) [p1 <- ^Player, p2 <- ^Player] -> ()
        (.player1 := p1)
        (.player2 := p2)
        (.game-over := false))

    (:pub end-game (g) [] -> ()
        (.game-over := true))

    (:pub get-winner (g) [] -> *option[^Player]
        (:if (.game_over)
            (:if (<: (player1 .get-score) (player2 .get-score))
                (:return (option.some(player1)))
            (:else
                (:return (option.some(player2)))))
        (:else
            (:return (option.none)))))
)

(:protocol (PingPong)
    (`NewGame    <- (^Player, ^Player))
    (`GameOver   <- ())
    (`GetWinner  <- *promise[^Player]))

(:protocol (PingPong.Player)
    (`StartGame <- ^PingPong.Player)
    (`EndGame   <- ())
    (`Ping      <- ^PingPong.Player)
    (`Pong      <- ^PingPong.Player))

(:process [^PingPong]
    (:state
        (game <- ^Game)
        (p1   <- ^PingPong.Player)
        (p2   <- ^PingPong.Player))

    (:init []
        (game := (new: ^Game)))

    (:receive (msg)
        (:match (`NewGame (player1, player2))
            (p1 := (:spawn ^PingPong.Player (player1)))
            (p2 := (:spawn ^PingPong.Player (player2)))
            (game .start-game (player1, player2))
            (p1 ! `StartGame p2)
            (p2 ! `StartGame p1))
        (:match (`GameOver)
            (game .end-game)
            (p1 ! `EndGame)
            (p2 ! `EndGame))
        (:match (`GetWinner (reply-to))
            (:let (winner) := (game.get-winner)
                winner.map())
            (reply-to .resolve ( game.get-winner )))
    )
)

(:process [^PingPong.Player]
    (:state (player <- ^Player)

    (:init [p <- ^Player]
        (player := p))

    (:receive (msg)
        (:match (`StartGame (p))
            (p ! `Ping))
        (:match (`EndGame)
            )
        (:match (`Ping (p))
            (p ! `Ping))
        (:match (`Pong)
            )
    )
)




```
