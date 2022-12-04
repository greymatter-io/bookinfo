package bookinfo

import (
	gsl "greymatter.io/gsl/v1"

	"bookinfo.module/greymatter:globals"
)

Opa: gsl.#Service & {
	// A context provides global information from globals.cue
	// to your service definitions.
	context: Opa.#NewContext & globals

	// name must follow the pattern namespace/name
	name:            "opa"
	display_name:    "Bookinfo OPA"
	version:         "v1.0.0"
	description:     "Open Policy Agent service for enforcing security policy"
	business_impact: "low"
	owner:           "Library"
	capability:      "Security"
	health_options: {
		tls: gsl.#MTLSUpstream
	}

	ingress: {
		(name): {
			gsl.#HTTPListener

			http2_protocol_options: {
				allow_connect: true
			}
			routes: {
				"/": {
					upstreams: {
						"local": {
							http2_protocol_options: {
								allow_connect: true
							}
							instances: [
								{
									host: "127.0.0.1"
									port: 9191
								},
							]
						}
					}
				}
			}
		}
	}

	// // Edge config for the Opa service.
	// // These configs are REQUIRED for your service to be accessible
	// // outside your cluster/mesh.
	edge: {
		edge_name: "edge"
		routes: "/services/\(context.globals.namespace)/\(name)": upstreams: (name): {
			namespace: context.globals.namespace
		}
	}
}

// exports: "opa": Opa
