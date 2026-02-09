---
title: Ddeep dive into Ruby'
date: 2026-02-09
tags: [ruby, programming-languages, internals, metaprogramming]
categories: ["Engineering"]
searchable: true
description: "A deep dive into how Ruby works — from syntax fundamentals to object model internals, garbage collection, and metaprogramming."
draft: false
---

Ruby is a dynamic, interpreted, object-oriented language designed by Yukihiro "Matz" Matsumoto in the mid-1990s. Its design philosophy prioritizes developer happiness and productivity — Matz famously said Ruby is *"optimized for developer joy."* Under the hood, Ruby is a surprisingly sophisticated language with a rich object model, a multi-phase interpreter pipeline, and powerful metaprogramming capabilities that let you reshape the language itself at runtime.

These notes cover Ruby from the ground up: the syntax fundamentals, how the interpreter turns your source code into executable instructions, how memory is managed, and the metaprogramming system that makes Ruby one of the most flexible languages in existence.

---

## Ruby Syntax Fundamentals

### Printing

Ruby provides two primary methods for output:

```ruby
puts "Hello"   # prints with a trailing newline (\n)
print "World"  # prints inline, no trailing newline
p "Debug"      # prints the .inspect representation (useful for debugging)
```

- **`puts`**: calls `.to_s` on the argument, appends `\n`. Returns `nil`.
- **`print`**: same as `puts` but without the newline.
- **`p`**: calls `.inspect` on the argument — shows the raw representation (e.g., strings include quotes). Returns the object itself, which makes it useful in method chains during debugging.

> **Note:** There's also `pp` (pretty-print), introduced in Ruby 2.5 as a built-in, which formats complex objects (hashes, arrays) with indentation for readability.

### Variables

Ruby uses **duck typing** — variables don't have explicit type declarations. The interpreter infers the type at runtime:

```ruby
name    = "Umberto"   # String
age     = 23          # Integer (Fixnum in Ruby < 2.4, Integer in 2.4+)
gpa     = 4.0         # Float
is_tall = true        # TrueClass
nothing = nil         # NilClass
```

#### Variable Scopes

Ruby determines variable scope by naming convention — the prefix of a variable name defines where it lives:

| Prefix | Scope | Example |
|---|---|---|
| (none) | Local | `name = "Umberto"` |
| `@` | Instance variable | `@name = "Umberto"` |
| `@@` | Class variable | `@@count = 0` |
| `$` | Global variable | `$debug = true` |
| `A-Z` (uppercase start) | Constant | `PI = 3.14159` |

- **Local variables** are scoped to the block, method, or module where they are defined.
- **Instance variables** belong to a specific object instance — they are the primary way objects hold state.
- **Class variables** are shared across all instances of a class *and* its subclasses — use with caution, as subclass modifications affect the parent.
- **Global variables** are accessible everywhere — generally considered bad practice because they introduce hidden coupling.
- **Constants** are meant to be immutable, but Ruby only raises a *warning* (not an error) if you reassign them.

#### Type Casting

Ruby provides explicit conversion methods on most objects:

```ruby
double_number = 3.14
integer       = double_number.to_i    # => 3  (truncates, does not round)
back_to_float = integer.to_f          # => 3.0
as_string     = back_to_float.to_s    # => "3.0"
```

Ruby distinguishes between **explicit** and **implicit** conversion:
- **Explicit** (`to_i`, `to_s`, `to_f`): lenient — tries its best to convert, returns a default if it can't (e.g., `"hello".to_i` returns `0`).
- **Implicit** (`to_int`, `to_str`, `to_ary`): strict — only defined on objects that *truly are* that type. Ruby calls these internally when it needs a guaranteed type match. If an object doesn't respond to `to_str`, Ruby raises a `TypeError` instead of silently converting.

### Strings

Strings in Ruby are **mutable by default** (unlike Python or Java):

```ruby
greeting = "Hello"
greeting[0] = "J"
puts greeting            # => "Jello"

puts greeting.length     # => 5
puts greeting[0]         # => "J"
puts greeting.include?("llo")  # => true
puts greeting[1, 3]      # => "ell" (start index, length)
```

#### String Interpolation vs Concatenation

```ruby
name = "Umberto"

# Interpolation (double quotes only — preferred)
puts "Hello, #{name}!"         # => Hello, Umberto!

# Concatenation
puts "Hello, " + name + "!"   # => Hello, Umberto!
```

Interpolation automatically calls `.to_s` on the expression inside `#{}`. It is faster than concatenation because it avoids creating intermediate String objects.

#### Frozen Strings and Immutability

Since Ruby 2.3, you can opt into **frozen string literals** by adding a magic comment at the top of a file:

```ruby
# frozen_string_literal: true

name = "Umberto"
name << " Ciccia"   # => FrozenError: can't modify frozen String
```

This is a performance optimization — frozen strings can be deduplicated in memory. Rails and most modern Ruby projects enable this by default. In Ruby 3.x, there are ongoing discussions about making this the default behavior.

#### Symbols vs Strings

```ruby
:name           # Symbol — immutable, one copy in memory
"name"          # String — mutable, new object each time
"name".freeze   # String — immutable but only after freeze is called
```

- **Symbols** are interned — `:name.object_id` always returns the same value. They are ideal for hash keys, method names, and identifiers.
- **Strings** allocate a new object every time (unless frozen). Use them for data that changes or comes from user input.

### Numbers

```ruby
puts 2 + 3     # => 5
puts 2 * 3     # => 6
puts 2 / 3     # => 0     (integer division!)
puts 2.0 / 3   # => 0.666... (float division)
puts 2 % 3     # => 2
puts 2 ** 10   # => 1024  (exponentiation)

num = -36.8
puts num.round  # => -37
puts num.ceil   # => -36
puts num.floor  # => -37
puts num.abs    # => 36.8
```

> **Note:** In Ruby, numbers are objects too. `5.times { |i| puts i }` is valid because `5` is an instance of `Integer`, and `times` is a method on `Integer`. Even numeric literals are objects — this is central to Ruby's "everything is an object" philosophy.

### Arrays

```ruby
friends = []
friends.push("Oscar")         # => ["Oscar"]
friends << "Marco"            # => ["Oscar", "Marco"]  (shovel operator)
friends.include?("Oscar")     # => true
friends.pop                   # => "Marco" (removes and returns last element)
friends.delete("Oscar")       # => "Oscar" (removes by value)
```

#### Useful Array Methods

```ruby
nums = [3, 1, 4, 1, 5, 9, 2, 6]

nums.sort               # => [1, 1, 2, 3, 4, 5, 6, 9]
nums.uniq               # => [3, 1, 4, 5, 9, 2, 6]
nums.select { |n| n > 3 }  # => [4, 5, 9, 6]
nums.map { |n| n * 2 }     # => [6, 2, 8, 2, 10, 18, 4, 12]
nums.reduce(:+)            # => 31
nums.flatten               # flattens nested arrays
nums.compact               # removes nil values
nums.zip([:a, :b, :c])    # pairs elements: [[3,:a],[1,:b],[4,:c]]
```

Ruby arrays are **heterogeneous** — they can hold objects of different types: `[1, "hello", :sym, nil, [2, 3]]`.

### Hashes (Dictionaries)

```ruby
test_grades = {
  "Andy"    => "Jassy",
  "Umberto" => "Ciccia",
  3         => 23
}

puts test_grades["Umberto"]  # => "Ciccia"
puts test_grades[3]          # => 23
```

#### Modern Symbol-Key Syntax (Ruby 1.9+)

```ruby
# Old hash-rocket syntax
config = { :host => "localhost", :port => 3000 }

# Modern shorthand (when keys are symbols)
config = { host: "localhost", port: 3000 }

config[:host]    # => "localhost"
config.fetch(:port, 8080)  # => 3000 (with default fallback)
```

#### Useful Hash Methods

```ruby
config.keys          # => [:host, :port]
config.values        # => ["localhost", 3000]
config.merge(ssl: true)  # => { host: "localhost", port: 3000, ssl: true }
config.each { |k, v| puts "#{k}: #{v}" }
config.select { |k, v| v.is_a?(Integer) }  # => { port: 3000 }
```

### Methods

```ruby
def add_numbers(num1, num2 = 0)
  num1 + num2   # implicit return — last expression is returned
end
```

Ruby has **implicit returns** — the value of the last evaluated expression in a method is automatically returned. Explicit `return` is only needed for early exits.

#### Variadic Arguments

```ruby
def log(*messages)
  messages.each { |msg| puts "[LOG] #{msg}" }
end

log("Starting", "Processing", "Done")
```

#### Keyword Arguments (Ruby 2.0+)

```ruby
def connect(host:, port: 3000, ssl: false)
  puts "Connecting to #{host}:#{port} (SSL: #{ssl})"
end

connect(host: "example.com", ssl: true)
```

#### Blocks, Procs, and Lambdas

This is one of Ruby's most powerful features. **Blocks** are anonymous chunks of code that can be passed to methods:

```ruby
# Block with do...end (multi-line convention)
[1, 2, 3].each do |n|
  puts n * 2
end

# Block with curly braces (single-line convention)
[1, 2, 3].each { |n| puts n * 2 }
```

**Procs** are blocks stored as objects:

```ruby
doubler = Proc.new { |n| n * 2 }
doubler.call(5)   # => 10
doubler.(5)       # => 10 (shorthand)
doubler[5]        # => 10 (another shorthand)
```

**Lambdas** are stricter Procs:

```ruby
doubler = ->(n) { n * 2 }   # lambda literal (Ruby 1.9+ syntax)
doubler.call(5)              # => 10
```

| Feature | Proc | Lambda |
|---|---|---|
| Arity check | No — ignores extra args, assigns `nil` to missing ones | Yes — raises `ArgumentError` on mismatch |
| `return` behavior | Returns from the *enclosing method* | Returns from the *lambda itself* only |

#### The Yield Keyword

Methods can invoke a passed block with `yield`:

```ruby
def with_logging
  puts "Starting..."
  result = yield
  puts "Finished with: #{result}"
end

with_logging { 2 + 2 }
# Output:
# Starting...
# Finished with: 4
```

You can check if a block was given with `block_given?`:

```ruby
def maybe_yield
  if block_given?
    yield
  else
    puts "No block provided"
  end
end
```

### Conditionals

```ruby
if is_student && is_smart
  puts "Smart student"
elsif is_student && !is_smart
  puts "Student, not smart"
else
  puts "Not a student"
end
```

#### Case/When (Pattern Matching)

```ruby
grade = "A"
case grade
when "A"
  puts "Excellent"
when "B", "C"
  puts "Good"
else
  puts "Invalid"
end
```

In Ruby 2.7+ **pattern matching** was introduced with `case/in`:

```ruby
response = { status: 200, body: "OK" }

case response
in { status: 200, body: String => body }
  puts "Success: #{body}"
in { status: 404 }
  puts "Not found"
in { status: (500..) }
  puts "Server error"
end
```

Pattern matching allows destructuring, guard clauses, and type checking — it's one of the most powerful recent additions to the language.

### Loops

```ruby
# While loop
index = 1
while index <= 5
  puts index
  index += 1
end

# Until loop (inverse of while)
index = 1
until index > 5
  puts index
  index += 1
end

# For-in loop
for index in 0..5    # Range: 0 to 5 inclusive
  puts index
end

# Times loop
5.times { |i| puts i }   # 0 through 4

# Each (idiomatic Ruby — preferred over for-in)
lucky_numbers = [0, 1, 2, 3]
lucky_numbers.each do |lucky|
  puts lucky
end

# Each with index
lucky_numbers.each_with_index do |num, idx|
  puts "#{idx}: #{num}"
end
```

> **Note:** Idiomatic Ruby avoids `for` loops entirely. The `.each` method with a block is the standard iteration pattern. `for` leaks its iterator variable into the surrounding scope, whereas `.each` keeps it contained inside the block.

### Exception Handling

```ruby
begin
  num = 10 / 0
rescue ZeroDivisionError => e
  puts "Error: #{e.message}"
rescue StandardError => e
  puts "Something else went wrong: #{e.message}"
ensure
  puts "This always runs (like 'finally')"
end
```

#### Custom Exceptions

```ruby
class InsufficientFundsError < StandardError
  def initialize(amount)
    super("Insufficient funds: need #{amount} more")
  end
end

def withdraw(balance, amount)
  raise InsufficientFundsError.new(amount - balance) if amount > balance
  balance - amount
end
```

The exception hierarchy matters — always rescue the **most specific** exceptions first. Ruby's hierarchy:

```
Exception
├── NoMemoryError
├── ScriptError
│   ├── LoadError
│   ├── SyntaxError
│   └── NotImplementedError
├── SignalException
│   └── Interrupt
└── StandardError          ← rescue catches this by default
    ├── RuntimeError
    ├── TypeError
    ├── ArgumentError
    ├── NameError
    │   └── NoMethodError
    ├── ZeroDivisionError
    ├── IOError
    └── ...
```

> **Note:** Never rescue bare `Exception` — it catches `Interrupt` (Ctrl+C) and `NoMemoryError`, which makes your program extremely hard to stop. Always rescue `StandardError` or more specific subclasses.

---

## Classes and the Object Model

### Defining a Class

```ruby
class Book
  attr_accessor :title, :author

  def initialize(title, author)
    @title  = title
    @author = author
  end

  def read_book
    puts "Reading #{@title} by #{@author}"
  end
end

book = Book.new("DDIA", "Martin Kleppmann")
book.read_book  # => Reading DDIA by Martin Kleppmann
```

#### Attribute Accessors

Ruby doesn't have public fields — instance variables (`@title`) are **always private**. You access them through methods. Ruby provides shorthand macros:

```ruby
attr_reader   :title            # generates: def title; @title; end
attr_writer   :title            # generates: def title=(val); @title = val; end
attr_accessor :title            # generates both reader and writer
```

These are actually **metaprogramming calls** — `attr_accessor` is a method on `Module` that dynamically defines getter/setter methods at class definition time.

### Inheritance

```ruby
class Animal
  def make_sound
    puts "Generic sound"
  end
end

class Dog < Animal
  def make_sound    # overrides Animal#make_sound
    puts "Woof"
  end
end

dog = Dog.new
dog.make_sound  # => "Woof"
```

Ruby uses **single inheritance** — a class can only inherit from one parent. But it compensates with **mixins** (modules), which provide a form of multiple inheritance without the diamond problem.

#### The `super` Keyword

```ruby
class Dog < Animal
  def make_sound
    super              # calls Animal#make_sound
    puts "...and Woof!"
  end
end
```

- `super` without arguments forwards all arguments from the current method.
- `super()` with empty parentheses calls the parent with *zero* arguments.
- `super(arg1, arg2)` calls the parent with specific arguments.

### Operator Overloading

Almost every operator in Ruby is actually a method call. You can override them:

```ruby
class Foo
  def <<(message)
    print "hello " + message
  end
end

f = Foo.new
f << "john"   # => hello john
```

When you write `a + b`, Ruby actually calls `a.+(b)`. This means you can define `+`, `-`, `*`, `[]`, `<=>`, `==`, and almost any other operator for your own classes.

```ruby
class Vector
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def +(other)
    Vector.new(@x + other.x, @y + other.y)
  end

  def ==(other)
    @x == other.x && @y == other.y
  end

  def to_s
    "(#{@x}, #{@y})"
  end
end

v1 = Vector.new(1, 2)
v2 = Vector.new(3, 4)
puts v1 + v2   # => (4, 6)
```

### Modules and Mixins

Modules serve two purposes in Ruby:
1. **Namespacing** — grouping related classes/constants
2. **Mixins** — sharing behavior across unrelated classes

```ruby
module Cream
  def cream?
    true
  end
end

class Cookie
  include Cream   # mixin — adds instance methods
end

cookie = Cookie.new
p cookie.cream?    # => true
```

#### `include` vs `extend` vs `prepend`

| Method | What it does |
|---|---|
| `include` | Adds module methods as **instance methods** |
| `extend` | Adds module methods as **class methods** (singleton methods) |
| `prepend` | Like `include`, but inserts the module **before** the class in the ancestor chain |

```ruby
module Logging
  def log(msg)
    puts "[LOG] #{msg}"
  end
end

class Server
  include Logging      # Server.new.log("hello") works
end

class Client
  extend Logging       # Client.log("hello") works (class-level)
end
```

**`prepend`** is particularly useful for wrapping existing behavior:

```ruby
module Auditing
  def save
    puts "Auditing before save..."
    super                # calls the original save method
    puts "Auditing after save..."
  end
end

class Record
  prepend Auditing

  def save
    puts "Saving record"
  end
end

Record.new.save
# Output:
# Auditing before save...
# Saving record
# Auditing after save...
```

This works because `prepend` inserts `Auditing` *before* `Record` in the method lookup chain, so `Auditing#save` runs first and `super` delegates to `Record#save`.

---

## Everything Is an Object

Ruby's most fundamental design principle is that **everything is an object**. There are no primitives — every value, including numbers, booleans, and `nil`, is an instance of a class.

```ruby
42.class          # => Integer
42.even?          # => true
42.methods.count  # => 145 (Integer has 145+ methods)

true.class        # => TrueClass
nil.class         # => NilClass
nil.nil?          # => true
nil.to_a          # => []
nil.to_s          # => ""
```

Even **classes are objects** — they are instances of `Class`:

```ruby
String.class         # => Class
Class.class          # => Class  (Class is an instance of itself!)
Class.superclass     # => Module
Module.superclass    # => Object
Object.superclass    # => BasicObject
BasicObject.superclass  # => nil (top of the hierarchy)
```

### The Ancestor Chain

Every class has an **ancestor chain** — the ordered list of classes and modules Ruby searches when resolving a method call:

```ruby
Dog.ancestors
# => [Dog, Animal, Object, Kernel, BasicObject]
```

When you call `dog.make_sound`, Ruby walks this chain from left to right until it finds a method with that name. If it reaches the end without finding one, it triggers `method_missing`.

With modules mixed in, the chain grows:

```ruby
class Dog < Animal
  include Comparable
  include Enumerable
end

Dog.ancestors
# => [Dog, Enumerable, Comparable, Animal, Object, Kernel, BasicObject]
```

Modules are inserted **right above** the class that includes them. If multiple modules are included, the **last included** module is closest to the class (searched first).

### Method Lookup Algorithm

When you call a method on an object, Ruby follows this exact process:

1. Check the object's **singleton class** (eigenclass) for the method
2. Check the object's **class**
3. Check any **prepended** modules (in reverse inclusion order)
4. Check any **included** modules (in reverse inclusion order)
5. Move to the **superclass** and repeat steps 2–4
6. Continue up the ancestor chain until `BasicObject`
7. If not found: restart from step 1 but look for `method_missing` instead
8. If `method_missing` is also not found all the way up: raise `NoMethodError`

### Singleton Classes (Eigenclasses)

Every object in Ruby has a hidden **singleton class** — an anonymous class that sits between the object and its actual class in the lookup chain. This is where **per-object methods** live:

```ruby
str = "hello"

def str.shout
  upcase + "!!!"
end

str.shout        # => "HELLO!!!"
"world".shout    # => NoMethodError — only str has this method
```

The singleton class is also how **class methods** work internally:

```ruby
class Dog
  def self.species
    "Canis lupus familiaris"
  end
end
```

`self.species` actually defines a method on `Dog`'s singleton class. `Dog` is an object (instance of `Class`), and `species` is a method on that specific object's singleton class. There is no separate concept of "static methods" in Ruby — it's all objects and singleton classes.

```ruby
Dog.singleton_class.instance_methods(false)  # => [:species]
```

---

## How the Ruby Interpreter Works

Understanding how Ruby goes from source code to execution is essential for writing performant code and debugging complex issues.

### The CRuby (MRI) Pipeline

CRuby (Matz's Ruby Interpreter, also called MRI) is the reference implementation. Since Ruby 1.9, it uses a **three-phase pipeline**:

```
Source Code → Tokenizer → Parser (AST) → Compiler → YARV Bytecode → VM Execution
```

#### Phase 1: Tokenization (Lexing)

The tokenizer reads raw source code characters and breaks them into **tokens** — the smallest meaningful units:

```ruby
# Source:
puts "hello"

# Tokens:
# [:identifier, "puts"], [:string, "hello"], [:newline]
```

You can see Ruby's tokenization using the `Ripper` standard library:

```ruby
require 'ripper'
pp Ripper.lex('puts "hello"')
# [[[1, 0], :on_ident, "puts", CMDARG],
#  [[1, 4], :on_sp, " ", CMDARG],
#  [[1, 5], :on_tstring_beg, "\"", CMDARG],
#  [[1, 6], :on_tstring_content, "hello", CMDARG],
#  [[1, 11], :on_tstring_end, "\"", CMDARG]]
```

#### Phase 2: Parsing (AST Construction)

The parser takes the token stream and builds an **Abstract Syntax Tree (AST)** — a tree representation of the program's structure:

```ruby
require 'ripper'
pp Ripper.sexp('x = 1 + 2')
# [:program,
#  [[:assign,
#    [:var_field, [:@ident, "x", [1, 0]]],
#    [:binary,
#     [:@int, "1", [1, 4]],
#     :+,
#     [:@int, "2", [1, 8]]]]]]
```

Since Ruby 2.6, you can also access the raw AST through `RubyVM::AbstractSyntaxTree`:

```ruby
ast = RubyVM::AbstractSyntaxTree.parse('x = 1 + 2')
pp ast
# (SCOPE@1:0-1:9
#  tbl: [:x]
#  args: nil
#  body: (LASGN@1:0-1:9 :x (OPCALL@1:4-1:9 (LIT@1:4-1:5 1) :+ (LIST@1:8-1:9 (LIT@1:8-1:9 2) nil))))
```

#### Phase 3: Compilation to YARV Bytecode

The AST is compiled into **YARV bytecode** (Yet Another Ruby VM). YARV is a stack-based virtual machine introduced in Ruby 1.9 that replaced the old tree-walking interpreter:

```ruby
code = RubyVM::InstructionSequence.compile('x = 1 + 2')
puts code.disasm

# == disasm: <RubyVM::InstructionSequence:<compiled>@<compiled>>=
# local table (size: 1, argc: 0 [opts: 0, rest: -1, post: 0, block: -1, kw: -1@-1, kwrest: -1])
# [ 1] x@0
# 0000 putobject_INT2FIX_1_                                           (   1)
# 0001 putobject                    2
# 0003 opt_plus                     <calldata!mid:+, argc:1, ARGS_SIMPLE>
# 0005 setlocal_WC_0                x@0
# 0007 leave
```

Key YARV instructions:
- **`putobject`**: pushes a value onto the stack
- **`opt_plus`**: optimized addition (inlined for common types)
- **`setlocal`**: stores a value in a local variable
- **`send`**: generic method dispatch (used when `opt_*` can't be applied)

#### Phase 4: VM Execution

YARV executes the bytecode using a **stack-based virtual machine**. Operations push and pop values from a value stack:

```
Stack before opt_plus: [1, 2]
Stack after opt_plus:  [3]
```

YARV uses several optimization techniques:
- **Specialized instructions**: `opt_plus`, `opt_minus`, `opt_lt`, etc. bypass full method dispatch for common operations on integers and floats
- **Inline caching**: method lookup results are cached at each call site — subsequent calls to the same method skip the full lookup
- **Instruction operand fusion**: common sequences of instructions are combined into a single instruction

### The Global Interpreter Lock (GIL/GVL)

CRuby has a **Global VM Lock (GVL)** — a mutex that ensures only one thread executes Ruby code at a time. This means:

- **CPU-bound** Ruby threads run sequentially, even on multi-core machines
- **I/O-bound** threads can run concurrently — the GVL is released during I/O operations (network, disk, sleep)
- **C extensions** can manually release the GVL to enable true parallelism for their code

```ruby
# I/O-bound: threads provide real concurrency
threads = 10.times.map do
  Thread.new { Net::HTTP.get(URI("https://example.com")) }
end
threads.each(&:join)

# CPU-bound: threads provide NO speedup due to GVL
threads = 10.times.map do
  Thread.new { (1..10_000_000).reduce(:+) }
end
threads.each(&:join)
```

**Alternatives for true parallelism:**
- **`Ractor`** (Ruby 3.0+): actor-based parallelism — each Ractor has its own GVL
- **`Process.fork`**: OS-level process forking — true parallelism, higher memory cost
- **JRuby/TruffleRuby**: alternative Ruby implementations without a GVL

### Ractors (Ruby 3.0+)

Ractors are Ruby's answer to safe parallelism. Each Ractor is an isolated execution context with its own GVL:

```ruby
ractors = 4.times.map do |i|
  Ractor.new(i) do |id|
    sum = (1..10_000_000).reduce(:+)
    "Ractor #{id}: #{sum}"
  end
end

ractors.each { |r| puts r.take }
```

Ractors communicate through **message passing** — they cannot share mutable state. Objects sent between Ractors are either **deep-copied** or **moved** (ownership transfer). This eliminates data races by design.

---

## Memory Management and Garbage Collection

### Object Allocation

Every Ruby object is represented in memory as an `RVALUE` struct (40 bytes on 64-bit systems). Objects are allocated in **heap pages**, each containing ~400 slots:

```
Heap Page (~16KB)
┌──────────────────────────────────────────┐
│ RVALUE │ RVALUE │ RVALUE │ ... │ RVALUE  │
│ 40 bytes│ 40 bytes│ 40 bytes│   │ 40 bytes│
└──────────────────────────────────────────┘
```

Small objects (short strings ≤ 23 bytes, small arrays ≤ 3 elements) are stored **directly inside the RVALUE** slot. Larger objects allocate additional memory on the OS heap and store a pointer in the RVALUE.

### Garbage Collection Strategy

Ruby's GC has evolved significantly over the years:

| Ruby Version | GC Strategy |
|---|---|
| 1.8 | Simple mark-and-sweep (stop-the-world) |
| 2.0 | Copy-on-write friendly (bitmap marking) |
| 2.1 | **Generational GC** (minor/major collections) |
| 2.2 | **Incremental GC** (reduces pause times) |
| 2.7 | **Compaction** (defragments the heap) |
| 3.3 | Object shapes and further optimizations |

#### Generational GC

Based on the **generational hypothesis** — most objects die young. Ruby divides objects into:

- **Young generation**: recently allocated objects. Collected frequently (minor GC). These are fast because most young objects are already dead.
- **Old generation**: objects that survived multiple minor GCs. Collected infrequently (major GC). A major GC marks *all* objects.

An object is **promoted** from young to old after surviving 3 minor GC cycles (configurable via `RUBY_GC_HEAP_OLDMALLOC_LIMIT`).

#### The Mark-and-Sweep Algorithm

1. **Mark phase**: starting from **GC roots** (global variables, stack references, the constant table), traverse all reachable objects and mark them as "alive"
2. **Sweep phase**: walk the entire heap — any unmarked object is dead and its slot is reclaimed for reuse

GC roots include:
- The VM stack (local variables, method arguments)
- Global variables (`$stdout`, `$LOAD_PATH`, etc.)
- The constant table
- Finalizers
- C extension references registered with `rb_gc_mark`

#### Incremental GC

Major GC collections can be slow because they traverse the entire object graph. **Incremental GC** breaks the mark phase into small steps interleaved with program execution, reducing pause times from tens of milliseconds to single-digit milliseconds.

It uses a **tri-color marking** algorithm:
- **White**: not yet visited (potentially garbage)
- **Gray**: visited but children not yet scanned
- **Black**: visited and all children scanned

The incremental collector processes gray objects in small batches, allowing the program to run between batches.

#### Heap Compaction (Ruby 2.7+)

Over time, live objects become scattered across heap pages with gaps between them. **Compaction** moves live objects together, which:
- Reduces memory fragmentation
- Improves cache locality
- Allows empty pages to be released back to the OS

```ruby
GC.compact    # manually triggers compaction
GC.auto_compact = true   # enables automatic compaction (Ruby 3.0+)
```

#### Tuning GC

Ruby's GC can be tuned through environment variables:

```bash
RUBY_GC_HEAP_INIT_SLOTS=600000        # initial heap slots
RUBY_GC_HEAP_FREE_SLOTS=200000        # free slots to maintain
RUBY_GC_HEAP_GROWTH_FACTOR=1.25       # heap growth multiplier
RUBY_GC_MALLOC_LIMIT=16000000         # malloc limit before GC trigger (bytes)
RUBY_GC_OLDMALLOC_LIMIT=16000000      # old-gen malloc limit
```

You can inspect GC stats at runtime:

```ruby
GC.stat
# => { count: 42, heap_allocated_pages: 150, heap_live_slots: 58320,
#      total_allocated_objects: 1234567, total_freed_objects: 1176247, ... }
```

---

## Metaprogramming

Metaprogramming is writing **code that writes code**. Ruby's dynamic nature makes it one of the best languages for metaprogramming — and this is the foundation of frameworks like Rails.

### `method_missing`

When Ruby can't find a method through the normal lookup chain, it calls `method_missing` on the object. You can override this to handle arbitrary method calls:

```ruby
class FlexibleObject
  def method_missing(method_name, *args)
    if method_name.to_s.start_with?("say_")
      word = method_name.to_s.sub("say_", "")
      puts word.capitalize
    else
      super   # important: call super for truly missing methods
    end
  end

  # Always pair with respond_to_missing?
  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?("say_") || super
  end
end

obj = FlexibleObject.new
obj.say_hello      # => "Hello"
obj.say_ruby       # => "Ruby"
obj.respond_to?(:say_hello)  # => true (thanks to respond_to_missing?)
```

> **Note:** Always override `respond_to_missing?` alongside `method_missing`. Without it, `respond_to?` returns `false` even for methods your `method_missing` handles — this breaks introspection and confuses other developers.

### `define_method`

Dynamically define methods at runtime:

```ruby
class ApiClient
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |url, params = {}|
      puts "#{http_method.upcase} #{url} with #{params}"
      # actual HTTP logic here
    end
  end
end

client = ApiClient.new
client.get("/users", page: 1)     # => GET /users with {:page=>1}
client.delete("/users/5")         # => DELETE /users/5 with {}
```

This technique is heavily used in Rails — `ActiveRecord` defines attribute accessors based on database column names discovered at runtime.

### `class_eval` and `instance_eval`

These methods let you execute code in the context of a class or object:

```ruby
# class_eval: execute code as if you're inside the class body
String.class_eval do
  def shout
    upcase + "!!!"
  end
end

"hello".shout   # => "HELLO!!!"

# instance_eval: execute code in the context of a specific object
obj = Object.new
obj.instance_eval do
  @secret = 42
  def reveal
    @secret
  end
end

obj.reveal    # => 42
```

### Open Classes (Monkey Patching)

Ruby classes are never "closed" — you can reopen any class and add or modify methods:

```ruby
class Integer
  def factorial
    return 1 if self <= 1
    self * (self - 1).factorial
  end
end

5.factorial   # => 120
```

This is powerful but dangerous. **Refinements** (Ruby 2.0+) provide a scoped alternative:

```ruby
module StringExtensions
  refine String do
    def shout
      upcase + "!!!"
    end
  end
end

# The refinement is only active where you explicitly activate it:
using StringExtensions
"hello".shout   # => "HELLO!!!"
```

Once execution leaves the file (or module) where `using` was called, the refinement is no longer active. This prevents the global side-effects of monkey patching.

### `send` and `public_send`

Invoke methods by name (as a symbol or string):

```ruby
class Account
  private

  def secret_balance
    1_000_000
  end
end

account = Account.new
account.send(:secret_balance)         # => 1000000 (bypasses private!)
account.public_send(:secret_balance)  # => NoMethodError (respects visibility)
```

- **`send`**: calls any method, ignoring visibility — use for metaprogramming when you know what you're doing
- **`public_send`**: respects `public`/`private`/`protected` — safer for general use

### Hooks and Callbacks

Ruby provides lifecycle hooks that fire when certain events happen:

```ruby
module Trackable
  def self.included(base)
    puts "#{self} was included in #{base}"
    base.extend(ClassMethods)
  end

  module ClassMethods
    def tracked_method(name)
      define_method(name) do
        puts "Calling tracked method: #{name}"
      end
    end
  end
end

class User
  include Trackable
  tracked_method :activate
end

User.new.activate   # => "Calling tracked method: activate"
```

Key hooks:

| Hook | Triggered when... |
|---|---|
| `included(base)` | A module is included in a class |
| `extended(base)` | A module is used to extend an object |
| `inherited(subclass)` | A class is subclassed |
| `method_added(name)` | An instance method is defined |
| `method_removed(name)` | An instance method is removed |
| `const_missing(name)` | A constant is referenced but not found |

### DSLs (Domain-Specific Languages)

Metaprogramming enables Ruby's most distinctive feature: the ability to create **internal DSLs** — code that reads like a custom language but is valid Ruby:

```ruby
class Route
  attr_reader :routes

  def initialize
    @routes = []
  end

  def get(path, &handler)
    @routes << { method: :get, path: path, handler: handler }
  end

  def post(path, &handler)
    @routes << { method: :post, path: path, handler: handler }
  end
end

def routes(&block)
  router = Route.new
  router.instance_eval(&block)
  router
end

app = routes do
  get "/users" do
    "List users"
  end

  post "/users" do
    "Create user"
  end
end

app.routes.each { |r| puts "#{r[:method].upcase} #{r[:path]}" }
# GET /users
# POST /users
```

This pattern — using `instance_eval` with blocks — is how tools like Rails routes, RSpec tests, Sinatra endpoints, and Gemfiles work. The block is evaluated in the context of a builder object, making the DSL syntax possible.

---

## Enumerable and the Collection Protocol

The `Enumerable` module is one of Ruby's most powerful mixins. Include it and define `each`, and you get 50+ collection methods for free:

```ruby
class WordCounter
  include Enumerable

  def initialize(text)
    @words = text.split
  end

  def each(&block)
    @words.each(&block)
  end
end

counter = WordCounter.new("the quick brown fox jumps over the lazy dog")
counter.count              # => 9
counter.sort               # => ["brown", "dog", "fox", ...]
counter.select { |w| w.length > 3 }  # => ["quick", "brown", "jumps", "over", "lazy"]
counter.group_by(&:length) # => {3=>["the", "fox", "the", "dog"], 5=>["quick", ...], ...}
counter.min_by(&:length)   # => "the"
counter.any? { |w| w == "fox" }  # => true
```

Similarly, including `Comparable` and defining `<=>` gives you `<`, `>`, `<=`, `>=`, `between?`, and `clamp` for free.

### Lazy Enumerators

For large or infinite sequences, **lazy enumerators** avoid materializing the entire collection:

```ruby
# Without lazy: generates all 10 million numbers, then filters, then takes 5
(1..10_000_000).select(&:prime?).first(5)   # slow, uses lots of memory

# With lazy: generates only as many as needed
(1..Float::INFINITY).lazy.select(&:odd?).map { |n| n ** 2 }.first(5)
# => [1, 9, 25, 49, 81]
```

Lazy enumerators build a pipeline of transformations and only evaluate them when a terminal operation (like `first`, `to_a`, or `force`) is called.

---

## Concurrency Primitives

### Fibers

Fibers are **cooperative concurrency** primitives — lightweight coroutines that you manually schedule:

```ruby
fiber = Fiber.new do
  puts "Step 1"
  Fiber.yield
  puts "Step 2"
  Fiber.yield
  puts "Step 3"
end

fiber.resume   # => "Step 1"
fiber.resume   # => "Step 2"
fiber.resume   # => "Step 3"
```

Fibers are the foundation of:
- **Enumerators** (each `Enumerator` uses a `Fiber` internally)
- **Fiber Scheduler** (Ruby 3.0+) — enables non-blocking I/O without callbacks

#### Fiber Scheduler (Ruby 3.0+)

The Fiber Scheduler API lets you write synchronous-looking code that is automatically made non-blocking:

```ruby
require 'async'

Async do
  # These run concurrently, not sequentially
  3.times.map do |i|
    Async do
      sleep 1   # non-blocking sleep via Fiber Scheduler
      puts "Task #{i} done"
    end
  end
end
# All three tasks complete in ~1 second, not 3
```

---

## Object Freezing and Immutability

```ruby
str = "hello"
str.freeze

str.frozen?     # => true
str << " world" # => FrozenError

# Dup creates a mutable copy; clone preserves frozen state
str.dup.frozen?    # => false
str.clone.frozen?  # => true
```

`freeze` is **shallow** — it freezes the object itself but not the objects it references:

```ruby
arr = ["a", "b", "c"]
arr.freeze
arr << "d"       # => FrozenError
arr[0] << "aa"   # => works! arr is now ["aaa", "b", "c"]
```

For deep freezing, you need to recursively freeze each element or use a gem like `ice_nine`.

---

## Useful Built-in Methods and Idioms

### The Safe Navigation Operator (`&.`)

```ruby
user = nil
user&.name       # => nil (no NoMethodError)
user&.address&.city  # => nil (chained safely)
```

### `tap` for Debugging

```ruby
[1, 2, 3].map { |n| n * 2 }
          .tap { |arr| puts "After map: #{arr.inspect}" }
          .select(&:even?)
          .tap { |arr| puts "After select: #{arr.inspect}" }
```

`tap` yields the object to the block, then returns the object unchanged — perfect for inserting debug output into method chains.

### `freeze` Constants

```ruby
VALID_STATUSES = %w[active inactive suspended].freeze
# %w creates an array of strings: ["active", "inactive", "suspended"]
```

### `Struct` and `Data`

```ruby
# Struct: quick value object with mutable attributes
Point = Struct.new(:x, :y)
p = Point.new(1, 2)
p.x = 3   # mutable

# Data (Ruby 3.2+): immutable value object
Point = Data.define(:x, :y)
p = Point.new(x: 1, y: 2)
p.x = 3   # => NoMethodError (immutable!)
```

---

## Summary

Ruby is much more than its clean syntax suggests. Beneath the surface lies a sophisticated runtime:

- **Everything is an object** — integers, classes, `nil`, even `true` and `false` are full objects with methods, singleton classes, and ancestors
- **The interpreter pipeline** (tokenizer → parser → compiler → YARV VM) turns source code into optimized bytecode with inline caches and specialized instructions
- **Generational, incremental GC with compaction** keeps memory efficient while minimizing pause times
- **Metaprogramming** (`method_missing`, `define_method`, `class_eval`, hooks) lets you write code that generates code — the foundation of Rails and every major Ruby framework
- **Blocks, Procs, Lambdas, and Fibers** provide a rich toolkit for functional programming and cooperative concurrency
- **Modules and mixins** solve the code reuse problem without the complexity of multiple inheritance

Understanding these internals doesn't just satisfy curiosity — it makes you a dramatically better Ruby developer. When you know how method lookup works, you can debug mysterious `NoMethodError`s. When you understand the GC, you can write memory-efficient code. When you grasp metaprogramming, you can read Rails source code instead of treating it as magic.
