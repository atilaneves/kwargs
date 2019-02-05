module kwargs;


/**
   Wrap `Function` so that it's callable with its parameters in any order.
   No types should be repeated in its signature.
 */
template kwargify(alias Function) {

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

        // Workaround for https://issues.dlang.org/show_bug.cgi?id=19650
        size_t numTypes(T)() {
            size_t ret;
            static foreach(i; 0 .. A.length)
                static if(is(A[i] == T))
                    ++ret;
            return ret;
        }

        // the parameters to pass to the wrapped function
        Tuple!funcArgTypes params;

        static foreach(i; 0 .. Parameters!Function.length) {{

            alias Type = typeof(params[i]);

            enum hasDefaultValue = !is(ParameterDefaults!Function[i] == void);
            enum typeIndex = staticIndexOf!(Type, A);

            static if(typeIndex == -1) {
                static assert(hasDefaultValue,
                              text("Could not find `", Type.stringof, "` in call to ", __traits(identifier, Function)));
                params[i] = ParameterDefaults!Function[i];
            } else {
                static assert(numTypes!Type == 1,
                              text("ERROR: found ", numTypes!Type, " `", Type.stringof, "`s instead of 1"));
                params[i] = args[typeIndex];
            }
        }}

        // to avoid a static if on the return type
        auto call() {
            return Function(params.expand);
        }

        return call;
    }

    alias kwargify = impl;
}
