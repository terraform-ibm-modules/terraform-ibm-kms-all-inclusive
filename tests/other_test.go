package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

const slzExampleTerraformDir = "examples/slz"

func TestRunSlzExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "slz-example", slzExampleTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
