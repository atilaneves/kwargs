module kwargs.compile_time;


/// Designates T to be a required template parameter value of type T
struct Required(T) { }

/// Designates the unique template parameter value to be an optional template parameter
struct Optional(T...) if(T.length == 1 && !is(T[0])) {}


template kwargify(alias Function, A...) if(__traits(isTemplate, Function)) {

}
