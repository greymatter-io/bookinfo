// Copyright 2022, greymatter.io Inc., All rights reserved.  
package http

#OauthConfig: {
	provider?:        string
	client_id?:       string
	client_secret?:   string
	server_name?:     string
	server_insecure?: bool
	session_secret?:  string
	domain?:          string
}

#OauthRouteConfig: {
	domain?: string
}
