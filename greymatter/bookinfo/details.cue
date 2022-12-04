package bookinfo

import (
	gsl "greymatter.io/gsl/v1"

	"bookinfo.module/greymatter:globals"
)

Details: gsl.#Service & {
	// A context provides global information from globals.cue
	// to your service definitions.
	context: Details.#NewContext & globals

	name:                      "details"
	display_name:              "Bookinfo Details"
	version:                   "v1.0.0"
	description:               "EDIT ME"
	api_endpoint:              "https://\(context.globals.edge_host)/\(context.globals.namespace)/\(name)"
	api_spec_endpoint:         "https://\(context.globals.edge_host)/\(context.globals.namespace)/\(name)"
	business_impact:           "low"
	owner:                     "Library"
	capability:                ""
	enable_instance_metrics:   true
	enable_historical_metrics: true

	health_options: {
		tls: gsl.#MTLSUpstream
	}
	// Details -> ingress to your container
	ingress: {
		(name): {
			gsl.#HTTPListener
			gsl.#MTLSListener

			//  NOTE: this must be filled out by a user. Impersonation allows other services to act on the behalf of identities
			//  inside the system. Please uncomment if you wish to enable impersonation. If the servers list if left empty,
			//  all traffic will be blocked.
			// filters: [
			//    gsl.#ImpersonationFilter & {
			//  #options: {
			//   servers: ""
			//   caseSensitive: false
			//  }
			//    }
			// ]
			routes: {
				"/": {
					upstreams: {
						"local": {
							instances: [
								{
									host: "127.0.0.1"
									port: 9080
								},
							]
						}
					}
				}
			}
		}
	}

	edge: {
		edge_name: "edge"
		routes: "/bookinfo/details": upstreams: (name): {
			namespace: "bookinfo"
			gsl.#MTLSUpstream
		}
	}
}

exports: "details": Details
