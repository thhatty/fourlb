# Copilot Instructions

## Expected Folder Structure for Trainer Demo Deploy

```
Root/
├── .devcontainer              [ For DevContainer ]
├── .github                    [ Configure GitHub workflow or Azure Pipelines ]
│   ├── copilot-instructions.md [ Instructions for Copilot ]
├── .vscode                    [ VS Code workspace configurations ]
├── demoguide
│   ├── demoguide.md           [ description of one or more demos that can be used by this template for instructors ]
├── infra                      [ Creates and configures Azure resources ]
│   ├── main.bicep             [ Main infrastructure file ]
│   ├── main.parameters.json   [ Parameters file ]
├── src                        [ Contains directories for the app code ]
└── azure.yaml                 [ Describes the app and type of Azure resources ]
├── README.md                  [ Overview of the demo and basic azd commands ]
```

This is a deployment for 4 different demos, each deployed into its own resource group from the #main.bicep. 
The demos are named:

Azure Load Balancer - #lb1.bicep
Azure App Gateway - #lb2.bicep
Azure Traffic Manager - #tm.bicep
Azure Front Door - #fd.bicep
