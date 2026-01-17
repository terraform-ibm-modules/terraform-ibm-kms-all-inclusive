# Advanced private only instance with CBRs

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=kms-all-inclusive-advanced-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-kms-all-inclusive/tree/main/examples/advanced"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An advanced example that shows how to provision a private only Key Protect instance with a new Key Ring and Key.

The following resources are provisioned by this example:
 - A new resource group, if an existing one is not passed in.
 - A CBR zone for the Schematics service.
 - A new Secrets Manager instance with private cert engine configured if one is not passed in.
 - A new Secrets Manager managed private certificate.
 - A new private Key Protect instance in the given resource group and region.
 - A new KMS key ring.
 - New KMS root keys and KMIP adapters using the Secrets Manager managed private certificate.
 - A context-based restriction (CBR) rule to only allow Key Protect to be accessible from Schematics zone.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
