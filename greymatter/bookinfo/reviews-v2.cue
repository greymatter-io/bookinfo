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
	display_name:      "Bookinfo Reviews"
	version:           "v2.0.0"
	description:       "Holds reviews for books"
	api_endpoint:      "http://\(context.globals.edge_host)/\(context.globals.namespace)/\(name)"
	api_spec_endpoint: "http://\(context.globals.edge_host)/\(context.globals.namespace)/\(name)"
	business_impact:   "low"
	owner:             "Library"
	capability:        "Web"

	// Reviews-V2 -> ingress to your container
	ingress: {
		(name): {
			gsl.#HTTPListener
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
			port: context.globals.custom.default_egress
			routes: {
				"/ratings/": {
					prefix_rewrite: "/ratings/"
					upstreams: {
						"ratings": {
							namespace: "bookinfo"
						}
					}
				}
			}
		}
	}

	edge: {
		edge_name: "edge"
		routes: "/bookinfo/reviews-v2/": {
			prefix_rewrite: "/reviews/"
			upstreams: (name): {
				namespace: "bookinfo"
			}
		}
	}
}

exports: "reviews-v2": Reviews_V2
