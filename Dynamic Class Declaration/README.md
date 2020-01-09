# Dynamic Class Declaration

Requires: [`[v2.0-a108-a2fa0498]`](https://github.com/Lexikos/AutoHotkey_L/releases/tag/v2.0-a108)

## Objective

Declare and define a class object at runtime.

## Implementation

1. Create a new instance of `Class`. Assign it to a `global` variable.

	```autohotkey
	global ClassObject := Class.New()
	```

2. `Static` class value properties, dynamic properties and methods may then be defined on `ClassObject` as needed.

	```autohotkey
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
	```

3. Declare a `Prototype` property. Initialize it with an `Object`.

	```autohotkey
	ClassObject.Prototype := {}
	```

4. The `Prototype` contains all instance value properties, dynamic properties and methods.

	```autohotkey
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
	```

5. Define a class constructor.

	A. If no special initialization is required, copy `Object`'s constructor.

	```autohotkey
	ClassObject.DefineMethod(
		'New',
		Object.GetMethod('New')
	)
	```

	B. Otherwise, implement a custom constructor, which creates an instance object, customizes it and returns it. In order for the instance object to truly become an instance of the class object, the class's `Prototype` has to be assigned to the instance's `Base`.

	```autohotkey
	ClassObject.DefineMethod(
		'New',
		this => {Base: this.Prototype}
	)
	```

	Alternatively:
	```autohotkey
	ClassObject.DefineMethod(
		'New',
		Func('Constructor')
	)

	Constructor(this)
	{
		Instance := {}
		Instance.Base := this.Prototype
		Instance.InstanceValueProp := 'More customization.'
		...
		return Instance
	}
	```

	_Note:_ `this` is populated by `ClassObject`, since `New()` is being called on it, i.e. `ClassObject.New()`.

## Caveats

- The class static initializer `static __New()` is never called.
- `Super-global` declarations may only take place inside the `Auto-Execute Section`.
- No `#Warn` overwrite protection as the check is only performed once at compile time.