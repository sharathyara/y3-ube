import json

def json_function(string):
    try: 
        string = json.loads(string)
        return json.dumps(string)
    except:
        string = str("\""+str(string)+"\"")
        return string