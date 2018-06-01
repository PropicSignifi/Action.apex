# Action.apex
Action.apex is a tiny library that removes the pain points from Salesforce Lightning server controllers.

## Why Action.apex?
Action.apex aims to solve some pitfalls in Lightning server controllers. First of all is that you cannot receive custom types in your `@AuraEnabled` method arguments. Instead, you receive strings and deserialize them, which is ugly. Then you have to surround every `@AuraEnabled` method with try-catch block to return the AuraHandledException, so that the front end can show anything except the **Internal Server Error**. Action.apex comes with solutions to get rid of these harassment from your Lightning server controllers.

## Dependencies
Action.apex has a dependency over [R.apex](https://github.com/Click-to-Cloud/R.apex/).

Please include it before including Action.apex.

## Preliminary Knowledge
You don't really need any knowledge on R.apex before you can move on with Action.apex. Knowledge on R.apex will be a plus, though.

## Getting Started

### Actions
In Action.apex, an important step is to put your server controller logic into objects called Actions. Actions represent standalone remote actions with meta information like the name, parameters and return types. Here is how we define a custom action:

```java
public class MessageDTO {
    public String content;
}

public class CustomAction extends Action {
    public CustomAction() {
        super('echo'); // Define the unqiue name of the action

        // Define parameter information
        param('msg', MessageDTO.class, 'The input message');
        // Auto convert to map as MessageDTO does not have AuraEnabled fields
        returnRaw();
    }

    public override Object execAction(Object arg) {
        MessageDTO msg = (MessageDTO)arg;

        return msg;
    }
}
```

This is a very simple implementation that echoes whatever it receives a `MessageDTO`.

We can define multiple parameters, and correspondingly we need to implement `execAction` methods as below:

| Method | Description |
| ------ | ----------- |
| execAction() | Execute action with no arguments |
| execAction(Object) | Execute action with one argument |
| execAction(Object, Object) | Execute action with two arguments |
| execAction(Object, Object, Object) | Execute action with three arguments |
| execActionN(List&lt;Object&gt;) | Execute action with more than 3 arguments |

### Action Registry
The next step is to register the action.

```java
Action.Registry registry = new Action.Registry();
registry.action(new CustomAction());
```

### Invoke Server Controllers
Then we can set up our action registry in Lightning server controller method.

```java
@AuraEnabled
public static Object invoke(String name, Map<String, Object> args) {
    return registry.invoke(name, args);
}
```

So now we can call the server action in this way.

```javascript
var action = cmp.get("c.invoke");
action.setParams({
    name: 'echo',
    args: {
        input: {
            content: 'message',
        },
    },
});

action.setCallback(this, function(response) {
    // ...
});

$A.enqueueAction(action);
```

And the whole flow is ready.

### What Action.apex did

In this example, behind the scenes, Action.apex helps us to:

- Convert the input parameters to MessageDTO
- Catch any exceptions thrown and rethrow it as AuraHandledExceptions
- Auto convert MessageDTO into map objects so that it can be serialized

