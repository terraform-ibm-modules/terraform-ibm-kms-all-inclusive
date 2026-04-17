# Basic example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=kms-all-inclusive-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-kms-all-inclusive/tree/main/examples/basic">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

A basic example that shows how to provision a Key Protect instance, Key Ring, and Keys.

The following resources are provisioned by this example:
- A new resource group, if an existing one is not passed in.
- A Key Protect instance in the resource group and region provided.
- A new Key Ring with multiple new Keys in the newly provisioned Key Protect instance.
