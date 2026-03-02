package main

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
)

func main() {
	raw, err := io.ReadAll(os.Stdin)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	var payload map[string]interface{}
	if len(raw) > 0 {
		_ = json.Unmarshal(raw, &payload)
	}

	out := map[string]interface{}{
		"plugin_kind": "__PLUGIN_ID__",
		"status":      "ok",
		"message":     "Go plugin executed",
	}
	buf, _ := json.Marshal(out)
	fmt.Println(string(buf))
}
