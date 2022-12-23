# Existing resources example

An end-to-end example will:
- Create a new resource group (if existing one is not passed in).
- Create a new Key Protect instance in the region and resource group provided (outside of terraform-ibm-key-protect-all-inclusive module).
- Create a Key Ring within the Key Protect Instance (outside of terraform-ibm-key-protect-all-inclusive module).
- Pass the existing Key Protect instance into the terraform-ibm-key-protect-all-inclusive module and create a new Key in the existing Key Ring.
