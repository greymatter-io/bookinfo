package bookinfo

import (
	gsl "greymatter.io/gsl/v1"

	"bookinfo.module/greymatter:globals"
)

Productpage: gsl.#Service & {
	context: Productpage.#NewContext & globals

	name:              "productpage"
	display_name:      "Bookinfo Productpage"
	version:           "v1.0.0"
	description:       "Book info product web app"
	api_endpoint:      "https://\(context.globals.edge_host)/"
	api_spec_endpoint: "https://\(context.globals.edge_host)/"
	business_impact:   "low"
	owner:             "Library"
	capability:        "Web"

	ingress: {
		(name): {
			gsl.#HTTPListener
			routes: "/": upstreams: "local": instances: [{host: "127.0.0.1", port: 9090}]
		}
	}

	egress: "backends": {
		gsl.#HTTPListener
		port: context.globals.custom.default_egress
		routes: {
			"/details/": {
				upstreams: {
					"details": {
						namespace: "bookinfo"
					}
				}
			}
			"/reviews/": {
				upstreams: {
					"reviews-v1": {
						namespace: "bookinfo"
					}
				}
			}
		}
	}

	edge: {
		edge_name: "edge"
		routes: "/": upstreams: (name): {namespace: context.globals.namespace}

	}
}

exports: "productpage": Productpage
