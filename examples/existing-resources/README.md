# Existing KMS example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=kms-all-inclusive-existing-resources-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-kms-all-inclusive/tree/main/examples/existing-resources">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

A simple example that shows how to provision a KMS root key in an existing KMS instance and Key Ring.

The following resources are provisioned by this example:
- A new KMS root key in the default key ring of an existing KMS instance
