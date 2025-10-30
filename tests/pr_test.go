// Tests in this file are run in the PR pipeline
package test

import (
	"fmt"
	"log"
	"math/rand"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

/*
Global variables
*/
const resourceGroup = "geretain-test-key-protect-all-inclusive"
const terraformVersion = "terraform_v1.12.2" // This should match the version in the ibm_catalog.json
const fullyConfigurableDADir = "solutions/fully-configurable"
const securityEnforcedDADir = "solutions/security-enforced"
const advancedExampleTerraformDir = "examples/advanced"
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var tags = []string{"test-schematic", "kms-all-inc"}
var validRegions = []string{
	"au-syd",
	"br-sao",
	"ca-tor",
	"eu-de",
	"eu-gb",
	"eu-es",
	"jp-osa",
	"jp-tok",
	"us-south",
	"us-east",
}
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

func setupSchematicOptions(t *testing.T, prefix string, dir string) *testschematic.TestSchematicOptions {
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                    t,
		TarIncludePatterns:         []string{"*.tf", fmt.Sprintf("%s/*.tf", dir)},
		TemplateFolder:             dir,
		Prefix:                     prefix,
		Tags:                       tags,
		DeleteWorkspaceOnFail:      false,
		WaitJobCompleteMinutes:     60,
		Region:                     validRegions[rand.Intn(len(validRegions))],
		TerraformVersion:           terraformVersion,
		CheckApplyResultForUpgrade: true,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
		{Name: "key_protect_resource_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "key_protect_access_tags", Value: permanentResources["accessTags"], DataType: "list(string)"},
		{Name: "keys", Value: []map[string]interface{}{{"key_ring_name": "my-key-ring", "keys": []map[string]interface{}{{"key_name": "some-key-name-1"}, {"key_name": "some-key-name-2"}}}}, DataType: "list(object)"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "region", Value: options.Region, DataType: "string"},
	}

	return options
}

func TestRunUpgradeFullyConfigurableDA(t *testing.T) {
	t.Parallel()

	options := setupSchematicOptions(t, "kms-fc-up", fullyConfigurableDADir)

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.NoError(t, err, "Schematic Test had an unexpected error")
	}
}

func TestRunSecurityEnforcedDA(t *testing.T) {
	t.Parallel()

	options := setupSchematicOptions(t, "kms-se", securityEnforcedDADir)
	options.TarIncludePatterns = append(options.TarIncludePatterns, fmt.Sprintf("%s/*.tf", fullyConfigurableDADir))
	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had an unexpected error")
}

func TestRunUpgradeSecurityEnforcedDA(t *testing.T) {
	t.Parallel()

	options := setupSchematicOptions(t, "k-se-up", securityEnforcedDADir)
	options.TarIncludePatterns = append(options.TarIncludePatterns, fmt.Sprintf("%s/*.tf", fullyConfigurableDADir))
	options.TarIncludePatterns = append(options.TarIncludePatterns, fmt.Sprintf("%s/*.tf", securityEnforcedDADir))
	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.NoError(t, err, "Schematic Test had an unexpected error")
	}
}

func TestRunAdvancedExample(t *testing.T) {
	t.Parallel()

	options := setupSchematicOptions(t, "kms-adv", advancedExampleTerraformDir)
	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_secrets_manager_crn", Value: permanentResources["secretsManagerCRN"], DataType: "string"},
		{Name: "existing_cert_template_name", Value: permanentResources["privateCertTemplateName"], DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}
