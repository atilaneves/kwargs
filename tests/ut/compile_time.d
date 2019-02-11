module ut.compile_time;


import ut;


@("optional")
@safe pure unittest {

    static struct Foo { int val; }
    static struct Bar { int val; }
    static struct Baz { int val; }

    static int[] funImpl(Foo foo, Bar bar, Baz baz)() {
        return [foo.val, bar.val, baz.val];
    }

    alias fun = kwargify!(funImpl, Required!Foo, Optional!(Bar(2)), Optional!(Baz(3)));

    fun!(Foo(1)).should == [1, 2, 3];
    fun!(Foo(5), Bar(4)).should == [5, 4, 3];
    fun!(Foo(7), Bar(8), Baz(9)).should == [7, 8, 9];

    fun!(Baz(9), Foo(7)).should == [7, 2, 9];
    fun!(Baz(9), Bar(8), Foo(7)).should == [7, 8, 9];

    static assert(!__traits(compiles, fun!()));
    static assert(!__traits(compiles, fun!(Bar(2))));
    static assert(!__traits(compiles, fun!(Baz(2))));
}
