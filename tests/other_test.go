// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

// import (
// 	"testing"

// 	"github.com/stretchr/testify/assert"
// 	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
// )

// func TestRunBasicExample(t *testing.T) {
// 	t.Parallel()

// 	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
// 		Testing:       t,
// 		TerraformDir:  "examples/basic",
// 		Prefix:        "kms-all-inc-basic",
// 		ResourceGroup: resourceGroup,
// 		TerraformVars: map[string]interface{}{
// 			"access_tags": permanentResources["accessTags"],
// 		},
// 	})
// 	output, err := options.RunTestConsistency()
// 	assert.Nil(t, err, "This should not have errored")
// 	assert.NotNil(t, output, "Expected some output")
// }

// func TestRunExistingResourcesExample(t *testing.T) {
// 	t.Parallel()

// 	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
// 		Testing:      t,
// 		TerraformDir: "examples/existing-resources",
// 		Prefix:       "kp-all-inc-exist",
// 	})

// 	terraformVars := map[string]interface{}{
// 		"existing_kms_instance_crn": permanentResources["hpcs_south_crn"],
// 	}
// 	options.TerraformVars = terraformVars

// 	output, err := options.RunTestConsistency()
// 	assert.Nil(t, err, "This should not have errored")
// 	assert.NotNil(t, output, "Expected some output")
// }
