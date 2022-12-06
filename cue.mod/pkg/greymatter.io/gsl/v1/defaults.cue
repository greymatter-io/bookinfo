// Copyright 2022, greymatter.io Inc., All rights reserved.  
package v1

#DEFAULT_ZONE: "default-zone"

#DefaultHTTP2Options: {
	allow_connect: true
}

#DefaultRBAC: {
	rules: {
		action: "ALLOW"
		policies: {
			all: {
				permissions: [
					{
						any: true
					},
				]
				principals: [
					{
						any: true
					},
				]
			}
		}
	}
}

#DefaultOPAUpstream: {
	http2_protocol_options: #DefaultHTTP2Options
}

#DefaultOPAEgress: {
	#options: {
		namespace:    string
		service_name: *"opa" | string
	}

	routes: "/": upstreams: (#options.service_name): #DefaultOPAUpstream & {namespace: #options.namespace}
}

#DefaultContext: #GlobalContext & {
	mesh: {
		name:                    *"greymatter-mesh" | _
		datastore_upstream_name: *"datastore" | _
		operator_namespace:      *"gm-operator" | _
	}

	sidecar: {
		// port for ingress traffic, matching the operator 
		default_ingress_port: *10808 | _
		// port of the healtcheck service
		healthcheck_port: *10910 | _
		// port the sidecar serves metrics requests from
		metrics_port: *8081 | _
	}

	spire: {
		trust_domain: *"greymatter.io" | _
	}

	edge_host: *"" | _
}
