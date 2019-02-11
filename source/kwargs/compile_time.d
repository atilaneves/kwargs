module kwargs.compile_time;


/// Designates T to be a required template parameter value of type T
struct Required(T) {
    alias Type = T;
}

/// Designates the unique template parameter value to be an optional template parameter
struct Optional(T...) if(T.length == 1 && !is(T[0])) {
    alias Type = typeof(T[0]);
    enum value = T[0];
}


template kwargify(alias Function, Parameters...)
    if(__traits(isTemplate, Function) && Parameters.length > 0)
{
    import std.meta: Filter, staticIndexOf;

    enum isRequired(alias T) = is(T == Required!U, U);
    alias required = Filter!(isRequired, Parameters);

    static foreach(i; 0 .. required.length) {
        static assert(i == staticIndexOf!(required[i], Parameters),
                      "All `Required` parameters must be at the beginning");
    }

    enum isOptional(alias T) = is(T == Optional!U, alias U);
    alias optional = Filter!(isOptional, Parameters);

    static foreach(i; 0 .. optional.length) {
        static assert(i + required.length == staticIndexOf!(optional[i], Parameters),
                      "All `Optional` parameters must be at the end");
    }

    static assert(required.length + optional.length == Parameters.length);

    auto impl(Args...)() {
        import std.meta: AliasSeq, staticMap, staticIndexOf;

        // return a tuple of values to use as template parameters to `Function`
        static auto params() {
            import std.typecons: Tuple;

            alias Type(alias T) = T.Type;
            alias TupleType = Tuple!(staticMap!(Type, Parameters));

            TupleType ret;

            // required parameters are easy
            static foreach(i, req; required) {{
                enum argIndex = staticIndexOf!(req.Type, required);
                ret[i] = Args[i];
            }}

            // optional parameters are trickier
            static foreach(i, opt; optional) {{

                alias ofRightType = Filter!(isOptionalType!opt, Args);

                static if(ofRightType.length == 0) {
                    // Get the default value from `Parameters` if the user didn't
                    // supply one of the optional values

                    alias defaults = Filter!(isOptionalType!opt, Parameters);
                    static assert(defaults.length == 1);
                    ret[required.length + i] = defaults[0].value;
                } else {
                    // value was supplied by the user, use it
                    static assert(ofRightType.length == 1);
                    ret[required.length + i] = ofRightType[0];
                }
            }}

            return ret;
        }

        enum paramTuple = params;
        return Function!(paramTuple.expand);
    }

    alias kwargify = impl;
}


// Workaround for https://issues.dlang.org/show_bug.cgi?id=19650
private template isOptionalType(alias optional) {

    private template Type(alias T) {
        static if(is(T.Type))
            alias Type = T.Type;
        else
            alias Type = typeof(T);
    }

    enum isOptionalType(alias T) = is(Type!T == optional.Type);
}
