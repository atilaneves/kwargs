module ut.runtime;


import ut;


@("nodefaults.void")
@safe pure unittest {

    static struct Foo { string value; }
    static struct Bar { string value; }
    static struct Baz { string value; }

    static void funImpl(in Foo foo, in Bar bar, in Baz baz) {
        foo.value.should == "foo";
        bar.value.should == "bar";
        baz.value.should == "baz";
    }

    alias fun = kwargify!funImpl;

    fun(Foo("foo"), Bar("bar"), Baz("baz"));
    fun(Bar("bar"), Foo("foo"), Baz("baz"));
    fun(Baz("baz"), Bar("bar"), Foo("foo"));

    static assert(!__traits(compiles, fun()));

    fun(Foo(), Bar(), Baz()).shouldThrow!UnitTestException;
}


@("nodefaults.int")
@safe pure unittest {

    static struct Foo { string value; }
    static struct Bar { string value; }
    static struct Baz { string value; }

    static size_t funImpl(in Foo foo, in Bar bar, in Baz baz) {
        return foo.value.length + bar.value.length + baz.value.length;
    }

    alias fun = kwargify!funImpl;

    fun(Foo("foo"), Bar("bar"), Baz("baz")).should == 9;
    fun(Bar("bar"), Foo("foo"), Baz("quux")).should == 10;
    fun(Baz(), Bar(), Foo()).should == 0;
}
