# HashEval

Copyright (C) Tim K 2021 <timprogrammer@rambler.ru>

Licensed under [MIT License](LICENSE).

## What is this thing all about?

**HashEval** is a Crystal library that converts stringified hashes that utilize only basic built-in types like ``String``,`` Int32``, etc into actual hashes. 

HashEval supports three forms of string-converted syntaxes:

- The default Crystal/Ruby one 

```crystal
{:salary => 12000, :currency => "RUB", :including_taxes => true}
```

- the simplified hash syntax supported by Crystal (which was originally introduced in Ruby 1.9)

```crystal
{salary: 12000, currency: "RUB", including_taxes: true}
```

- Haml's HTML-like attributes hash format

```haml
(salary=12000 currency="RUB" including_taxes)
```

## How do you use this?

First, include the library in your ``shard.yml`` file (that is, if you use shards):

```yaml
dependencies:
   hasheval:
      github: tenfensw/hasheval
```

Then just include it from your code and use the sole public method provided by the ``HashEval`` module:

```crystal
require "hasheval"

HashEval.eval("{\"chunky_bacon\" => false}") # => {"chunky_bacon" => false} <- Hash(String, Bool)
```

By the way, HashEval automatically detects the specified stringified hash format, so there is no need to worry about that as long as it is correctly syntaxed.

```crystal
HashEval.eval("{ruby: false, crystal: true}") # => {"ruby" => false, "crystal" => true} <- Hash(String, Bool)
```

Also, as you can see, due to Crystal limitations and strict typing system, symbols are always converted to strings when used as keys. There are also some other limitations, like no way to reference global variables or even constants as well as lack of support of arrays inside hashes or any types that are not `String`, `Bool`, `Int32`, `BigFloat` and `Nil`, but this might change in the future.

----

If HashEval encounters a syntax error, it throws a ``HashEval::ParsingException``:

```crystal
require "hasheval"

begin
	HashEval.eval("{\"referencing_a_var\" => variable1}") # invalid syntax
rescue ex : HashEval::ParsingException
	puts "Syntax error - #{ex}"
end
```

---

Oh, and HashEval also has a more readable `String` and `Hash` extension syntax:

```crystal
require "hasheval"

testhash = {:name => "Tim K", :os => "macOS"}
testhash_string = testhash.to_s

testhash_string.to_hash # same as HashEval.eval(testhash_string)
```

## Requirements

Basically, HashEval will run anywhere where at least Crystal 0.34.0 is supported. Older versions might work too, but they are untested.

## Unit tests

If you have this habit of testing if a library works after compilation before you install it, you can run the unit tests provided in this repo:

```bash
$ shards --ignore-crystal-version # get minitest
$ crystal unit/unit.cr
```