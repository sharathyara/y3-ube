
class FFDPLogger:

    def __init__(self, traceId, jobName, jobRunId):
        self.service = "gluejob"
        self.jobName = jobName
        self.jobRunId = jobRunId 
        self.traceId = traceId 


    def get_message(self, message:str):
        return f"trace-Id: {self.traceId} service: {self.service} name: {self.jobName} instance: {self.jobRunId} message: {message}"
