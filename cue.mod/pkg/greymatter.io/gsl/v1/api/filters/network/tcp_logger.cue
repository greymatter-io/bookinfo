// Copyright 2022, greymatter.io Inc., All rights reserved.  
package network

#TcpLoggerConfig: {
	warnWindow?:        string
	logConnect?:        bool
	omitSSLFailure?:    bool
	logRawTcp?:         bool
	failureCheckDelay?: string
}
