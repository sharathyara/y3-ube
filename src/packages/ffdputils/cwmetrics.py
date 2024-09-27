def push_metrics(glue_job_run_id, glue_job_name='AvroFromS3ToHudiGlueJob', operation='INSERT', grp_cst_mtrcPDF=None, unit='None', metric_name='HudiCRUDMetric', metric_namespace='HudiDataOperations', hudi_table_name='farm', cloudwatch=None, glue_logger=None, log_former=None):
    metric_data = [
            {
                'MetricName': 'DefaultMetricName',
                'Dimensions': [
                    {
                        'Name': 'JobName',
                        'Value': 'DefaultJobName'
                    },
                    {
                        'Name': 'JobRunId',
                        'Value': 'DefaultJobRunId'
                    },
                    {
                        'Name': 'Operation',
                        'Value': 'DefaultOperation'
                    },
                    {
                        'Name': 'File',
                        'Value': 'DefaultFileName'
                    },
                    {
                        'Name': 'Entity',
                        'Value': 'DefaultEntityName'
                    }
                ],
                'Unit': 'None',
                'Value': 0
            },
        ]
    
    for idx in range(grp_cst_mtrcPDF.shape[0]):
        metric_data[0]['MetricName'] = metric_name
        metric_data[0]['Dimensions'][0]['Value'] = glue_job_name
        metric_data[0]['Dimensions'][1]['Value'] = glue_job_run_id
        metric_data[0]['Dimensions'][2]['Value'] = operation
        metric_data[0]['Dimensions'][3]['Value'] = (grp_cst_mtrcPDF["avroFilePath"][idx]).split("/")[-1]
        metric_data[0]['Dimensions'][4]['Value'] = hudi_table_name
        metric_data[0]['Unit'] = unit
        metric_data[0]['Value'] = int(grp_cst_mtrcPDF["record_count"][idx])
        response = cloudwatch.put_metric_data(
            MetricData = metric_data,
            Namespace = metric_namespace
        )
    glue_logger.info(log_former.get_message("Hudi operation metrics registered."))