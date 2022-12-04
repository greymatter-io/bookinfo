package bookinfo

import (
	gsl "greymatter.io/gsl/v1"

	"bookinfo.module/greymatter:globals"
)

Productpage: gsl.#Service & {
	// A context provides global information from globals.cue
	// to your service definitions.
	context: Productpage.#NewContext & globals

	name:                      "productpage"
	display_name:              "Bookinfo Productpage"
	version:                   "v1.0.0"
	description:               "EDIT ME"
	api_endpoint:              "https://\(context.globals.edge_host)/productpage"
	api_spec_endpoint:         "https://\(context.globals.edge_host)/productpage"
	business_impact:           "low"
	owner:                     "Library"
	capability:                "Web"
	enable_instance_metrics:   true
	enable_historical_metrics: true

	health_options: {
		tls: gsl.#MTLSUpstream
	}
	// Productpage -> ingress to your container
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
				"/details/": {
					// prefix_rewrite: "/details/"
					upstreams: {
						"details-v1": {
							gsl.#MTLSUpstream
							namespace: "bookinfo"
						}
					}
				}
				"/ratings/": {
					// prefix_rewrite: "/ratings/"
					upstreams: {
						"ratings-v1": {
							gsl.#MTLSUpstream
							namespace: "bookinfo"
						}
					}
				}
				"/reviews/": {
					// prefix_rewrite: "/reviews/"
					upstreams: {
						"reviews-v1": {
							gsl.#MTLSUpstream
							namespace:       "bookinfo"
							traffic_options: gsl.#SplitTraffic & {
								weight: 100
							}
						}
						"reviews-v2": {
							gsl.#MTLSUpstream
							namespace:       "bookinfo"
							traffic_options: gsl.#SplitTraffic & {
								weight: 0
							}
						}
						"reviews-v3": {
							gsl.#MTLSUpstream
							namespace:       "bookinfo"
							traffic_options: gsl.#SplitTraffic & {
								weight: 0
							}
						}
					}
				}
			}
		}
	}
	// Edge config for the Productpage service.
	// These configs are REQUIRED for your service to be accessible
	// outside your cluster/mesh.
	edge: {
		edge_name: "edge"
		routes: "/": {
			//prefix_rewrite: "/productpage/"
			upstreams:
				(name): {
					gsl.#MTLSUpstream
					namespace: "bookinfo"
				}
		}
	}
}

exports: "productpage": Productpage
