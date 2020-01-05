; Example 01 rewritten to make use of a fat-arrow function.
; Same premise: enumerate elements from the set of natural numbers.

; Since the 'static' keyword is unsupported in lambda expressions,
; keep track of state by means of a global free variable instead.
i := 0

; Named (and anonymous) lambda expressions (not to be confused with
; fat-arrow syntax function definitions!) are themselves function
; references already.
for n in Nat(ByRef out) => (
	out := i,
	i += 1,
	true
)
{
	MsgBox n
}
