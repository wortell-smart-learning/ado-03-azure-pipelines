# Setting up release pipeline

## Introduction

Compared to other CI/CD tools, Azure DevOps had a peculiar deviation until recently: although the tasks for build/release were largely the same, two different types of pipelines were maintained in two different user interfaces:

* Builds have been YAML-enabled for some time
* Releases have their own (graphical) interface with release-specific functionality

Since 2019 (preview) / 2020 (GA), this has been aligned: both builds and releases can now be defined in YAML. However, the legacy (graphical) release section is still available for now. In this course, we focus on the new *multi-stage* YAML functionality.

## Creating a multi-stage pipeline

The easiest way to automate a release is by extending your automated *build pipeline*. To do that, we need to convert your build pipeline into a *multi-stage pipeline*:

1. Go to **Pipelines** -> **Pipelines**
2. Select **03-azure-pipelines**
3. Click **Edit**
4. You will now see a YAML definition that is mostly identical to the definition you created in the previous task.

When you want to add multiple *stages* to your pipeline, at least two YAML elements that we haven't seen before need to be added:

* stages
* jobs

### Jobs

In our release pipelines, we have already used various blocks with `steps`. As BI and Data Platform developers within the Microsoft realm, this is not unusual so far: all our builds run on the same platform (namely Visual Studio with SSDT).

However, when building a larger solution, you may want to execute the *build* for different components on different types of servers. Or you may use certain variables slightly differently. In such cases, you can encapsulate your `pool` (with the server requirements), `variables`, and `steps` in a `job`.

**Jobs** were already available in "regular" pipelines, but we haven't used or needed them so far. In multi-stage pipelines, they are now a required component of the schema.

Adding a `job` to your build pipeline is quite simple:

5. Insert an empty line below the `trigger` definition, followed by the following two lines:

```yaml
jobs:
- job: BuildJob
```

6. Select all lines after the `job` definition and indent them one level further using the <kbd>Tab</kbd> key.

You have now added a *job* to your pipeline. As you can see, the structure has become one level deeper, but essentially nothing has changed in your pipeline itself.

### Stages

In a *multi-stage pipeline*, the top-level element is `stages`: this is what separates your *build* phase (or *build stage*) from your deployment.

Before we add the actual release steps or other *stages*, let's add the `stages` definition:

7. Insert an empty line below the `trigger` definition, followed by the following two lines:

```yaml
stages:
- stage: BuildStage
```

8. Select all lines after the `stage` definition and indent them one level further using the <kbd>Tab</kbd> key.

> ### The YAML Schema
>
> We haven't made any functional changes to the pipeline yet, but we have added several elements and levels to the pipeline. These levels (`stage` and `job`) are always present in YAML pipelines in principle. However, if you only have one *stage*, you can omit the *stages* definition. And if you only have one `stage` and one `job`, you can also omit the `jobs` definition.
> In our previous build pipeline, we had only one `job` and

 one `stage`. That's why we didn't use these elements before. However, with the addition of a `stage`, the intermediate `jobs` level must be explicitly specified.
>
> Microsoft has summarized a comprehensive description of the YAML pipeline definition possibilities on the page [https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema?view=azure-devops&tabs=schema](https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema?view=azure-devops&tabs=schema).

If everything is correct, your pipeline should now look more or less like this:

```yaml
# Build Pipeline for SQL Database

# The *trigger* specifies what triggers this pipeline to run automatically. In this case: a *commit* to *main*
trigger:
- main

stages:
- stage: BuildStage

  jobs:
  - job: BuildJob

    # The *pool* specifies the VM image to be used for running this pipeline. 
    pool:
      name: Azure Pipelines
      vmImage: windows-latest

    variables:
      BuildConfiguration: 'Release'

    # Here come the actual "build steps". In this case, we have a "simple" build pipeline - later, we will look at pipelines with multiple "stages".
    steps:
    ### You don't have to memorize the configuration of a "task": Azure DevOps Pipelines has built-in visual tools to add *tasks* and configure their settings.
    - task: VSBuild@1
      displayName: 'Build Data Warehouse'
      inputs:
        solution: 'src/sqldatabase/**/*.sqlproj'
        configuration: '$(BuildConfiguration)'

    - task: CopyFiles@2
      displayName: 'Copy Files to: $(Build.ArtifactStagingDirectory)'
      inputs:
        SourceFolder: '$(Build.SourcesDirectory)'
        Contents: '**/bin/$(BuildConfiguration)/**/*.dacpac'
        TargetFolder: '$(Build.ArtifactStagingDirectory)'
        flattenFolders: true

    # The artifact is the result of this pipeline. By publishing it, a deployment pipeline can pick it up to "roll out" to other environments.
    - task: PublishPipelineArtifact@1
      inputs:
        targetPath: '$(Build.ArtifactStagingDirectory)'
        artifact: 'SQLDW'
        publishLocation: 'pipeline'
```

## Adding release job

Setting up the "actual" release steps of a Release Pipeline is similar to the Build Pipeline.

9. Add a new line at the bottom of the YAML pipeline. Ensure that you don't have any indentation.
10. Add a new stage with the name DeployToDevStage:
    * `- stage: DeployToDevStage`
11. Using the YAML knowledge and examples from the *BuildStage* stage so far, configure the following:
    * Add a new job named `DeployToDevJob`
    * Create a series of steps with the following:
       * Download Pipeline Artifact
         * Retrieve the artifact from the build
         * The name is configured in your *PublishPipelineArtifact@1* task
       * Azure SQL Database deployment
         * Authentication type: SQL Server
         * Azure SQL Server: `<< FILL IN SQL DATABASE SERVER FROM AZURE >>-student01.database.windows.net` (replace *student01* with your own account name)
         * Database: `<< FILL IN SQL DATABASE NAME FROM AZURE >>-student01`
         * Login: student
         * Password: <<FILL IN PASSWORD OF ADMIN SQL USER >>
         * Deployment package: SQL DACPAC File
         * Action: Publish
         * DACPAC File: `$(Pipeline.Workspace)/AdventureWorksDW.dacpac`
12. Once you have a **working release**, try capturing the following properties in variables:
    * ServerName
    * DatabaseName
    * SqlUsername
    * SqlPassword

**If you need help, you can find the solution [here](05-working-release-pipeline.md)**