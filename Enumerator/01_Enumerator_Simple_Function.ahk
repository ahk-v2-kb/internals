; Enumerate elements from the set of natural numbers.

Nat(ByRef out)
{
	; A 'static' variable's value is preserved between calls.
	; Enumerators universally require a mechanism to track state.
	static n := 0

	; Assign to the 'for' loop's parameter.
	out := n

	n += 1

	; Enumeration will never cease.
	return true
}

; Pass a function reference to the 'for' loop.
for n in Func('Nat')
	MsgBox n