# Asynq Task Context

The producer stores a timeout setting in the task:

~~~go
asynq.NewTask(
    TaskWelcome,
    payload,
    asynq.Timeout(30*time.Second),
)
~~~

This does not create a live context.

When the worker starts the task, Asynq:

1. Reads the timeout.
2. Calculates a deadline.
3. Creates a context.
4. Adds task metadata.
5. Passes the context to the handler.

~~~go
func (j *JobService) handleWelcomeEmailTask(
    ctx context.Context,
    task *asynq.Task,
) error
~~~

The task context belongs to one task attempt. It is separate from the original HTTP request. The task can continue after that request ends.

## Current project limit

~~~text
Asynq context
      |
      v
Handler receives ctx
      |
      x
Email client receives no ctx
~~~

The handler does not pass **ctx** to the email client. The 30-second cancellation signal does not reach Resend.

The repository also has no caller for **NewWelcomeEmailTask** and no **Enqueue** call.
