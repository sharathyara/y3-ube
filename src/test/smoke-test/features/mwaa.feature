Feature: Testing MWAA Airflow DAGs
  In order to validate correct MWAA deployment, a smoke test
  dag needs to triggered and run successfully

  Scenario: Trigger Smoke Test DAG
    Given MWAA is live and CLI token can be obtained
    When the smoke test dag is triggered
    Then MWAA API returns code 200

    Given smoke test dag has been triggered
    When dag status is requested from MWAA API
    Then MWAA API returns status "success"
	 
    Given smoke test dag has completed its run
    When the status of all tasks is requested from MWAA API
    Then the status is recorded

  Scenario Outline: Check status of individual tasks
    When the status of a task is queried
    Then the status of task <task_id> is listed as "success"

  Examples: Tasks
    | task_id              |
    | bash_test            |
    | test_internet_access |
    | xcom_test            |
    | pip_package_test     |
    | get_failed_dags      |
    | dag_error_test       |
    | test_ffdp_redshift   |
    | test_one21_redshift  |
    | check_dbt_version    |
    | run_dbt_model        |
    | print_dbt_logs       |
