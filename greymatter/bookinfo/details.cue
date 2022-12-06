package bookinfo

import (
	gsl "greymatter.io/gsl/v1"

	"bookinfo.module/greymatter:globals"
)

Details: gsl.#Service & {
	context: Details.#NewContext & globals

	name:              "details"
	display_name:      "Bookinfo Details"
	version:           "v1.0.0"
	description:       "Provides product details on books"
	api_endpoint:      "https://\(context.globals.edge_host)/\(context.globals.namespace)/\(name)"
	api_spec_endpoint: "https://\(context.globals.edge_host)/\(context.globals.namespace)/\(name)"
	business_impact:   "low"
	owner:             "Library"
	capability:        "Web"

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
		routes: "/bookinfo/details": {
			prefix_rewrite: "/"
			upstreams: (name): {
				namespace: "bookinfo"
			}
		}
	}
}

exports: "details": Details
