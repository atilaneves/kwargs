module kwargs;


/**
   Wrap `Function` so that it's callable with its parameters in any order.
   No types should be repeated in its signature.
 */
template kwargify(alias Function) {

    auto impl(A...)(auto ref A args) {
        import std.conv: text;
        import std.typecons: Tuple;
        import std.meta: staticMap, staticIndexOf, Filter, templateNot;
        import std.traits: Unqual, ParameterDefaults, Parameters;

        enum isDefaultParam(T...) = is(T[0] == void);
        enum numOfNonDefaultParams = Filter!(templateNot!isDefaultParam, ParameterDefaults!Function).length;
        enum numOfRequiredParams = Parameters!Function.length - numOfNonDefaultParams;

        static assert(A.length >= numOfRequiredParams,
                      text("ERROR: wrapper for ", __traits(identifier, Function),
                           "must be called with at least", Parameters!Function.length, " parameters"));

        Tuple!(staticMap!(Unqual, Parameters!Function)) params;

        static foreach(i; 0 .. Parameters!Function.length) {{

            alias Type = typeof(params[i]);

            enum hasDefaultValue = !is(ParameterDefaults!Function[i] == void);
            enum typeIndex = staticIndexOf!(Type, A);

            static if(typeIndex == -1) {
                static assert(hasDefaultValue,
                              text("Could not find `", Type.stringof, "` in call to ", __traits(identifier, Function)));
                params[i] = ParameterDefaults!Function[i];
            }
            else
                params[i] = args[typeIndex];
        }}

        // to avoid a static if on the return type
        auto call() {
            return Function(params.expand);
        }

        return call;
    }

    alias kwargify = impl;
}
