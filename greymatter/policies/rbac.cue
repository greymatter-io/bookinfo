package policies

#RBAC: {
	#DenyAll: {
		rules: {
			action: "DENY"
			policies: {
				all: {
					permissions: [
						{
							any: true
						},
					]
					principals: [
						{
							any: true
						},
					]
				}
			}
		}
	}
}
