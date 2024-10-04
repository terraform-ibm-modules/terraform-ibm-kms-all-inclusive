# Configuring keys in a KMS in IBM Cloud projects

When you add a key management service from the IBM Cloud catalog to an IBM Cloud Projects service, you can configure key rings and keys. In the edit mode for the projects configuration, select the Configure panel and then click the optional tab.

In the configuration, specify the name of the key ring and whether the key ring exists. The object also contains a list of keys with all the information about the keys that you want to create in that key ring.

To enter a custom value, use the edit action to open the "Edit Array" panel. Add the KMS key ring and key configurations to the array here.


## Options
### Key Ring options

- `key_ring_name` (required): A unique human-readable name that identifies this key ring. To protect your privacy, do not use personal data, such as your name or location. The key ring name can be between 2 and 100 characters.
- `existing_key_ring` (optional, default = `false`): Set to true if the key ring already exists and keys should be added to it.

### Key options

- `key_name` (required): A human-readable name that identifies this key. To protect your privacy, do not use personal data, such as your name or location. The key name can be between 2 and 90 characters.
- `rotation_interval_month` (optional, default = 1): Configures the key rotation interval.
- `standard_key` (optional, default false): whether a standard encryption key is created. For more information, see [Key types](https://cloud.ibm.com/docs/key-protect?topic=key-protect-envelope-encryption#key-types).
- `dual_auth_delete_enabled`  (optional, default = `false`): Whether to use dual authorization when deleting the key. For more information, see [Using dual authorization](https://cloud.ibm.com/docs/key-protect?topic=key-protect-manage-dual-auth).
- `force_delete` (optional, default = `true`): Whether to force delete the key. For more information, see [Considerations before deleting and purging a key](https://cloud.ibm.com/docs/key-protect?topic=key-protect-delete-purge-keys#delete-purge-keys-considerations).

The following example includes all the configuration options for two key rings. One ring contains two keys.

    [
      {
        "key_ring_name": "da-ring-1",
        "existing_key_ring": false,
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
