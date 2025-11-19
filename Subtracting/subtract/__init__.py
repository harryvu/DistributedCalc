import logging
import json
import azure.functions as func


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request for subtraction.')

    a = req.params.get('a')
    b = req.params.get('b')
    
    if not a or not b:
        try:
            req_body = req.get_json()
            a = req_body.get('a')
            b = req_body.get('b')
        except ValueError:
            pass

    if a and b:
        try:
            a_float = float(a)
            b_float = float(b)
            result = a_float - b_float
            
            return func.HttpResponse(
                json.dumps({
                    "operation": "subtraction",
                    "a": a_float,
                    "b": b_float,
                    "result": result
                }),
                mimetype="application/json",
                status_code=200
            )
        except ValueError:
            return func.HttpResponse(
                "Please provide valid numbers for parameters 'a' and 'b'",
                status_code=400
            )
    else:
        return func.HttpResponse(
            "Please provide parameters 'a' and 'b' in query string or request body",
            status_code=400
        )
