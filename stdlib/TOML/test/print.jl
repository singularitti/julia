# This file is a part of Julia. License is MIT: https://julialang.org/license

toml_str(a; kwargs...) = sprint(io -> TOML.print(io, a; kwargs...))
toml_str(f, a; kwargs...) = sprint(io -> TOML.print(f, io, a; kwargs...))

@test toml_str(Dict("b" => 1, "c" => 2, "a" => 3); sorted=true) ==
    """
    a = 3
    b = 1
    c = 2
    """

@test toml_str(Dict("b" => 1, "ac" => 2, "abc" => 3); sorted=true, by=length) ==
    """
    b = 1
    ac = 2
    abc = 3
    """

struct MyStruct
    a::Int
end
@test_throws ErrorException toml_str(Dict("foo" => MyStruct(1)))
# simple value
@test toml_str(Dict("foo" => MyStruct(1))) do x
        x isa MyStruct && return x.a
    end == """
        foo = 1
        """

# tabular values
@test toml_str(Dict("foo" => MyStruct(1)); sorted=true) do x
         x isa MyStruct && return [x.a]
     end == """
         foo = [1]
         """
@test toml_str(Dict("foo" => MyStruct(1)); sorted=true) do x
        x isa MyStruct && return Dict(:bar => x.a)
    end == """
        [foo]
        bar = 1
        """

# validation against the usual case
@test toml_str(Dict("foo" => MyStruct(1)); sorted=true) do x
         x isa MyStruct && return [x.a]
     end == toml_str(Dict("foo" => [1]); sorted=true)
@test toml_str(Dict("foo" => MyStruct(1)); sorted=true) do x
        x isa MyStruct && return Dict(:bar => x.a)
    end == toml_str(Dict("foo" => Dict(:bar => 1)); sorted=true)

@test toml_str(Dict("b" => SubString("foo"))) == "b = \"foo\"\n"

@testset "empty dict print" begin
    s = """
    user = "me"
    [julia]
    [option]
    """
    d = TOML.parse(s)
    @test toml_str(d) == "user = \"me\"\n\n[julia]\n\n[option]\n"
end
