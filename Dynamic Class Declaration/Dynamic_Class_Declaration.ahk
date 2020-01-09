; 1.
global ClassObject := Class.New()

; 2.
ClassObject.ClassValueProp := 'Static class value property.'
ClassObject._ClassDynamicProp := 'Static class dynamic property backing field.'
ClassObject.DefineProp(
	'ClassDynamicProp',
	{
		Get: this => this._ClassDynamicProp,
		Set: this => this._ClassDynamicProp := value
	}
)
ClassObject.DefineMethod(
	'ClassMethod',
	this => MsgBox('Static class method.')
)

; 3.
ClassObject.Prototype := {}

; 4.
ClassObject.Prototype.InstanceValueProp := 'Instance value property.'
ClassObject.Prototype._InstanceDynamicProp := 'Instance dynamic property backing field.'
ClassObject.Prototype.DefineProp(
	'InstanceDynamicProp',
	{
		Get: this => this._InstanceDynamicProp,
		Set: this => this._InstanceDynamicProp := value
	}
)
ClassObject.Prototype.DefineMethod(
	'InstanceMethod',
	this => MsgBox('Instance method.')
)

; 5. A.
; ClassObject.DefineMethod(
; 	'New',
; 	Object.GetMethod('New')
; )

; 5. B.
ClassObject.DefineMethod(
	'New',
	this => {Base: this.Prototype}
)

; 5. C.
; ClassObject.DefineMethod(
; 	'New',
; 	Func('Constructor')
; )

; Constructor(this)
; {
; 	Instance := {}
; 	Instance.Base := this.Prototype
; 	Instance.InstanceValueProp := 'More customization.'
; 	...
; 	return Instance
; }

; Usage.
MsgBox ClassObject.ClassValueProp
MsgBox ClassObject.ClassDynamicProp
ClassObject.ClassMethod()

Instance := ClassObject.New()
MsgBox Instance.InstanceValueProp
MsgBox Instance.InstanceDynamicProp
Instance.InstanceMethod()