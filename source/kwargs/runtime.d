module kwargs.runtime;


/**
   Wrap `Function` so that it's callable with its parameters in any order.
   No types should be repeated in its signature.
 */
template kwargify(alias Function) if(!__traits(isTemplate, Function)) {

    import std.traits: Parameters;
    import std.conv: text;

    // Workaround for https://issues.dlang.org/show_bug.cgi?id=19650
    private size_t numTypes(T, A...)() {
        size_t ret;
        static foreach(i; 0 .. A.length)
            static if(is(A[i] == T))
                ++ret;
        return ret;
    }

    static foreach(T; Parameters!Function) {
        static assert(numTypes!(T, Parameters!Function) == 1,
                      text("ERROR: `", __traits(identifier, Function), "` does not have unique types: ",
                           Parameters!Function.stringof));
    }

    auto impl(A...)(auto ref A args) {
        import std.conv: text;
        import std.typecons: Tuple;
        import std.meta: staticMap, staticIndexOf, Filter;
        import std.traits: Unqual, ParameterDefaults, Parameters;

        alias funcArgTypes = staticMap!(Unqual, Parameters!Function);
        enum isWrongType(T) = staticIndexOf!(T, funcArgTypes) == -1;
        alias wrongTypes = Filter!(isWrongType, A);

        static assert(wrongTypes.length == 0,
                      text("ERROR: ", wrongTypes.stringof, " are not parameters of ", __traits(identifier, Function)));

        auto nthParam(int index)() {
            alias Type = typeof(params[index]);

            enum hasDefaultValue = !is(ParameterDefaults!Function[index] == void);
            enum typeIndex = staticIndexOf!(Type, A);

            static if(typeIndex == -1) {
                static assert(hasDefaultValue,
                              text("Could not find `", Type.stringof, "` in call to ", __traits(identifier, Function)));
                return ParameterDefaults!Function[index];
            } else {
                enum numTypes = numTypes!(Type, A);
                static assert(numTypes == 1,
                              text("ERROR: found ", numTypes, " `", Type.stringof, "`s instead of 1"));
                return args[typeIndex];
            }
        }

        // the parameters to pass to the wrapped function
        Tuple!funcArgTypes params;

        static foreach(i; 0 .. Parameters!Function.length) {
            params[i] = nthParam!i;
        }


        // to avoid a static if on the return type
        auto call() {
            return Function(params.expand);
        }

        return call;
    }

    alias kwargify = impl;
}
