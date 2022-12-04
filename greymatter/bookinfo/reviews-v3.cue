package bookinfo

import (
	gsl "greymatter.io/gsl/v1"

	"bookinfo.module/greymatter:globals"
)

Reviews_V3: gsl.#Service & {
	// A context provides global information from globals.cue
	// to your service definitions.
	context: Reviews_V3.#NewContext & globals

	name:              "reviews-v3"
	display_name:      "Bookinfo Reviews v3"
	version:           "v3.0.0"
	description:       "Holds reviews for books"
	api_endpoint:      "https://\(context.globals.edge_host)/\(context.globals.namespace)/\(name)"
	api_spec_endpoint: "https://\(context.globals.edge_host)/\(context.globals.namespace)/\(name)"
	business_impact:   "low"
	owner:             "Library"
	capability:        ""

	health_options: {
		tls: gsl.#MTLSUpstream
	}
	ingress: {
		(name): {
			gsl.#HTTPListener
			// gsl.#MTLSListener

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
					upstreams: {
						"ratings": {
							namespace: "bookinfo"
							// gsl.#MTLSUpstream
						}
					}
				}
			}
		}
	}

	edge: {
		edge_name: "edge"
		routes: "/bookinfo/reviews-v3": {
			prefix_rewrite: "/"
			upstreams: (name): {
				namespace: "bookinfo"
			}
		}
	}
}

exports: "reviews-v3": Reviews_V3
