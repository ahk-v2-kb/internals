; Enumerate elements from the set of natural numbers.

class NaturalNumbers
{
	; Class method.
	static Nat(ByRef out)
	{
		static n := 0

		out := n
		n += 1

		return true
	}
}

; Retrieve a function reference to the method.
; Since the method is being called on its own,
; no value has been provided for the implicit 'this',
; which is the method's first argument (hidden).
;
; Instead 'Bind' an empty string to 'this, resulting in
; a bound function object and preventing runtime
; exceptions the first time the enumerator is invoked.
for n in NaturalNumbers.GetMethod('Nat').Bind('')
	MsgBox n