class FuncObjBase
{
	/*
		It is desirable to have the standard function object's
		properties and methods automatically inherited upon the
		instantiation of the derived class, without having to resort to
		approaches, which would pollute the deriving class's interface
		(such as initialization inside constructors and static
		initializers).

		Initialization inside a constructor would require the derived
		class's constructor to invoke an instance method (belonging to
		the base class, which would perform the initialization) and
		then delete the method (so as to avoid polluting its own
		interface). While this approach certainly works, it is
		suboptimal, since the deriving class necessarily has to define
		a constructor and perform the initialization, which imposes
		additional unwanted burden on the end-user and is also error
		prone.

		Another approach is having the dedicated initialization method
		called by an instance variable (belonging to the base class).
		This addresses the issue of the end-user having to necessarily
		define a constructor and remember to invoke the initialization
		method, however, it presents a new one - namely, the derived
		class's interface is now polluted with the instance variable,
		which invoked the initialization routine. It is not possible
		for the routine to automatically delete it, since it will be
		executed in the context of the '__Init()' method and the
		variable will not yet have been defined (unable to delete
		something, which does not yet exist), until after '__Init()'
		has returned.

		It is also desirable to detect attempts to instantiate the base
		class and prevent them, since the class is meant to act as an
		abstract one - instantiating it on its own is meaningless.

		Therefore, avoid defining any instance variables and override
		the base class's '__Init()' method instead. Perform a check to
		detect whether whichever class is being instantiated implements
		a 'Call()'. If so, proceed with transplanting the methods and
		properties. Otherwise, either the end-user is either trying to
		instantiate the base class or their derived class is not
		callable (eg., forgot to implement 'Call()'). Prevent the
		instantiation in either case and throw.
	*/
	__Init()
	{
		; Failing to retrieve a reference to the derived class's 'Call()'
		; method aborts the instantiation, for reasons explained earlier.
		try
			fnCall := this.Base.GetMethod('Call')
		catch
			throw Exception(
				'No implementation provided for abstract method.',
				-1,
				this.__Class '.Call()'
			)

		; Cached with 'static'. No reason not to.
		static fn := () => ''

		; Func::Bind(fnReference, Args*) -> BoundFunc
		static fnBind := fn.Base.GetMethod('Bind')

		; Since 'Func::Bind(fnReference, Args*)' returns an object of
		; type 'BoundFunc', merely adopting the standard 'Bind()'
		; implementation would result in the derived instance being
		; overwritten with a 'BoundFunc' instance the very first time
		; the end-user attempts to invoke 'Bind()'. This is obviously
		; highly undesirable as it could lead to a potential "loss" of
		; instance variables and methods. Additionally, it would be
		; confusing and difficult to debug.
		; Therefore, provide a custom implementation for 'Bind()',
		; which invokes the native function, redefines the 'Call()'
		; method to one where the arguments that were passed to
		; 'Bind()' are already bound and lastly return the derived
		; class instance.
		this.Base.DefineMethod('Bind', Func('BindImpl'))

		/*
			this - The derived class instance, automatically inserted by
				   the runtime at the time of invocation.
			[Args*] - The user-supplied argument(s) to be bound.
		*/
		BindImpl(this, Args*)
		{
			; Retrieve the *current* implementation of 'Call()', since
			; function object could have possibly been re-bound an
			; indeterminate number of times.
			fnCall := this.Base.GetMethod('Call')

			; 'Func::Bind(fnReference, Args*) -> BoundFunc' expects a function
			; reference as its first argument, which indicates which function
			; 'Bind()' is meant to bind arguments to. Omit providing a value
			; for the second argument (which is the hidden 'this' in a standard
			; instance method's signature - 'Call(this, [Args*])'), since the
			; runtime will automatically populate this argument with the
			; instance of the derived class whenever it is invoked. Lastly,
			; bind any arguments supplied to 'DerivedClass::Bind(Args*)' per
			; usual, i.e., simply expand the array of parameters.
			bfCall := %fnBind%(fnCall, , Args*)

			; Replace the existing 'Call()' method with the bound counterpart.
			this.Base.DefineMethod('Call', bfCall)

			; Return the instance of the derived class itself instead of
			; an unrelated newly instantiated 'BoundFunc' object.
			return this
		}

		; Func::IsByRef(fnReference, [paramIndex]) -> int
		static fnIsByRef := fn.Base.GetMethod('IsByRef')
		; Func::IsOptional(fnReference, [paramIndex]) -> int
		static fnIsOptional := fn.Base.GetMethod('IsOptional')

		; The methods expect a function reference for their first
		; (normally hidden) parameter.
		; Bind the deriving class's 'Call()' method.
		bfIsByRef := fnIsByRef.Bind(fnCall)
		bfIsOptional := fnIsOptional.Bind(fnCall)

		; Since in 'Derived::Call(this, [Args*])' the hidden, implicit
		; 'this' is the first parameter, invoking these functions would
		; produce technically correct, yet rather unintuitive results
		; (index mismatch due to the hidden 'this').
		; To rectify this, a manual check is performed and the indices
		; are then adjusted accordingly.
		this.Base.DefineMethod('IsByRef', Func('IsByRefOptionalImpl').Bind(bfIsByRef))
		this.Base.DefineMethod('IsOptional', Func('IsByRefOptionalImpl').Bind(bfIsOptional))

		/*
			fn - The 'IsByRef' or 'IsOptional' bound function.
			this - The derived class instance, automatically inserted by
				   the runtime at the time of invocation.
			[paramIndex] - The user-supplied one-based index of a parameter.
		*/
		IsByRefOptionalImpl(fn, this, paramIndex := '')
		{
			ParameterIndexException(what)
			{
				; 'paramIndex' captured from the enclosing lexical scope.
				throw Exception('Parameter #1 invalid. ' what '.', -2, paramIndex)
			}

			switch
			{
			; "If omitted, 'Boolean' indicates whether the function has
			; any 'ByRef'/optional parameters."
			case (paramIndex == ''): return %fn%()

			; Prohibit invalid indices and types (strings, floats, objects).
			case !(paramIndex is 'Integer'): ParameterIndexException('NaN')
			case (paramIndex = 0): ParameterIndexException('Invalid zero index')
			case (paramIndex < 0): ParameterIndexException('Invalid negative index')

			; Prohibit indices exceeding the function's parameter count,
			; except for variadic functions.
			case (!this.IsVariadic && paramIndex + 1 > this.MaxParams):
				ParameterIndexException('Index out of bounds')

			; Increment once to account for the hidden 'this'.
			default: return %fn%(paramIndex + 1)
			}
		}

		this.Base.DefineProp('Name', {get: this => this.__Class})
		this.Base.DefineProp('IsBuiltIn', {get: this => false})

		; These properties are effectively hard-coded to reflect the
		; properties of the 'Call()' method at the point of
		; instantiation and are also adjusted to account for the hidden
		; 'this'. Going for this approach can, however, prove to be
		; problematic if the end-user decides to redefine 'Call()'
		; themselves after instantiation - they would also have to
		; redefine *these* properties on their own, too.
		; While it is possible to implement the properties in a way
		; such that they would inspect the current 'Call()'
		; implementation dynamically, this alternative approach is not
		; entirely flawless either - particularly, when 'Bind()' is
		; used and has overwritten the 'Call()' implementation,
		; accessing the properties would incorrectly query the 'Bind()'
		; method's interface instead of that of 'Call()'.
		isVariadic := fnCall.IsVariadic
		minParams := fnCall.MinParams - 1
		maxParams := fnCall.MaxParams - 1
		this.Base.DefineProp('IsVariadic', {get: this => isVariadic})
		this.Base.DefineProp('MinParams', {get: this => minParams})
		this.Base.DefineProp('MaxParams', {get: this => maxParams})
	}
}