#Include FuncObjBase.ahk

class CustomFuncObj extends FuncObjBase
{
	InstanceValueProp := 'Instance value property.'

	Call(a, ByRef b, c := 'default', d*)
	{
		this.PrintMap(
			Map(
				'a', a,
				'b', b,
				'c', c,
				'd', d.Length
			)
		)
	}

	PrintMap(M)
	{
		s := 'A_ThisFunc: ' A_ThisFunc '`n'

		for k, v in M
			s .= k ': ' v '`n'

		MsgBox s
	}
}

fnObj := CustomFuncObj.New()

; Standard normal usage.
%fnObj%('a', 'b')
MsgBox(
	'Type: ' Type(fnObj) '`n'
	'Name: ' fnObj.Name '`n'
	'IsBuiltIn: ' fnObj.IsBuiltIn '`n'
	'IsVariadic: ' fnObj.IsVariadic '`n'
	'MinParams: ' fnObj.MinParams '`n'
	'MaxParams: ' fnObj.MaxParams '`n'
	'IsByRef(2): ' fnObj.IsByRef(2) '`n'
	'IsOptional(3): ' fnObj.IsOptional(3) '`n'
	'Has(`'PrintMap`'): ' fnObj.HasMethod('PrintMap') '`n'
	'InstanceValueProp: ' fnObj.InstanceValueProp
)

; Bind only the second argument.
fnObj := fnObj.Bind(, 'Bound B')

; Populate the first argument with 'a'.
; Populate the *third* argument with 'c' as 'b' has
; already been bound.
; Collect the last two arguments into the variadic 'd*'.
%fnObj%('a', 'c', 'd', 'e')

; The instance (along with its instance variables and methods)
; is preserved even after having been bound.
MsgBox(
	'Type: ' Type(fnObj) '`n'
	'Name: ' fnObj.Name '`n'
	'IsBuiltIn: ' fnObj.IsBuiltIn '`n'
	'IsVariadic: ' fnObj.IsVariadic '`n'
	'MinParams: ' fnObj.MinParams '`n'
	'MaxParams: ' fnObj.MaxParams '`n'
	'IsByRef(2): ' fnObj.IsByRef(2) '`n'
	'IsOptional(3): ' fnObj.IsOptional(3) '`n'
	'Has(`'PrintMap`'): ' fnObj.HasMethod('PrintMap') '`n'
	'InstanceValueProp: ' fnObj.InstanceValueProp
)