package envoy.authz

default allow = false
allow {
	any({
		input.attributes.request.http.method == "GET",
	})
}

