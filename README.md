# kwargs - Type-based keyword arguments for D


[![Build Status](https://travis-ci.org/atilaneves/kwargs.png?branch=master)](https://travis-ci.org/atilaneves/kwargs)


## Pass run or compile time parameters in any order to your functions

### Runtime parameters

This library aims to make it easier to use type-safe APIs (the opposite of [primitive obsession](http://wiki.c2.com/?PrimitiveObsession))
without having to spell out all the values to be used, especially when many of them have defaults. For instance:

```d
void build(BinName binName,
           CompileFlags cFlags = CompileFlags("-g", "-debug"),
           LinkerFlags lFlags = LinkerFlags(),
           ExtraStuff extraStuff = ExtraStuff());_
```

If the user wants to use a non-default `ExtraStuff` value, they have to pass in `CompilerFlags` _and_ `LinkerFlags` even though
they might be happy with the defaults:

```d
build(BinName(BinName("myapp"), CompilerFlags("-g", "debug"), LinkerFlags(), ExtraStuff(42)));
```

With this library, one can:

```d
import kwargs;
alias awesomeBuild = kwargify!build;
// look ma, wrong order!
awesomeBuild(ExtraStuff(42), BinName("myapp"))
```


### Compile-time parameters

Unfortunately, D currently lacks a way to reflect on template parameters, so the usage is slightly clumsier:

```d
struct Foo { int val; }
struct Bar { int val; }
struct Baz { int val; }

int[] funImpl(Foo foo, Bar bar, Baz baz)() {
    return [foo.val, bar.val, baz.val];
}

alias fun = kwargify!(funImpl, Required!Foo, Optional!(Bar(2)), Optional!(Baz(3)));

fun!(Foo(1)).should == [1, 2, 3];
fun!(Baz(9), Foo(7)).should == [7, 2, 9];
fun!(Baz(9), Bar(8), Foo(7)).should == [7, 8, 9];

```

Hopefully the example is self-explanatory.
