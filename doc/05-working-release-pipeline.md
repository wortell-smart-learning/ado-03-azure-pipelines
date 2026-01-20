# Working release pipeline

This is the definition for a working release pipeline, as we worked it out in [task 4](04-setting-up-releasepipeline.md).
You can use this as a reference implementation for what we tried to achieve in task 4. 

```yaml
Sure! Here's the translation of the comments inside the YAML pipeline:

# Build Pipeline for SQL Database

# The *trigger* specifies what automatically triggers this pipeline. In this case: a *commit* to *main*
trigger:
- main

stages:
- stage: BuildStage

  jobs:
  - job: BuildJob

    # The *pool* specifies the VM image to be used for running this pipeline.
    # The vmImage property specifies what VM image is used (i.e. Operating System)
    pool:
      name: Azure Pipelines
      vmImage: windows-latest

    variables:
      BuildConfiguration: 'Release'

    # Here come the actual "build steps". In this case, we have a "simple" build pipeline - later we will look into pipelines with multiple "stages".
    steps:
    ### You don't need to remember the configuration of a "task": Azure DevOps Pipelines has built-in visual tools to add *tasks* and configure their settings.
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

    # The Artifact is the result of this pipeline. By publishing it, a deployment pipeline can pick it up for deployment to other environments.
    - task: PublishPipelineArtifact@1
      inputs:
        targetPath: '$(Build.ArtifactStagingDirectory)'
        artifact: 'SQLDW'
        publishLocation: 'pipeline'


- stage: DeployToDevStage
  jobs:
  - job: DeployToDevJob

    pool: 
      name: Azure Pipelines
      vmImage: windows-latest

    steps:
    - task: DownloadPipelineArtifact@2
      inputs:
        buildType: 'current'
        artifactName: 'SQLDW'
        targetPath: '$(Pipeline.Workspace)'

    - task: SqlAzureDacpacDeployment@1
      inputs:
        azureSubscription: 'Azure ARM connection (Wortell Smart Learning)'
        AuthenticationType: 'server'
        ServerName: '<< FILL IN SQL DATABASE SERVER FROM AZURE >>.database.windows.net'
        DatabaseName: '<< FILL IN SQL DATABASE NAME FROM AZURE >>'
        SqlUsername: 'student'
        SqlPassword: '<<FILL IN PASSWORD OF ADMIN SQL USER >>'
        deployType: 'DacpacTask'
        DeploymentAction: 'Publish'
        DacpacFile: '$(Pipeline.Workspace)/AdventureWorksDW.dacpac'
        IpDetectionMethod: 'AutoDetect'
```
