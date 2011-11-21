/**
  * Copyright 2011 SwoDev
  * Author: Joshua Rountree (joshua@swodev.com)
  *
  * Licensed under the Apache License, Version 2.0 (the "License"); you may
  * not use this file except in compliance with the License. You may obtain
  * a copy of the License at
  * 
  *  http://www.apache.org/licenses/LICENSE-2.0
  *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
  * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
  * License for the specific language governing permissions and limitations
  * under the License.
  *
  * @displayname Stripe API
  * @hint A client wrapper to call Stripe API
  * 
  */
component accessors="true" {
	
	/**
     * @description Stripe API key
	 * @hint
	 */
	property String apiKey;
	
	variables.VERSION = "1";
	variables.apiEndPoint = "https://api.stripe.com/";
	variables.apiBaseUrl = variables.apiEndPoint & "v1";
	
	variables.PERSISTENT_KEYS = "CUSTOMER,CARD";
	variables.REQUEST_KEYS = "";
	
	/*
	 * @description Base constructor
	 * @hint Requires an API Secret Key
	 */
	public Any function init(String apiKey = 0) {
		setApiKey(arguments.apiKey);
		return this;
	}
	
	// PRIVATE
	private Any function callAPIService(required Http httpService) {
		var response = arguments.httpService.send().getPrefix();
		
		var result = {};
		if (isJSON(response.fileContent)) {
			result = deserializeJSON(response.fileContent);
			if (isStruct(result) && (structKeyExists(result, "error") || structKeyExists(result, "error_code"))) {
				var exception = new StripeAPIException(result);

				throw(errorCode="#exception.getErrorCode()#", message="#exception.getType()# - #exception.getMessage()#", type="#exception.getType()#");
			}
		} else if (isSimpleValue(response.fileContent) && response.statusCode == "200 OK") {
			result = parseQueryString(response.fileContent);
		} else {
			throw(message="#response.statusCode#", type="StripeHTTP");
		}
		return result;
	}
	
	private String function getKeyVariableName(required String key) {
		return "stripe_" & getApiKey() & "_" & arguments.key;
	}
	
	/**
	* Utility functions
	*/
	/**
	* Uses ColdFusion request scope to cache data during the duration of the request.
	*/
	private Boolean function deleteRequestData(required String key) {
		if (!listFindNoCase(variables.REQUEST_KEYS, arguments.key)) {
			throw(errorCode="Invalid key", message="Unsupported key passed to deleteRequestData");
		}
		return structDelete(request, getKeyVariableName(arguments.key), true);
	}
	
	private Any function getRequestData(required String key, any value = "") {
		if (!listFindNoCase(variables.REQUEST_KEYS, arguments.key)) {
			throw(errorCode="Invalid key", message="Unsupported key passed to getRequestData");
		}
		var requestKey = getKeyVariableName(arguments.key);
		if (structKeyExists(request, requestKey)) {
			return request[requestKey];
		} else {
			return arguments.value;
		}
	}

	private Boolean function hasRequestData(required String key) {
		return structKeyExists(request, getKeyVariableName(arguments.key));
	}
		
	private void function setRequestData(required String key, required Any value) {
		if (!listFindNoCase(variables.REQUEST_KEYS, arguments.key)) {
			throw(errorCode="Invalid key", message="Unsupported key passed to setRequestData");
		}
		request[getKeyVariableName(arguments.key)] = arguments.value;
	}
	
	/**
	* Uses ColdFusion sessions to provide a primitive persistent store, but another subclass of StripeApp --one that you implement-- might use a database, memcache, or an in-memory cache.
	*/
	private Boolean function deletePersistentData(required String key) {
		if (!listFindNoCase(variables.PERSISTENT_KEYS, arguments.key)) {
			throw(errorCode="Invalid key", message="Unsupported key passed to deletePersistentData");
		}
		return structDelete(session, getKeyVariableName(arguments.key), true);
	}

	private void function deleteAllPersistentData() {
		for (var key in listToArray(variables.PERSISTENT_KEYS)) {
			deletePersistentData(key);
		}
	}
	
	private Any function getPersistentData(required String key, Any value = "") {
		if (!listFindNoCase(variables.PERSISTENT_KEYS, arguments.key)) {
			throw(errorCode="Invalid key", message="Unsupported key passed to getPersistentData");
		}
		var persistentKey = getKeyVariableName(arguments.key);
		if (structKeyExists(session, persistentKey)) {
			return session[persistentKey];
		} else {
			return arguments.value;
		}
	}
	
	private Boolean function hasSessionData(required String key) {
		return structKeyExists(session, getKeyVariableName(arguments.key));
	}
	
	public Boolean function isPersistentDataEnabled() {
		return application.getApplicationSettings().sessionManagement;
	}
		
	private void function setPersistentData(required String key, required Any value) {
		if (!listFindNoCase(variables.PERSISTENT_KEYS, arguments.key)) {
			throw(errorCode="Invalid key", message="Unsupported key passed to setPersistentData");
		}
		session[getKeyVariableName(arguments.key)] = arguments.value;
	}
}