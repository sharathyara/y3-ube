## ffdp-ube
This is the repo where we shall push all the code related to connecting FFDP to UB Kafka cluster
- The Data Ingestion to FFDP platform
- The CDC using Apache Hudi

## Conventional Commits & Versioning
We are using [semver](https://semver.org/) for versioning the artifacts from master build/releases. Moreover, we have decided to use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification for git commits. **Therefore, please follow conventional commits specifications 
for formatting your git commit messages.** You may read the details by going through
the links but in short your commit message must follow the follow pattern:

```bash
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

We do have a linter in the pipeline which ensures that commits follow the convention.

## Working with Parameters
We have added automation to generate parameters file. Therefore, a new structure has been defined. Please read the details [here](src/parameters-conf/README.md).

## Working with DB Changes
In order to automate database deployments, we have introduced open-source tool named [Liquibase](https://www.liquibase.org/). It is a very powerful yet flexible tool. We highly recommend you to watch [this video](https://yara-my.sharepoint.com/:v:/p/a839865/Eafe_sI61QtPjz9b31eUCPgBhzcfO0W6qUzMmpBksw0qUA) for a detailed demo. 

The idea is to treat database changes as software changes and the flow is similar to the etl-scripts. To summarize, once the database changes, get merged to master branch, a new version will be automatically released and deployed to ffdp-stage environment. The version can then be deployed to higher environments by triggering the pipeline.

A particular release of this repository via [etl-scripts-release-pipeline](https://github.com/yaradigitallabs/ffdp-ube/actions/workflows/etl-scripts-release-pipeline.yaml) contains two artifacts: ```db-scripts``` and ```etl-scripts``` as can be seen [here](https://github.com/yaradigitallabs/ffdp-ube/releases/tag/3.0.0). Moreover, the [etl-scripts-deploy-pipeline](https://github.com/yaradigitallabs/ffdp-ube/actions/workflows/etl-scripts-deploy-pipeline.yaml) has been modified to incorporate database deployment. In order words, the deployment pipeline will trigger the database deployment first before proceeding with the etl-scripts deployment.

In order to work with database changes, all you need is to follow these instructions:
- Create the particular script under [redshift-database/scripts](redshift-database/scripts) directory. 
- Follow the naming convention of the filename as: <ddddd_script_brief_name> where ddddd is the 5 digits prefix which you may get by adding "10" in the 5 digits of last script. For instance, if the last script is 00010_add_drop_me_schema.sql then you should have your script named as 00020_add_drop_me_table.sql. The reason of keeping a margin of 10 is to have some flexibility for future scripts.
- Liquibase requires some metadata on the script. Below is an example script which contains bare minimum metadata which we must have:
    ```sql
    --liquibase formatted sql

    --changeset KamranManzoor:ATI-5895-add-initial-dummy-script
    --comment: ATI-5895 - DB automation using liquibase
    select 'Hello World';

    --rollback select 'Hello World';
    ```

  ```--liquibase formatted sql``` indicates that the script is controlled by liquibase ```--changeset author:id attribute1:value1 attribute2:value2 [...]``` A changeset is the basic unit of change in Liquibase. Liquibase attempts to execute each changeset in a transaction that is committed at the end, or rolled back if there is an error. A changeset is uniquely tagged by both the author and id attributes. The ```id``` tag is just an identifier, it doesn't direct the order that changes are run and doesn't have to be an integer and therefore, we recommend using ```JIRA-ID-brief-description``` as id format. Please see [this page](https://docs.liquibase.com/concepts/changelogs/sql-format.html) for more details about possible attributes. Some of them like ```splitStatements``` might required for a bit complex changeset including procedures ```--comment: any useful comment``` is a field where one may write any useful comment related to the changeset ```--rollback SQL STATEMENT``` is a field which include statements to be applied when rolling back the changeset
- It is important to specify one change per changeset to make each change "atomic" within a single transaction. Moreover, one may specify more changesets in a single sql file but for simplicity, we would encourage to have one changeset in a single file. Please see [this page](https://docs.liquibase.com/concepts/bestpractices.html) for more best practices.
