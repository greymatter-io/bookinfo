package bookinfo

import (
	gsl "greymatter.io/gsl/v1"

	"bookinfo.module/greymatter:globals"
)

Reviews_V2: gsl.#Service & {
	// A context provides global information from globals.cue
	// to your service definitions.
	context: Reviews_V2.#NewContext & globals

	name:              "reviews-v2"
	display_name:      "Bookinfo Reviews v2"
	version:           "v2.0.0"
	description:       "EDIT ME"
	api_endpoint:      "https://\(context.globals.edge_host)/\(context.globals.namespace)/\(name)"
	api_spec_endpoint: "https://\(context.globals.edge_host)/\(context.globals.namespace)/\(name)"
	business_impact:   "low"
	owner:             "Library"
	capability:        ""

	health_options: {
		tls: gsl.#MTLSUpstream
	}
	// Reviews-V2 -> ingress to your container
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
									port: 9090
								},
							]
						}
					}
				}
			}
		}
	}
	egress: {
		"backends": {
			gsl.#HTTPListener
			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]
			port: context.globals.custom.default_egress
			routes: {
				"/ratings/": {
					prefix_rewrite: "/ratings/"
					upstreams: {
						"ratings-v1": {
							gsl.#MTLSUpstream
							namespace: "bookinfo"
						}
					}
				}
			}
		}
	}

	edge: {
		edge_name: "edge"
		routes: "/bookinfo/reviews-v2": upstreams: (name): {
			namespace: "bookinfo"
			gsl.#MTLSUpstream
		}
	}
}

exports: "reviews-v2": Reviews_V2
