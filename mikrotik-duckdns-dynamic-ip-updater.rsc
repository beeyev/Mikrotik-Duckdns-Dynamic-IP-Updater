#----------SCRIPT INFORMATION---------------------------------------------------
#
# Script:  Beeyev DuckDNS.org Dynamic DNS Update Script
# Version: 1.1
# Created: 29/07/2019
# Updated: 03/08/2019
# Author:  Alexander Tebiev
# Website: https://github.com/beeyev
#
#----------MODIFY THIS SECTION AS NEEDED----------------------------------------


# DuckDNS Sub Domain
:local duckdnsSubDomain "PUT-SUBDOMAIN-HERE"

# DuckDNS Token
:local duckdnsToken "PUT-TOKEN-HERE"

# Online services which respond with your IP
:local ipDetectService1 "https://api.ipify.org/"
:local ipDetectService2 "https://v4.ident.me/"


#-------------------------------------------------------------------------------

:local previousIP; :local currentIP
# DuckDNS Full Domain (FQDN)
:local duckdnsFullDomain "$duckdnsSubDomain.duckdns.org"

:log warning message="START: DuckDNS.org DDNS Update"

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
	
	
# Very simple checks that provided IP is correct
:local dotPos0 0; :local dotPos1 0; :local dotCount 0
:for i from=1 to=3 step=1 do={
	:set dotPos1 [:find $currentIP "." $dotPos0];
	:if ($dotPos1 > $dotPos0) do={ :set dotPos0 $dotPos1; :set dotCount ($dotCount+1)}
}
# Yes we just counted dots in IP address, at least it's better than nothing.
:if ($dotCount < 3 or [:len $currentIP] < 7 or [:len $currentIP] > 15) do={
	:log error "DuckDNS: provided public IP was not correct! Provided ip: $currentIP"
	:error "DuckDNS: bye!"
}


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
