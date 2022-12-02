package v1

import (
	"list"
	"strings"
	envoy_tcp_proxy "envoyproxy.io/extensions/filters/network/tcp_proxy/v3"
)

#SpireCommon: {
	#context: {
		#GlobalContext
		service_name: string
	}
	#subjects: [...string]

	secret: {
		ecdh_curves: *["X25519:P-256:P-521:P-384"] | [...string]
		secret_validation_name: *"spiffe://\(#context.spire.trust_domain)" | _
		// // self 
		secret_name: *"spiffe://\(#context.spire.trust_domain)/\(#context.mesh.operator_namespace).\(#context.mesh.name).\(#context.service_name)" | _
		// other 
		subject_names: *[ for s in #subjects {"spiffe://\(#context.spire.trust_domain)/\(#context.mesh.operator_namespace).\(#context.mesh.name).\(s)"}] | _
		set_current_client_cert_details: URI: *true | _
		forward_client_cert_details: *"APPEND_FORWARD" | _
	}
}

#SpireListener: {
	#SpireCommon
	force_https: true
	...
}

#SpireUpstream: {
	#SpireCommon
	require_tls: true
	...
}

#TLSUpstream: {
	require_tls: true
	ssl_config:  #UpstreamSSLConfig & {
		protocols:      *["TLS_AUTO"] | _
		cert_key_pairs: *[
				{
				certificate_path: *"/etc/proxy/tls/sidecar/server.crt" | _
				key_path:         *"/etc/proxy/tls/sidecar/server.key" | _
			},
		] | _
	}
	...
}

#MTLSUpstream: {
	#TLSUpstream
	ssl_config: trust_file: *"/etc/proxy/tls/sidecar/ca.crt" | _
	...
}

#TLSListener: {
	force_https: true
	ssl_config:  #ListenerSSLConfig & {
		protocols:      *["TLS_AUTO"] | _
		// NOTE(alec): this is supposed to be optional but the disjunction 
		// in the health option breaks if we don't provide a value here.
		trust_file: "" 
		cert_key_pairs: *[
				{
				certificate_path: *"/etc/proxy/tls/sidecar/server.crt" | _
				key_path:         *"/etc/proxy/tls/sidecar/server.key" | _
			},
		] | _
	}
	...
}

#MTLSListener: {
	#TLSListener
	ssl_config: {
		trust_file:           *"/etc/proxy/tls/sidecar/ca.crt" | _
		require_client_certs: *true | _
	}
	...
}

#ShadowTraffic: {
	behavior: "shadow"
	weight:   int
}

#SplitTraffic: {
	behavior: "split"
	weight:   int
}

#TCPListener: self = {
	#ListenerSchema

	_#filterOrder: {
		// Authentication always comes first so we can 
		// block/deny/allow as necessary.
		"ext_authz": *1 | int

		// Rate limiting also receives a high priority
		// since it can prevent DOS attacks.
		"rate_limit": *2 | int

		"metrics": *3 | int

		// TCP proxy and protocol filters should 
		// always be last as they signal the proxy 
		// what kind of connection its handling.
		"tcp_proxy": *10 | int

		// The greymatter proxy requires redis to be 
		// last in the network filter chain.
		"redis_proxy": *11 | int
	}

	tcp_options: envoy_tcp_proxy.#TcpProxy & {
		cluster:     *upstream.name | _
		stat_prefix: *upstream.name | _
	}
	metrics_options: #TCPMetricsFilter.#options

	filter_order?: [...string]
	filters: [...]
	_defaultfilters: [...]
	_allfilters: filters + _defaultfilters + [{tcp_proxy: tcp_options}]
	_unique: {
		for filter in _allfilters for name, v in filter {
			"\(name)": v
		}
	}
	network_filters: #TCPFilters & {
		for name, v in _unique {
			"\(_#lookupFilters[name])": v
		}

	}
	active_network_filters: [ for f in (list.Sort(
		[ for name, v in _unique {name}],
		{x: string, y: string, less: (*_#filterOrder[x] | 5) < (*_#filterOrder[y] | 5)},
		) | *filter_order) {strings.Replace("\(_#lookupFilters[f])", "_", ".", 1)}]

	upstream: #UpstreamSchema
	routes: {
		{"/": {
			upstreams: {"\(self.upstream.name)": self.upstream}
		}} & #Routes
	}
	protocol: "tcp"
}

#HTTPListener: {
	#ListenerSchema
	_#filterOrder: {
		"fault_injection":  *1 | int
		"inheaders":        *1 | int
		"impersonation":    *1 | int
		"oidc_validate":    *1 | int
		"oidc_authn":       *1 | int
		"ensure_variables": *1 | int
		"jwt_authn":        *1 | int

		// the greymatter audits pipeline needs info populated by auth
		"audit": *2 | int

		// authz requests should be logged by audits
		"external_authz": *3 | int
		"rbac":           *3 | int

		// Metrics must be last except for extreme and specific cases
		"metrics": *10 | int
	}

	metrics_options?: #MetricsFilter.#options
	audit_options?:   #AuditFilter.#options

	filters: [...]
	_defaultfilters: [...]
	_allfilters: filters + _defaultfilters
	filter_order?: [...string]

	_unique: {for filter in _allfilters for name, v in filter {(name): v}}
	http_filters: #HTTPFilters & {
		for name, v in _unique {
			"\(_#lookupFilters[name])": v
		}

	}
	active_http_filters: [ for f in (list.Sort(
		[ for name, v in _unique {name}],
		{x: string, y: string, less: (*_#filterOrder[x] | 5) < (*_#filterOrder[y] | 5)},
		) | *filter_order) {strings.Replace("\(_#lookupFilters[f])", "_", ".", 1)}]

	protocol: "http_auto"
	routes:   #Routes
}
