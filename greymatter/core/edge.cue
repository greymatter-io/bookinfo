// Edge configuration for enterprise mesh-segmentation. This is a dedicated
// edge proxy that provides north/south network traffic to services in this
// repository in the mesh. This edge would be separate from the default
// greymatter edge that is deployed via enterprise-level configuration in
// the gitops-core git repository.
package bookinfo

import (
	gsl "greymatter.io/gsl/v1"

	"bookinfo.module/greymatter:globals"
	//policies "bookinfo.module/greymatter/policies"
)

Edge: gsl.#Service & {
	context: Edge.#NewContext & globals

	name:              "edge"
	display_name:      "Bookinfo Edge"
	version:           "v1.8.1"
	description:       "Edge ingress for bookinfo"
	api_endpoint:      "N/A"
	api_spec_endpoint: "N/A"
	business_impact:   "high"
	owner:             "Library"
	capability:        "Ingress"

	ingress: {
		(name): {
			gsl.#HTTPListener
			port: 10809
			filters: [

				// gsl.#OPAFilter & {
				//  #options: {
				//   with_request_body: {
				//    max_request_bytes:     1024
				//    allow_partial_message: true
				//    pack_as_bytes:         true
				//   }
				//   static_host: {
				//    target_uri:  "localhost:9191"
				//    stat_prefix: "opa"
				//   }
				//   failure_mode_allow: false
				//   status_on_error: code: "ServiceUnavailable"
				//  }
				// },

				// Make sure to uncomment the policies import statement
				// gsl.#RBACFilter & {
				//  #option: {
				//   policies.#RBAC.#DenyAll
				//  }
				// },
			]

			// Default cluster pointing to itself
			routes: "/": upstreams: (name): namespace: context.globals.namespace
		}
	}
}

exports: "edge-bookinfo": Edge
