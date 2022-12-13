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
	api_endpoint:      "http://\(context.globals.edge_host)/"
	api_spec_endpoint: "http://\(context.globals.edge_host)/"
	business_impact:   "medium"
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
									port: 9090
								},
							]
						}
					}
				}
			}
		}
	}
	
	// The app needs to know where to find it's dependencies
	// in the mesh. We create egress routes from the apps sidecar
	// below so it can easily reach by requesting to localhost:9080.
	egress: {
		"egress-to-services": {
			gsl.#HTTPListener
			port: context.globals.custom.default_egress
			routes: {
				"/details/": {
					prefix_rewrite: "/details/"
					upstreams: {
						"details": {
							namespace: "bookinfo"
						}
					}
				}
				"/ratings/": {
					prefix_rewrite: "/ratings/"
					upstreams: {
						"ratings": {
							namespace: "bookinfo"
						}
					}
				}

				// We split traffic to v2/v3 to mimic what a canary 
				// deployment might look like. We can slowly rollout new
				// versions of services to test quality of service 
				// for users. Default behavior is to "split" but it 
				// can me used to shadow as well.
				"/reviews/": {
					prefix_rewrite: "/reviews/"
					upstreams: {
						"reviews-v2": {
							namespace: "bookinfo"
							traffic_options: {
								weight: 50
							}
						}
						"reviews-v3": {
							namespace: "bookinfo"
							traffic_options: {
								weight: 50
							}
						}
					}
				}
			}
		}
	}

	// Deploy productpage to the root of the application edge node.
	// This is to serve the web app first above all other services.
	edge: {
		edge_name: "edge"
		routes: {
			"/": {
				upstreams: {
					(name): {
						namespace: context.globals.namespace
					}
				}
			}
		}
	}
}

exports: "productpage": Productpage
