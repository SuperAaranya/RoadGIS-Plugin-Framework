package main

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
)

type Payload struct {
	FeatureCount int `json:"feature_count"`
}

func main() {
	raw, err := io.ReadAll(os.Stdin)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	var payload Payload
	if len(raw) > 0 {
		_ = json.Unmarshal(raw, &payload)
	}
	out := map[string]interface{}{
		"plugin_kind": "hello_world",
		"message":     "Hello from Go plugin",
		"features":    payload.FeatureCount,
	}
	buf, _ := json.Marshal(out)
	fmt.Println(string(buf))
}
