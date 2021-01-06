# Laravel Echo IOS

This project is a fork of a project initially done by [Bubbleflat : find your perfect roommate and flatsharing](https://bubbleflat.com)

This project is wrapper to use [Laravel Echo](https://github.com/laravel/echo) in Swift IOS project

This only work for **socket.io**, NOT FOR PUSHER yet !

## Installation

This module is only supports installation using SPM.


## Example

Import the framework:

```Swift
import LaravelEchoIOS
```

Keep a strong reference to the `Echo` instance (for example in your view controller):

```Swift
var echo: Echo?
```

Create `Echo` and connect (wait for connection to add listeners):

```Swift
echo = Echo(options: ["host":"http://localhost:6001", "auth": ["headers": ["Authorization": "Bearer " + token]]])
echo?.connect(callback: { [weak self] _, _ in
    print("CONNECTED")

    self?.echo?.join(channel: "conversation.243").listen(event: ".NewMessage", callback: { data, ack in
        print(data)
    })
}, timeoutHandler: { [weak self] in
    print("CONNECTION TIMEOUT")
    self?.echo = nil
})
```

## Options

- `host` - String, the host to connect
- `log` - Bool, whether to print SocketIO logs or not
- `auth` - Dictionary, authorization options

## Documentation

See [full Echo documentation](https://laravel.com/docs/5.5/broadcasting) for all available methods

**here, joining, leaving are not available yet**
