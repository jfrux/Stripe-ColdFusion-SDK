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
  * @displayname Base Stripe CFC
  * @hint A library to help aid in building stripe integrated ColdFusion applications.
  * 
  */
component accessors="true" extends="stripeBase" {
	/**
     * @description Stripe Secret ApiKey
	 * @hint
	 */
	property String apiKey;
	 
	variables.VERSION = "1";
	variables.apiEndPoint = "https://api.stripe.com/";
	variables.apiBaseUrl = variables.apiEndPoint & "v1";
	
	/*
	 * @description Stripe constructor
	 * @hint Requires an ApiKey
	 */
	public Any function init(required String apiKey) {
		if (!isPersistentDataEnabled()) {
			throw(message="Persistent scope is not available (by default session scope, so you must enable session management for this app)", type="UnvailablePersistentScope");
		}
		super.init(arguments.apiKey);
		setApiKey(arguments.apiKey);
		return this;
	}
}