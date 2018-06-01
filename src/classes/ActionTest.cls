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
@isTest
private class ActionTest {
    @isTest
    private static void simpleTest() {
        Action.Registry registry = new Action.Registry();
        Object val = null;

        registry
            .action('Boolean')
            .delegate(R.identity)
            .param('input', Boolean.class);
        val = true;
        System.assertEquals(val, registry.invoke('Boolean', new Map<String, Object>{ 'input' => val }));
        System.assertEquals(val, registry.invoke('Boolean', new Map<String, Object>{ 'input' => JSON.serialize(val) }));

        registry
            .action('Integer')
            .delegate(R.identity)
            .param('input', Integer.class);
        val = 1;
        System.assertEquals(val, registry.invoke('Integer', new Map<String, Object>{ 'input' => val }));
        System.assertEquals(val, registry.invoke('Integer', new Map<String, Object>{ 'input' => JSON.serialize(val) }));

        registry
            .action('Long')
            .delegate(R.identity)
            .param('input', Long.class);
        val = 1;
        System.assertEquals(val, registry.invoke('Long', new Map<String, Object>{ 'input' => val }));
        System.assertEquals(val, registry.invoke('Long', new Map<String, Object>{ 'input' => JSON.serialize(val) }));

        registry
            .action('Double')
            .delegate(R.identity)
            .param('input', Double.class);
        val = 1;
        System.assertEquals(val, registry.invoke('Double', new Map<String, Object>{ 'input' => val }));
        System.assertEquals(val, registry.invoke('Double', new Map<String, Object>{ 'input' => JSON.serialize(val) }));

        registry
            .action('Decimal')
            .delegate(R.identity)
            .param('input', Decimal.class);
        val = 1;
        System.assertEquals(val, registry.invoke('Decimal', new Map<String, Object>{ 'input' => val }));
        System.assertEquals(val, registry.invoke('Decimal', new Map<String, Object>{ 'input' => JSON.serialize(val) }));

        registry
            .action('String')
            .delegate(R.identity)
            .param('input', String.class);
        val = 'abc';
        System.assertEquals(val, registry.invoke('String', new Map<String, Object>{ 'input' => val }));

        registry
            .action('List')
            .delegate(R.identity)
            .param('input', List<Object>.class);
        val = new List<Object>{ 'abc' };
        System.assertEquals(val, registry.invoke('List', new Map<String, Object>{ 'input' => val }));

        registry
            .action('Set')
            .delegate(R.identity)
            .param('input', Set<String>.class);
        val = new Set<String>{ 'abc' };
        System.assertEquals(val, registry.invoke('Set', new Map<String, Object>{ 'input' => val }));
        System.assertEquals(val, registry.invoke('Set', new Map<String, Object>{ 'input' => JSON.serialize(val) }));

        registry
            .action('Map')
            .delegate(R.identity)
            .param('input', Map<String, Object>.class);
        val = new Map<String, Object>{ 'name' => 'test' };
        System.assertEquals(val, registry.invoke('Map', new Map<String, Object>{ 'input' => val }));
        System.assertEquals(val, registry.invoke('Map', new Map<String, Object>{ 'input' => JSON.serialize(val) }));

        registry
            .action('SObject')
            .delegate(R.identity)
            .param('input', SObject.class);
        val = new Account(Name='test');
        System.assertEquals(val, registry.invoke('SObject', new Map<String, Object>{ 'input' => val }));
        System.assertEquals(val, registry.invoke('SObject', new Map<String, Object>{ 'input' => JSON.serialize(val) }));

        registry
            .action('Date')
            .delegate(R.identity)
            .param('input', Date.class);
        val = Date.newInstance(2018, 1, 1);
        System.assertEquals(val, registry.invoke('Date', new Map<String, Object>{ 'input' => val }));
        System.assertEquals(val, registry.invoke('Date', new Map<String, Object>{ 'input' => JSON.serialize(val) }));

        registry
            .action('Time')
            .delegate(R.identity)
            .param('input', Time.class);
        val = Time.newInstance(10, 0, 0, 0);
        System.assertEquals(val, registry.invoke('Time', new Map<String, Object>{ 'input' => val }));
        System.assertEquals(val, registry.invoke('Time', new Map<String, Object>{ 'input' => JSON.serialize(val) }));

        registry
            .action('Datetime')
            .delegate(R.identity)
            .param('input', Datetime.class);
        val = Datetime.newInstance(2018, 1, 1, 10, 0, 0);
        System.assertEquals(val, registry.invoke('Datetime', new Map<String, Object>{ 'input' => val }));
        System.assertEquals(val, registry.invoke('Datetime', new Map<String, Object>{ 'input' => JSON.serialize(val) }));
    }

    @isTest
    private static void custionActionTest() {
        Action.Registry registry = new Action.Registry();
        registry.description('desc');

        registry.action(new Custom0Action());
        registry.action(new Custom1Action());
        registry.action(new Custom2Action());
        registry.action(new Custom3Action());
        registry.action(new Custom4Action());

        System.assertEquals(0, registry.invoke('Custom0', new List<Object>{ }));
        System.assertEquals(1, registry.invoke('Custom1', new List<Object>{ 1 }));
        System.assertEquals(2, registry.invoke('Custom2', new List<Object>{ 1, 1 }));
        System.assertEquals(3, registry.invoke('Custom3', new List<Object>{ 1, 1, 1 }));
        System.assertEquals(4, registry.invoke('Custom4', new List<Object>{ 1, 1, 1, 1 }));

        registry.action(new Invalid0Action());
        registry.action(new Invalid1Action());
        registry.action(new Invalid2Action());
        registry.action(new Invalid3Action());
        registry.action(new Invalid4Action());

        try {
            registry.invoke('Invalid0', new List<Object>{  });
            System.assert(false);
        }
        catch(Exception e) {
        }

        try {
            registry.invoke('Invalid1', new List<Object>{  });
            System.assert(false);
        }
        catch(Exception e) {
        }

        try {
            registry.invoke('Invalid2', new List<Object>{  });
            System.assert(false);
        }
        catch(Exception e) {
        }

        try {
            registry.invoke('Invalid3', new List<Object>{  });
            System.assert(false);
        }
        catch(Exception e) {
        }

        try {
            registry.invoke('Invalid4', new List<Object>{  });
            System.assert(false);
        }
        catch(Exception e) {
        }
    }

    private class Invalid0Action extends Action {
        public Invalid0Action() {
            super('Invalid0');
        }
    }

    private class Invalid1Action extends Action {
        public Invalid1Action() {
            super('Invalid1');

            param('a', Integer.class);
        }
    }

    private class Invalid2Action extends Action {
        public Invalid2Action() {
            super('Invalid2');

            param('a', Integer.class);
            param('b', Integer.class);
        }
    }

    private class Invalid3Action extends Action {
        public Invalid3Action() {
            super('Invalid3');

            param('a', Integer.class);
            param('b', Integer.class);
            param('c', Integer.class);
        }
    }

    private class Invalid4Action extends Action {
        public Invalid4Action() {
            super('Invalid4');

            param('a', Integer.class);
            param('b', Integer.class);
            param('c', Integer.class);
            param('d', Integer.class);
        }
    }

    private class Custom0Action extends Action {
        public Custom0Action() {
            super('Custom0');
        }

        public override Object execAction() {
            return 0;
        }
    }

    private class Custom1Action extends Action {
        public Custom1Action() {
            super('Custom1');

            param('a', Integer.class);
        }

        public override Object execAction(Object a) {
            return a;
        }
    }

    private class Custom2Action extends Action {
        public Custom2Action() {
            super('Custom2');

            param('a', Integer.class);
            param('b', Integer.class);
        }

        public override Object execAction(Object a, Object b) {
            return (Integer)a + (Integer)b;
        }
    }

    private class Custom3Action extends Action {
        public Custom3Action() {
            super('Custom3');

            param('a', Integer.class);
            param('b', Integer.class);
            param('c', Integer.class);
        }

        public override Object execAction(Object a, Object b, Object c) {
            return (Integer)a + (Integer)b + (Integer)c;
        }
    }

    private class Custom4Action extends Action {
        public Custom4Action() {
            super('Custom4');

            param('a', Integer.class);
            param('b', Integer.class);
            param('c', Integer.class);
            param('d', Integer.class);
        }

        public override Object execActionN(List<Object> args) {
            return (Integer)args.get(0) + (Integer)args.get(1) + (Integer)args.get(2) + (Integer)args.get(3);
        }
    }
}
