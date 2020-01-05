; Implement a producer-consumer relationship, emulate 'yield' and coroutines.
;
; A queue of determinate capacity is passed to a 'for' loop. The queue automatically
; enqueues elements (from the set of natural numbers) until full ("producer"), then
; control is relinquished back to the 'for' loop ("consumer") to process the elements.
;
; For reference: https://en.wikipedia.org/wiki/Coroutine#Comparison_with_subroutines

class Queue extends Array
{
	; Internal use only: number counter.
	N := 0

	; Queue max capacity.
	Size := 0

	IsEmpty[] => !this.Length
	IsFull[] => this.Length = this.Size

	/*
		Define the maximum number of elements the queue
		may contain at a time.
	*/
	__New(capacity)
	{
		this.Size := capacity
	}

	/*
		Insert elements at the back of the queue.
		Same semantics as 'Push'.
	*/
	Enqueue(Args*)
	{
		ExceedsCapacity() => Args.Length + this.Length > this.Size

		if ExceedsCapacity()
			throw Exception(
				Format(
					"Enqueueing {} elements exceeds the queue's current capacity ({}).",
					Args.Length,
					this.Size
				), -1)

		this.Push(Args*)
	}

	/*
		Pop elements from the front of the queue.
	*/
	Dequeue()
	{
		if !this.IsEmpty
			return this.RemoveAt(1)

		throw Exception('Dequeueing from an already empty queue.', -1)
	}

	__Enum(argCount)
	{
		; For the sake of brevity.
		if (argCount = 1)
			throw Exception("One parameter 'for' loop unsupported.", -1)

		; Loop iteration count.
		loopIndex := 1

		; Wiki: "coroutine produce"
		Enumerator(ByRef index, ByRef Q)
		{
			MsgBox 'Enqueuing...'

			; Wiki: "while q is not full"
			while !this.IsFull
			{
				; Wiki: "create some new items"
				item := this.N++

	            ; Wiki: "add the items to q"
				this.Enqueue(item)
			}

			MsgBox 'Full!'

			loopIndex++
			index := loopIndex

			; Reassigning the queue itself to one of the 'for' loop's
			; outparams allows one pick a custom variable name for use
			; inside the 'for' loop's body.
			Q := this

			; Wiki: "yield to consume"
			; In other words, 'yield' to the 'for' loop.
			return true
		}

		return Func('Enumerator')
	}
}

; Wiki: "var q := new queue"
ThreeItemQueue := Queue.New(3)

; Wiki: "coroutine consume"
for i, Q in ThreeItemQueue
{
	MsgBox 'Processing...'

	; Wiki: "while q is not empty"
	while !Q.IsEmpty
	{
		; Wiki: "remove some items from q"
		item := Q.Dequeue()

		; Wiki: "use the items"
		MsgBox item
	}

	MsgBox 'Empty!'

	; Wiki: "yield to produce"
	; About to exit the 'for' loop's scope, effectively
	; 'yield'-ing back to the enumerator routine.
} until (i = 2) ; Limit to 2 iterations for the sake of the example.

; The queue persists for as long as it is needed (or desired).
; Create and add some items.
ThreeItemQueue.Enqueue('a', 'b', 'c')

; Processing resumes, based on the current state of the queue.
; Notice how no new numbers shall be enqueued (as doing so would
; exceed the queue's capacity) until after the already enqueued
; letters have all been processed.
for i, Q in ThreeItemQueue
{
	MsgBox 'Processing...'

	while !Q.IsEmpty
	{
		item := Q.Dequeue()
		MsgBox item
	}

	MsgBox 'Empty!'
} until (i = 2)