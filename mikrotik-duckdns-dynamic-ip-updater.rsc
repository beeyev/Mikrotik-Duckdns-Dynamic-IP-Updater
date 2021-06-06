#----------SCRIPT INFORMATION---------------------------------------------------
#
# Script:  Beeyev DuckDNS.org Dynamic DNS Update Script
# Version: 1.2
# Created: 29/07/2019
# Updated: 06/06/2021
# Author:  Alexander Tebiev
# Website: https://github.com/beeyev
#
#----------MODIFY THIS SECTION AS NEEDED----------------------------------------


# DuckDNS Sub Domain
:local duckdnsSubDomain "PUT-SUBDOMAIN-HERE"

# DuckDNS Token
:local duckdnsToken "PUT-TOKEN-HERE"

# Set true if you want to use IPv6
:local ipv6mode false;

# Online services which respond with your IPv4, two for redundancy
:local ipDetectService1 "https://api.ipify.org/"
:local ipDetectService2 "https://api4.my-ip.io/ip.txt"

# Online services which respond with your IPv6, two for redundancy
:local ipv6DetectService1 "https://api64.ipify.org"
:local ipv6DetectService2 "https://api6.my-ip.io/ip.txt"


#-------------------------------------------------------------------------------

:local previousIP; :local currentIP
# DuckDNS Full Domain (FQDN)
:local duckdnsFullDomain "$duckdnsSubDomain.duckdns.org"

:log warning message="START: DuckDNS.org DDNS Update"

if ($ipv6mode = true) do={
	:set ipDetectService1 $ipv6DetectService1;
	:set ipDetectService2 $ipv6DetectService2;
	:log error "DuckDNS: ipv6 mode enabled"
}

# Resolve current DuckDNS subdomain ip address
:do {:set previousIP [:resolve $duckdnsFullDomain]} on-error={ :log warning "DuckDNS: Could not resolve dns name $duckdnsFullDomain" };

# Detect our public IP adress useing special services
:do {:set currentIP ([/tool fetch url=$ipDetectService1 output=user as-value]->"data")} on-error={
		:log error "DuckDNS: Service does not work: $ipDetectService1"
		#Second try in case the first one is failed
		:do {:set currentIP ([/tool fetch url=$ipDetectService2 output=user as-value]->"data")} on-error={
			:log error "DuckDNS: Service does not work: $ipDetectService2"
		};
	};
	

:log info "DuckDNS: DNS IP ($previousIP), current internet IP ($currentIP)"

:if ($currentIP != $previousIP) do={
	:log info "DuckDNS: Current IP $currentIP is not equal to previous IP, update needed"
	:log info "DuckDNS: Sending update for $duckdnsFullDomain"
	:local duckRequestUrl "https://www.duckdns.org/update\?domains=$duckdnsSubDomain&token=$duckdnsToken&ip=$currentIP&verbose=true"
	:log info "DuckDNS: using GET request: $duckRequestUrl"

	:local duckResponse
	:do {:set duckResponse ([/tool fetch url=$duckRequestUrl output=user as-value]->"data")} on-error={
		:log error "DuckDNS: could not send GET request to the DuckDNS server. Going to try again in a while."
		:delay 5m;
			:do {:set duckResponse ([/tool fetch url=$duckRequestUrl output=user as-value]->"data")} on-error={
				:log error "DuckDNS: could not send GET request to the DuckDNS server for the second time."
				:error "DuckDNS: bye!"
			}
	}

	# Checking server's answer
	:if ([:pick $duckResponse 0 2] = "OK") do={
		:log info "DuckDNS: New IP address ($currentIP) for domain $duckdnsFullDomain has been successfully set!"
	} else={ 
		:log warning "DuckDNS: There is an error occurred during IP address update, server did not answer with \"OK\" response!"
	}

	:log info "DuckDNS: server answer is: $duckResponse"
} else={
	:log info "DuckDNS: Previous IP ($previousIP) is equal to current IP ($currentIP), no need to update"
}

:log warning message="END: DuckDNS.org DDNS Update finished"
