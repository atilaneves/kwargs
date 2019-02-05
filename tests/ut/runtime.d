module ut.runtime;


import ut;


@("nodefaults")
@safe pure unittest {

    static struct Foo { string value; }
    static struct Bar { string value; }
    static struct Baz { string value; }

    static void funImpl(Foo foo, Bar bar, Baz baz) {
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
