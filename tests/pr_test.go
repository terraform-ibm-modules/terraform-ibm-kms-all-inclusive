// Tests in this file are run in the PR pipeline
package test

import (
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group for tests
const resourceGroup = "geretain-test-key-protect-all-inclusive"
const defaultExampleDir = "examples/default"
const existingResourcesExampleDir = "examples/existing-resources"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

func TestMain(m *testing.M) {
	// Read the YAML file contents
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"access_tags": permanentResources["accessTags"],
		},
	})

	return options
}

func TestRunDefaultExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "kp-all-inclusive", defaultExampleDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunExistingResourcesExample(t *testing.T) {
	t.Parallel()

	// options := setupOptions(t, "kp-all-inc-exist", existingResourcesExampleDir)
	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  existingResourcesExampleDir,
		Prefix:        "kp-all-inc-exist",
		ResourceGroup: resourceGroup,
	})

	terraformVars := map[string]interface{}{
		"prefix":                     options.Prefix,
		"existing_kms_instance_guid": permanentResources["hpcs_south"],
	}
	options.TerraformVars = terraformVars

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "kp-all-inclusive-upg", defaultExampleDir)
	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestDASolutionInSchematics(t *testing.T) {
	t.Parallel()

	const region = "us-south"

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "kp-solution",
		TarIncludePatterns: []string{
			"*.tf",
		},
		ResourceGroup:          resourceGroup,
		TemplateFolder:         "solutions/standard",
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
		Region:                 region,
	})

	// Workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5154
	options.AddWorkspaceEnvVar("IBMCLOUD_KP_API_ENDPOINT", "https://private."+region+".kms.cloud.ibm.com", false, false)

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "resource_group_name", Value: options.Prefix, DataType: "string"},
		{Name: "service_endpoints", Value: "private", DataType: "string"},
		{Name: "resource_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
		// {Name: "keys", Value: []string{key_ring_name = "default"}, DataType: "list(object)"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}
