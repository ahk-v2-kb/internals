# Enumerator

Requires: [`[v2.0-a108-a2fa0498]`](https://github.com/Lexikos/AutoHotkey_L/releases/tag/v2.0-a108)

## Purpose

An enumerator provides means for modifying the element enumeration behavior of built-in and user-defined collections. In other words, implementing a custom enumerator allows for a finer-grained control over how collections are traversed.

Enumerators can also be employed as sequence generators.

## Description

An enumerator is a function (or method) reference, a closure or a function object (bound or user-defined, implementing a `Call` method) that can be passed to a `for` loop's `Expression` parameter.

An enumerator must, at the very least, base its implementation on a unary (or binary, in the case of a two-parameter `for` loop) function. Higher-arity and variadic functions are permissible as well, however, depending on the type of `for` loop the enumerator has been passed to, the following set of conditions must be satisfied:

- _One-parameter `for` loop:_ there exists exactly __one, unbound, non-variadic, `ByRef`__ out-param, corresponding to the `for` loop's single parameter.
- _Two-parameter `for` loop:_ there exist exactly __two, unbound, non-variadic, `ByRef`__ out-params, one immediately followed by the other, corresponding to each of the `for` loop's parameters, respectively.
- __All__ remaining (if any) __non-variadic__ function parameters have been bound.

The enumerator's parameters, which correspond to those of the `for` loop, are required to be declared `ByRef`, so as to permit the updating of the `for` loop's parameters. While an enumerator based solely on variadic or non-`ByRef` functions, for instance, would not produce any runtime errors, it certainly wouldn't behave as expected either.

The enumerator function is called repeatedly by the `for` loop, on every iteration of the `for` loop, indefinitely or until the function `return`s a __falsy__ value (plain `return`, `false`, `0`, empty strings or numeric strings, decaying into `0`), at which point enumeration ceases and the  `for` loop's scope is broken out of.

If an object is passed to the `for` loop's `Expression` parameter, the runtime shall attempt to invoke the object's `__Enum` method, passing as an argument (`NumberOfVars`) the number of `for` loop parameters, depending on the type of `for` loop that the object was passed to. Objects that do not inherit or themselves implement an `__Enum` method are not enumerable and any attempts of passing them to `for` loops would trigger runtime exceptions.

Sample `__Enum` implementation:

```autohotkey
__Enum(NumberOfVars)
{
	OneParameterEnumerator(ByRef out)
	{
		; ...
	}

	TwoParameterEnumerator(ByRef out1, ByRef out2)
	{
		; ...
	}

	return (NumberOfVars = 1)
		? Func('OneParameterEnumerator')
		: Func('TwoParameterEnumerator')
}