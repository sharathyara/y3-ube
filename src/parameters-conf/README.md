# Working with Parameters
In order to avoid duplication, have better maintainability and be able to change the parameters in a fast and convenient way, we have introduced automation to generate the parameters files for the parameterized jobs (init and curated jobs atm). The parameters files are split and merged by pipeline in a hierarichal fashion in order to provide precedence option. The parameters defined in each deeper level will override the ones defined at the parent level. 

Following explains the hierarchy and how it works:

## Parameters common to all jobs (`base_parameters.json`)
`base_parameters.json` file contains parameters which are common to all the topics in all jobs. So atm the parameters which are common to all topics in both init and curated jobs should be defined here.

## Parameters common to all topics for a particular job (`job_parameters.json`)
The next level of parameters is defined via `job_parameters.json` inside each job type folder i.e., inside init and curated directories at the moment. The purpose of this file is to have the parameters which are common to all the topics for a particular job type. Parameters defined in this file will be given precedence and they will override parameters (if defined) in `base_parameters.json` file.  

## Parameters specific to a topic for a particular job (`topic_parameters.json`)
The purpose of this file is to contain topic specific parameters for a particular job. For instance, `topic_parameters.json` file inside `init/cnp` directory contains parameters particular to cnp topic for the init job. Therefore, topic specific parameters should be added to these files. Parameters defined in these files will be given precedence and they will override parameters (if defined) in `job_parameters.json` or `base_parameters.json` file.

## Parameters specific to a topic for a particular job for an environment (`env_parameters.json`)
This is the deepest level of hierarichy with highest priority. As the title states, the purpose of this file is to contain environment specific parameter for a particular topic in a particular job. For instance, if we want to change the concurrency parameter for user topic for the init job then we may use this file and define the parameter inside it. The location of file needs to be `<job>/<topic>/<env>/env_parameters.json`

## Rendering of environment specific vars
We have added functionality to define variables inside the parameter files. They can help in scenarios where a parameter may be common to all topics but require environment specific value like for example bucket names. In order to render the variable, the key-value pair must be define in environment specific map files located in this directory. An example file can be found [here](ffdp-stage.map).

# Automation Pipeline
Once you make the required change in this directory and perform push, Github workflow gets triggered and generates the parameter files located under [parameters](../parameters/README.md) directory. Since the `parameters` directory is also under version controlled, the *pipeline-bot* will push the generated files as a commit in your branch. The changeset will be visible once you create a PR. An example PR can be seen [here](https://github.com/yaradigitallabs/ffdp-ube/pull/234).    