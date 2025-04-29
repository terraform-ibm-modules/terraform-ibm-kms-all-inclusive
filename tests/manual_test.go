package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"
)

func setupAddonOptions(t *testing.T, prefix string) *testaddons.TestAddonOptions {
	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:              t,
		Prefix:               prefix,
		ResourceGroup:        "Default",
	})

	return options
}

func TestRunTerraformAddonFullyConfigurable(t *testing.T) {
	t.Parallel()

	options := setupAddonOptions(t, "test-terraform-addon")

	// Using the specialized Terraform helper function
	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,        // prefix for unique resource naming
		"deploy-arch-ibm-kms",           // offering name
		"fully-configurable",          // offering flavor
		map[string]interface{}{ // inputs
			"prefix": options.Prefix,
			"region": "us-south",
			"existing_resource_group_name": options.ResourceGroup,
		},
	)

	err := options.RunAddonTest()
	assert.Nil(t, err, "This should not have errored")
}

