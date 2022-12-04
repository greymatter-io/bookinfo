package envoy.authz

default allow = false
allow {
	any({
		input.attributes.request.http.method == "PUT",
		input.attributes.request.http.method == "POST"
	})
}

