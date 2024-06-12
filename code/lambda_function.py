# from forex_python.converter import CurrencyRates
# c = CurrencyRates()
# h = c.get_rates('USD')

# print(h)

# def lambda_handler(event, context):
#    content = """
#    <html>
#    <h1> Hello Website running on Lambda! Deployed via Terraform </h1>
#    </html>
#    """
#    response ={
#      "statusCode": 200,
#      "body": content,
#      "headers": {"Content-Type": "text/html",}, 
#    }
#    return response

def lambda_handler(event, context):
    # Extract the input integer from the event
    print(event)
    input_integer = int(event['queryStringParameters']['number'])
    
    # Calculate the square of the input integer
    square = input_integer ** 2
    
    # Prepare the HTML content with the result
    content = f"""
    <html>
    <h1> Hello Website running on Lambda! Deployed via Terraform </h1>
    <p> The square of {input_integer} is {square}. </p>
    </html>
    """
    
    # Prepare the response
    response = {
        "statusCode": 200,
        "body": content,
        "headers": {"Content-Type": "text/html"},
    }
    
    return response
