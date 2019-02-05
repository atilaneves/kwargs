module kwargs;


/**
   Wrap `Function` so that it's callable with its parameters in any order.
   No types should be repeated in its signature.
 */
template kwargify(alias Function) {

    import std.traits: Parameters;

    auto impl(A...)(auto ref A args) {
        import std.conv: text;
        import std.typecons: Tuple;
        import std.meta: staticMap, staticIndexOf;
        import std.traits: Unqual;

        static assert(A.length == Parameters!Function.length,
                      text("ERROR: wrapper for ", __traits(identifier, Function),
                           "must be called with ", Parameters!Function.length, " parameters"));

        Tuple!(staticMap!(Unqual, Parameters!Function)) params;

        static foreach(i; 0 .. Parameters!Function.length) {{
            alias Type = typeof(params[i]);
            enum typeIndex = staticIndexOf!(Type, A);
            static assert(typeIndex != -1,
                          text("Could not find `", Type.stringof, "` in call to ", __traits(identifer, Function)));
            params[i] = args[typeIndex];
        }}

        auto call() {
            return Function(params.expand);
        }

        return call;
    }

    alias kwargify = impl;
}
