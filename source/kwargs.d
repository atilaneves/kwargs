module kwargs;


template kwargify(alias Function) {

    import std.traits: Parameters;

    auto impl(A...)(auto ref A args) {
        import std.conv: text;

        static assert(A.length == Parameters!Function.length,
                      text("ERROR: wrapper for ", __traits(identifier, Function),
                           "must be called with ", Parameters!Function.length, " parameters"));
    }

    alias kwargify = impl;
}
