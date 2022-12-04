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
	description:               "Book info product web app"
	api_endpoint:              "http://\(context.globals.edge_host)/productpage"
	api_spec_endpoint:         "http://\(context.globals.edge_host)/producttester"
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
				"/details/": {

					upstreams: {
						"details": {
							// gsl.#MTLSUpstream
							namespace: "bookinfo"
						}
					}
				}
				"/ratings/": {

					upstreams: {
						"ratings": {
							// gsl.#MTLSUpstream
							namespace: "bookinfo"
						}
					}
				}
				"/reviews/": {
					upstreams: {
						"reviews-v1": {
							// gsl.#MTLSUpstream
							namespace:       "bookinfo"
							traffic_options: gsl.#SplitTraffic & {
								weight: 80
							}
						}
						"reviews-v2": {
							// gsl.#MTLSUpstream
							namespace:       "bookinfo"
							traffic_options: gsl.#SplitTraffic & {
								weight: 20
							}
						}
						// "reviews-v3": {
						//  // gsl.#MTLSUpstream
						//  namespace:       "bookinfo"
						//  traffic_options: gsl.#SplitTraffic & {
						//   weight: 33
						//  }
						// }
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
		routes: {
			"/": {
				prefix_rewrite: "/productpage"
				// redirects: [
				//  {
				//   from:          "^" + "/productpage/" + "$"
				//   to:            "/productpage"
				//   redirect_type: "permanent"
				//  },
				// ]
				upstreams:
					(name): {
						namespace: "bookinfo"
					}
			}
			"/producttester": {
				prefix_rewrite: "/"
				upstreams:
					(name): {
						// gsl.#MTLSUpstream
						namespace: "bookinfo"
					}
			}
		}
	}
}

exports: "productpage": Productpage
