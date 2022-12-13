// Edge configuration for enterprise mesh-segmentation. This is a dedicated
// edge proxy that provides north/south network traffic to services in this
// repository in the mesh. This edge would be separate from the default
// greymatter edge that is deployed via enterprise-level configuration in
// the gitops-core git repository.
package bookinfo

import (
	gsl "greymatter.io/gsl/v1"

	"bookinfo.module/greymatter:globals"
)

Edge: gsl.#Service & {
	// A context provides global information from globals.cue
	// to your service definitions.
	context: Edge.#NewContext & globals

	// name must follow the pattern namespace/name
	name:              "edge"
	display_name:      "Bookinfo Edge"
	version:           "v1.8.1"
	description:       "Edge ingress for bookinfo"
	api_endpoint:      "N/A"
	api_spec_endpoint: "N/A"
	business_impact:   "high"
	owner:             "Bookinfo"
	capability:        ""
	health_options: {
		tls: gsl.#MTLSUpstream
	}
	ingress: {
		// Edge -> HTTP ingress to your container
		(name): {
			gsl.#HTTPListener
			gsl.#TLSListener
			port: 10809


			routes: "/": upstreams: (name): {
				namespace: context.globals.namespace
			}
		}
	}
}

exports: "edge-bookinfo": Edge
