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
  * @displayname StripeAPI CFC
  * @hint Init this per customer or charge.  This contains all available api calls.
  * 
  */
component accessors="true" extends="stripeBase" {
	
	/*
	 * @description Stripe API constructor
	 * @hint Optionally add a customerid or card object for charge / customer calls
	 */
	public Any function init(String customerId = "",Struct card = { 'number':'', 'exp_month':'','exp_year':'','cvc':'','name':'','address_line1':'','address_line2':'','address_zip':'','address_state':'','address_country':'' }, String apiKey = "", Numeric timeout = 10) {
		super.init(apiKey=arguments.apiKey);
		variables.CUSTOMERID = arguments.customerId;
		variables.CARD = arguments.card;
		variables.TIMEOUT = arguments.timeout;
		variables.CUSTOMER = getCustomer(arguments.customerId);
		setPersistentData("CUSTOMER",variables.CUSTOMER);
		return this;
	}
	
	/*
	 * @description create a charge
	 * @hint 
	 */
	public Boolean function createCharge(amount,description) {
		var httpService = new Http(username=getAPIKey(),password="",url="#variables.apiBaseUrl#/charges", method="POST", timeout=variables.TIMEOUT);
		var result = {};
		httpService.addParam(type="formField", name="amount", value=arguments.amount);
		httpService.addParam(type="formField", name="currency", value="usd");
		
		if(len(trim(variables.CUSTOMERID)) GT 0) {
			httpService.addParam(type="formField", name="customer", value=variables.CUSTOMERID);
		} else {
			httpService.addParam(type="formField", name="card", value=variables.CARD);
		}
		
		httpService.addParam(type="formField", name="description", value=arguments.description);
		
		result = callAPIService(httpService);
		return result;
	}
	
	/*********************************
	**********************************
	* CUSTOMERS
	**********************************
	*/
	
	/*
	 * @description create a customer
	 * @hint 
	 */
	public Struct function createCustomer(
			String coupon = "",
			String email = "",
			String description = "",
			String plan = "",
			String trial_end = "") {
					
		var httpService = new Http(
								username=getAPIKey(),
								password="",
								url="#variables.apiBaseUrl#/customers",
								method="POST",
								timeout=variables.TIMEOUT);
		var result = {};
		
		
		if(len(trim(arguments.coupon))) {
			httpService.addParam(type="formField", name="coupon", value=arguments.coupon);
		}
		
		if(len(trim(arguments.email))) {
			httpService.addParam(type="formField", name="email", value=arguments.email);
		}
		
		if(len(trim(arguments.plan))) {
			httpService.addParam(type="formField", name="plan", value=arguments.plan);
		}
		
		if(len(trim(arguments.trial_end))) {
			httpService.addParam(type="formField", name="trial_end", value=arguments.trial_end);
		}
		
		if(listLen(structKeyList(variables.CARD,","),",") GT 0) {
			for (key in variables.CARD) {
				httpService.addParam(type="formField", name="card[#key#]", value=variables.CARD[key]);
			}
		}
		
		if(len(trim(arguments.description))) {
			httpService.addParam(type="formField", name="description", value=arguments.description);
		}
		
		result = callAPIService(httpService);
		return result;
	}
	
	/*
	 * @description gets a customer from API if customerid is different than already provided.
	 * @hint 
	 */
	public Struct function getCustomer(String customerid = "") {
		var customer = {};
		var custId = '';
		var persistedCustomer = getPersistentData("CUSTOMER",{id:0});
		var httpService = new Http(
								username=getAPIKey(),
								password="",
								url="#variables.apiBaseUrl#/customers",
								method="GET",
								timeout="#variables.TIMEOUT#");
		var result = {};
		
		
		if(len(trim(arguments.customerid))) {
			custId = arguments.customerid;
			if(persistedCustomer.id NEQ custId) {
				httpService.setUrl(httpService.getUrl() & "/" & arguments.customerid);
				result = callAPIService(httpService);
			} else {
				result = persistedCustomer;
			}
		}
		
		WriteDump(var=result,abort=true);
		
		return result;
	}
}