# Configuring complex inputs for KMS in IBM Cloud projects

Several optional input variables in the IBM Cloud [KMS all inclusive deployable architecture](https://cloud.ibm.com/catalog#deployable_architecture) use complex object types. You specify these inputs when you configure deployable architecture.

* Rules For Context-Based Restrictions (`cbr_rules`)


## Rules For Context-Based Restrictions <a name="cbr_rules"></a>

The `cbr_rules` input variable allows you to provide a list of rules for the target service in this case the KMS all inclusive DA instance to enforce access restrictions for the instance based on the context of access requests. Context are criterias that include the network location of access requests, the endpoint type from where the request is sent etc ..

- Variable name: `cbr_rules`.
- Type: A list of objects. Each object represents a set of rules
- Default value: An empty list (`[]`).

### Options for cbr_rules

  - `description` (required): The description of the rule to create.
  - `account_id` (required): The IBM Cloud Account ID
  - `rule_contexts` (required): (List) The contexts the rule applies to
      - `attributes` (optional): (List) Individual context attributes 
        - `name` (required): The attribute name.
        - `value`(required): The attribute value.

  - `enforcement_mode` (required): The rule enforcement mode: `enabled` - The restrictions are enforced and reported. This is the default. `disabled` - The restrictions are disabled. Nothing is enforced or reported. `report` - The restrictions are evaluated and reported, but not enforced.
  - `operations` (optional): The operations this rule applies to
    - `api_types`(required): (List) The API types this rule applies to.
        - `api_type_id`(required):The API type ID

### Example Rules For Context-Based Restrictions Configuration

```hcl
cbr_rules = [
  {
  description = "rule from terraform"
  account_id = "abac0df06b6......."
  rule_contexts= [{
    attributes = [{
        name  = "networkZoneId"
         value = "559052eb8f43302824e7........." # pragma: allowlist secret
          }]
        }]
  enforcement_mode = "enabled"
  operations = [{ 
    api_types = [{
     api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
      }]
    }]
  }
]
```

