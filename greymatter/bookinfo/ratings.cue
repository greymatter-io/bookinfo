package bookinfo

import (
	gsl "greymatter.io/gsl/v1"

	"bookinfo.module/greymatter:globals"
)

Ratings: gsl.#Service & {
	context: Ratings.#NewContext & globals

	name:              "ratings"
	display_name:      "Bookinfo Ratings"
	version:           "v1.0.0"
	description:       "Provides ratings for books"
	api_endpoint:      "http://\(context.globals.edge_host)/\(context.globals.namespace)/\(name)"
	api_spec_endpoint: "http://\(context.globals.edge_host)/\(context.globals.namespace)/\(name)"
	business_impact:   "low"
	owner:             "Library"
	capability:        "Web"

	// Ratings -> ingress to your container
	ingress: {
		(name): {
			gsl.#HTTPListener
			routes: {
				"/": {
					upstreams: {
						"local": {
							instances: [{host: "127.0.0.1", port: 9080}]
						}
					}	
				}
			}
		}
	}

	edge: {
		edge_name: "edge"
		routes: {
			"/bookinfo/ratings": {
				prefix_rewrite: "/ratings/"
				upstreams: (name): {
					namespace: "bookinfo"
				}
			}
		}
	}
}

exports: "ratings": Ratings
