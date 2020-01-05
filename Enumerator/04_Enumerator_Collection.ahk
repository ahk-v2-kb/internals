; Enumerate array elements in reverse.

; Standard array, only modify the enumerator.
class ReverseArray extends Array
{
	__Enum(NumberOfVars)
	{
		; Lexical scope bound.
		; Serves as an index counter.
		i := this.Length

		EnumerateElements(ByRef element)
		{
			; Stop enumerating when there are no more elements
			; left in the array.
			if (i = 0)
				return false

			; Assign to the 'for' loop and decrement.
			element := this[i]
			i -= 1

			; Continue enumeration.
			return true
		}

		EnumerateIndexWithElements(ByRef index, ByRef element)
		{
			if (i = 0)
				return false

			index := i
			element := this[i]
			i -= 1

			return true
		}

		; Decide, based on the 'for' loop type, which
		; enumeration function is the appropriate one.
		return (NumberOfVars = 1)
			 ? Func('EnumerateElements')
			 : Func('EnumerateIndexWithElements')
	}
}

ReversedLetters := ReverseArray.New('a', 'b', 'c')

; One parameter mode.
for e in ReversedLetters
	MsgBox e

; Two parameter mode.
for i, e in ReversedLetters
	MsgBox i '. ' e