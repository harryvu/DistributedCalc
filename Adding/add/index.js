module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request for addition.');

    const a = parseFloat(req.query.a || (req.body && req.body.a));
    const b = parseFloat(req.query.b || (req.body && req.body.b));

    if (isNaN(a) || isNaN(b)) {
        context.res = {
            status: 400,
            body: "Please provide valid numbers for parameters 'a' and 'b' in query string or request body"
        };
        return;
    }

    const result = a + b;

    context.res = {
        status: 200,
        body: {
            operation: "addition",
            a: a,
            b: b,
            result: result
        }
    };
};
