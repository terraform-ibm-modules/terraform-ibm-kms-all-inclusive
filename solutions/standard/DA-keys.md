# Configuring keys in a KMS in IBM Cloud projects

When you add a key management service from the IBM Cloud catalog to an IBM Cloud Projects service, you can configure key rings and keys. In the edit mode for the projects configuration, select the Configure panel and then click the optional tab.

In the configuration, specify the name of the key ring, whether the key ring exists, and whether to force the deletion of the key. The object also contains a list of keys with all the information about the keys that you want to create in that key ring.

To enter a custom value, use the edit action to open the "Edit Array" panel. Add the KMS key ring and key configurations to the array here.
The following example includes all the configuration options for two key rings. One ring contains two keys.

    [
      {
        "key_ring_name": "da-ring-1",
        "existing_key_ring": false,
        "force_delete_key_ring": true,
        "keys": [
          {
            "key_name": "da-key-1-1",
            "rotation_interval_month": 1,
            "standard_key": false,
            "dual_auth_delete_enabled": false,
            "force_delete": true
          },
          {
            "key_name": "da-key-1-2",
            "rotation_interval_month": 1,
            "standard_key": false,
            "dual_auth_delete_enabled": false,
            "force_delete": true
          }
        ]
      },
      {
        "key_ring_name": "da-ring-2",
        "existing_key_ring": false,
        "force_delete_key_ring": true,
        "keys": [
          {
            "key_name": "da-key-2-1",
            "rotation_interval_month": 1,
            "standard_key": false,
            "dual_auth_delete_enabled": false,
            "force_delete": true
          }
        ]
      }
    ]


## Key Ring options

- `key_ring_name` (required) is the name choosen for the Key Ring
- `existing_key_ring` (optional, default false) can be set to true if the Key Ring already exists and Keys should be added to it
- `force_delete_key_ring` (optional, default true) configures the force option using destroy, or removing the configuration

## Key options

- `key_name` (required) is the name choosen for the Key
- `rotation_interval_month` (optional, default 1) configures the Key rotation interval
- `standard_key` (optional, default false) configures the Key type
- `dual_auth_delete_enabled`  (optional, default false) configures the dual authorization for deletion option to be used during destroy
- `force_delete` (optional, default true) configures the force option to be used during destroy
