/**
 * MIT License
 *
 * Copyright (c) 2018 Click to Cloud Pty Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 **/
/**
 * Action object that wraps the lightning server remote actions
 *
 * Example:
 *
 * // Define custom action
 * private class CustomAction extends Action {
 *     public CustomAction() {
 *         super('getMessage');
 *
 *         param('input', String.class, 'input field');
 *     }
 *
 *     public override Object execAction(Object arg) {
 *         String input = (String)arg;
 *         return input;
 *     }
 * }
 *
 * // Register the custom action
 * Action.Registry registry = new Action.Registry();
 *
 * registry.action(new CustomAction());
 *
 * */
public virtual class Action extends Func {
    // The function delegator
    private Func impl;

    // Whether we return the raw object. If set to true, we will convert the raw object into a map
    private Boolean returnRaw = false;

    // The name of the action
    @AuraEnabled
    public String name;

    // The params of the action
    @AuraEnabled
    public List<ActionParam> params;

    /**
     * Create an action with the name and Func
     *
     * Example:
     * new Action('test', R.identity);
     *
     * @param name The action name
     * @param f The delegated function
     * */
    public Action(String name, Func f) {
        super(-1);

        this.name = name;
        this.params = new List<ActionParam>();
        this.delegate(f);
    }

    /**
     * Create an action with the name
     *
     * Example:
     * new Action('test');
     *
     * @param name The name of the action
     * */
    public Action(String name) {
        this(name, null);
    }

    /**
     * Add an action parameter
     *
     * Example:
     * new Action('test')
     *     .param('input', String.class, 'Input parameter');
     *
     * @param name The name of the action param
     * @param typeClass The type of the action param
     * @param description The description of the param
     * @return Action
     * */
    public Action param(String name, Type typeClass, String description) {
        this.params.add(new ActionParam(name, typeClass, description));

        return this;
    }

    /**
     * Add an action parameter
     *
     * Example:
     * new Action('test')
     *     .param('input', String.class);
     *
     * @param name The name of the action param
     * @param typeClass The type of the action param
     * @return Action
     * */
    public Action param(String name, Type typeClass) {
        return this.param(name, typeClass, null);
    }

    /**
     * Delegate the action to the function, so that the function will carry the logic
     *
     * Example:
     * new Action('test').delegate(R.identity);
     *
     * @param f The delegated function
     * @return Action
     * */
    public Action delegate(Func f) {
        this.impl = f;

        return this;
    }

    /**
     * Set if the action will return a raw object, which does not have 'AuraEnabled' annotations on the fields
     *
     * Example:
     * new Action('test', R.identity)
     *     .returnRaw();
     *
     * @return Action
     * */
    public Action returnRaw() {
        this.returnRaw = true;

        return this;
    }

    // Execute the action as a function
    public override Object execN(List<Object> args) {
        List<Object> argList = new List<Object>();
        for(Integer i = 0; i < this.params.size(); i++) {
            ActionParam param = this.params.get(i);
            Object arg = R.nth.run(i, args);
            argList.add(this.convertArgument(arg, param.paramTypeClass));
        }

        try {
            Object result = null;
            if(this.impl != null) {
                result = this.impl.runN(argList);
            }
            else {
                if(argList.size() == 0) {
                    result = this.execAction();
                }
                else if(argList.size() == 1) {
                    result = this.execAction(argList.get(0));
                }
                else if(argList.size() == 2) {
                    result = this.execAction(argList.get(0), argList.get(1));
                }
                else if(argList.size() == 3) {
                    result = this.execAction(argList.get(0), argList.get(1), argList.get(2));
                }
                else {
                    result = this.execActionN(argList);
                }
            }

            // If integrated with Log.apex, call Log.flush at the end of each action
            Func flush = Func.require('Log.flush', R.noop);
            flush.run();

            if(this.returnRaw) {
                String jsonStr = JSON.serialize(result);
                return JSON.deserializeUntyped(jsonStr);
            }
            else {
                return result;
            }
        }
        catch(Exception e) {
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Get called when there are more than 3 arguments
     *
     * @param args The arg list
     * @return Object
     * */
    public virtual Object execActionN(List<Object> args) {
        throw new AuraHandledException('Action is not implemented');

        return null;
    }

    /**
     * Get called when there is no argument
     *
     * @return Object
     * */
    public virtual Object execAction() {
        throw new AuraHandledException('Action is not implemented');

        return null;
    }

    /**
     * Get called when there is only one argument
     *
     * @param arg
     * @return Object
     * */
    public virtual Object execAction(Object arg) {
        throw new AuraHandledException('Action is not implemented');

        return null;
    }

    /**
     * Get called when there are two arguments
     *
     * @param arg1 The first argument
     * @param arg2 The second argument
     * @return Object
     * */
    public virtual Object execAction(Object arg1, Object arg2) {
        throw new AuraHandledException('Action is not implemented');

        return null;
    }

    /**
     * Get called when there are 3 arguments
     *
     * @param arg1 The first argument
     * @param arg2 The second argument
     * @param arg3 The third argument
     * @return Object
     * */
    public virtual Object execAction(Object arg1, Object arg2, Object arg3) {
        throw new AuraHandledException('Action is not implemented');

        return null;
    }

    private Object convertArgument(Object arg, Type argType) {
        if(argType == Boolean.class) {
            if(arg instanceof Boolean) {
                return arg;
            }
            else if(arg instanceof String){
                return JSON.deserialize((String)arg, Boolean.class);
            }
            else {
                return R.toBoolean.run(arg);
            }
        }
        else if(argType == Integer.class) {
            if(arg instanceof Integer) {
                return arg;
            }
            else if(arg instanceof String){
                return JSON.deserialize((String)arg, Integer.class);
            }
            else {
                return R.toInteger.run(arg);
            }
        }
        else if(argType == Long.class) {
            if(arg instanceof Long) {
                return arg;
            }
            else if(arg instanceof String){
                return JSON.deserialize((String)arg, Long.class);
            }
            else {
                return R.toLong.run(arg);
            }
        }
        else if(argType == Double.class) {
            if(arg instanceof Double) {
                return arg;
            }
            else if(arg instanceof String){
                return JSON.deserialize((String)arg, Double.class);
            }
            else {
                return R.toDouble.run(arg);
            }
        }
        else if(argType == Decimal.class) {
            if(arg instanceof Decimal) {
                return arg;
            }
            else if(arg instanceof String){
                return JSON.deserialize((String)arg, Decimal.class);
            }
            else {
                return R.toDecimal.run(arg);
            }
        }
        else if(argType == String.class) {
            if(arg instanceof String) {
                return arg;
            }
            else {
                return R.toString.run(arg);
            }
        }
        else if(argType == List<Object>.class) {
            if(arg instanceof List<Object>) {
                return arg;
            }
            else if(arg instanceof String) {
                return JSON.deserializeUntyped((String)arg);
            }
            else {
                return R.toList.run(arg);
            }
        }
        else if(argType == Set<String>.class) {
            if(arg instanceof Set<String>) {
                return arg;
            }
            else if(arg instanceof String){
                return JSON.deserialize((String)arg, Set<String>.class);
            }
            else {
                return R.toSet.run(arg);
            }
        }
        else if(argType == Map<String, Object>.class) {
            if(arg instanceof Map<String, Object>) {
                return arg;
            }
            else if(arg instanceof String){
                return JSON.deserializeUntyped((String)arg);
            }
            else {
                return R.toMap.run(arg);
            }
        }
        else if(argType == SObject.class) {
            if(arg instanceof SObject) {
                return arg;
            }
            else if(arg instanceof String){
                return JSON.deserialize((String)arg, SObject.class);
            }
            else {
                return R.toSObject.run(arg);
            }
        }
        else if(argType == Date.class) {
            if(arg instanceof Date) {
                return arg;
            }
            else if(arg instanceof String){
                return JSON.deserialize((String)arg, Date.class);
            }
            else {
                return R.toDate.run(arg);
            }
        }
        else if(argType == Time.class) {
            if(arg instanceof Time) {
                return arg;
            }
            else if(arg instanceof String){
                return JSON.deserialize((String)arg, Time.class);
            }
            else {
                return R.toTime.run(arg);
            }
        }
        else if(argType == Datetime.class) {
            if(arg instanceof Datetime) {
                return arg;
            }
            else if(arg instanceof String){
                return JSON.deserialize((String)arg, Datetime.class);
            }
            else {
                return R.toDatetime.run(arg);
            }
        }
        else {
            String jsonStr = null;
            if(arg instanceof String) {
                jsonStr = (String)arg;
            }
            else {
                jsonStr = JSON.serialize(arg);
            }

            return JSON.deserialize(jsonStr, argType);
        }
    }

    /**
     * A registry to manage all the actions
     * */
    public class Registry {
        // The description of the registry
        @AuraEnabled
        public String description;

        // The registered actions
        @AuraEnabled
        public Map<String, Action> actions;

        /**
         * Create a default registry
         * */
        public Registry() {
            this.actions = new Map<String, Action>();
        }

        /**
         * Register an action with name, create one if not found
         *
         * @param name The name of the action
         * @return Action
         * */
        public Action action(String name) {
            if(this.actions.get(name) == null) {
                this.actions.put(name, new Action(name));
            }

            return this.actions.get(name);
        }

        /**
         * Register the action
         *
         * @param a The action
         * @return Action
         * */
        public Action action(Action a) {
            if(a != null) {
                this.actions.put(a.name, a);
            }

            return a;
        }

        /**
         * Set the description
         *
         * @param description The description of the registry
         * @return Registry
         * */
        public Registry description(String description) {
            this.description = description;

            return this;
        }

        /**
         * Invoke the action with name and args
         *
         * Example:
         * registry.invoke('test', new List<Object>{ 'a', 'b' });
         *
         * @param name The name of the action
         * @param args The arguments to be passed to the action
         * @return Object
         * */
        public Object invoke(String name, List<Object> args) {
            Action instance = this.actions.get(name);
            if(instance == null) {
                throw new AuraHandledException('Action not found for [' + name + ']');
            }

            return instance.runN(args);
        }

        /**
         * Invoke the action with name and args
         *
         * Example:
         * registry.invoke('test', new Map<String, Object>{ 'name' => 'test' });
         *
         * @param name The name of the action
         * @param args The arguments to be passed to the action
         * @return Object
         * */
        public Object invoke(String name, Map<String, Object> args) {
            Action instance = this.actions.get(name);
            if(instance == null) {
                throw new AuraHandledException('Action not found for [' + name + ']');
            }

            List<Object> argList = new List<Object>();
            for(ActionParam param : instance.params) {
                argList.add(args.get(param.paramName));
            }

            return this.invoke(name, argList);
        }
    }

    /**
     * The action parameter
     * */
    public class ActionParam {
        // Parameter name
        @AuraEnabled
        public String paramName;

        // Parameter type
        @AuraEnabled
        public String paramType;

        // Parameter description
        @AuraEnabled
        public String paramDescription;

        // Parameter type class
        public Type paramTypeClass;

        public ActionParam(String name, Type typeClass, String description) {
            this.paramName = name;
            this.paramTypeClass = typeClass;
            this.paramType = String.valueOf(typeClass);
            this.paramDescription = description;
        }
    }
}
