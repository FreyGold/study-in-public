# Context Basics

**context.Context** is a control value for one operation. **ctx** is the usual variable name.

It can carry:

- A cancellation signal.
- A deadline.
- Small operation metadata.

It does not run work or force a function to stop. Lower code must receive it and observe its signal.

## Root and child

~~~go
ctx, cancel := context.WithTimeout(
    context.Background(),
    5*time.Second,
)
defer cancel()
~~~

**Background()** creates an empty root. **WithTimeout** creates a timed child.

The child ends when:

- Five seconds pass.
- Its parent ends.
- The owner calls **cancel()**.

Call **cancel()** even when work finishes early. It stops the unused timer and releases related resources.

Cancellation moves from parent to child. It does not move from child to parent.

This context has no connection to an HTTP user:

~~~go
context.WithTimeout(context.Background(), 5*time.Second)
~~~

This child inherits HTTP request cancellation:

~~~go
context.WithTimeout(request.Context(), 5*time.Second)
~~~

The code that creates a cancelable context owns its cancel function. Other functions receive **ctx** and pass it down.
