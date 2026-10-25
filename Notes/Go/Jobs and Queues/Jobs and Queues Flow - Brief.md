# Jobs and Queues Flow

A queue moves work out of the current call.

~~~text
Producer
   |
   v
Redis
   |
   v
Asynq worker
   |
   v
ServeMux
   |
   v
Task handler
~~~

- The task type identifies the work.
- The payload contains the business data.
- The task factory creates the task.
- The producer enqueues it.
- Redis stores it.
- The worker reads it.
- **ServeMux** selects the handler.
- The handler decodes the payload and performs the work.

The payload and context have different roles:

- Payload: data that must survive storage in Redis.
- Context: control state for one task attempt.

## Current project state

The project defines the welcome task, payload, factory, handler, and route.

No saved code calls **NewWelcomeEmailTask** or **Enqueue**. The producer is missing.

The executable also does not start the server. **main.go** only prints **Hello, World!**
