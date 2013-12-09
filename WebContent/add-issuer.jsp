<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page isThreadSafe="false" %>
<%@ page import="CreditCardProcessor.*"
		 import="java.text.ParseException" 
%>

<%
	String errorMessage = "";
	boolean success = true;
	if("POST".equals(request.getMethod())) {
		
		String issuerName = request.getParameter("name");
		String iin = request.getParameter("iin");
		String strLength = request.getParameter("length");
		boolean enableExpiry = (request.getParameter("expiry") == null ? false : true);
		boolean luhnValidation = (request.getParameter("luhn") == null ? false : true);
		
		if ((issuerName == null) || (iin == null) || (strLength == null)) {
			errorMessage += "<li>Error validating input.  Please try again.</li>";
		} else {
			// add issuer to database
			int PANLength = Integer.parseInt(strLength);
			PaymentGateway gateway = null;
			
			try {		
				//check to see that the IIN doesn't already exist
				gateway = new PaymentGateway("/tmp/paymentproxy.unread.db");
				CardIssuer issuer = gateway.findIssuer(iin);
				if(issuer == null) {
					// issuer not in the database: Add them.
					gateway.addCardIssuer(issuerName, PANLength, iin, luhnValidation, enableExpiry);
					success = true;
				} else {
					errorMessage += "<li>A card issuer with the same IIN already exists: " + issuer.name + "</li>";
				}
				
				// close this shit
				if (gateway != null) 
					gateway.close();
		
			} catch (PaymentGatewayException e) {
				errorMessage += "<li>Error with database access: "+ e.getMessage() + "</li>";
			}
			
		}
		
	}

%>

<!DOCTYPE html>
<html>
<head>


<!-- CDN WITCHERY -->
<link rel="stylesheet" href="http://yui.yahooapis.com/pure/0.3.0/pure-min.css">
<!-- CDN WITCHERY -->

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Register Card</title>
<style>
    #ccn {
      width: 0px;
      height: 0px;
      border: none;
      background: transparent;
      float:right;
      margin-right: 135px;
    }
    #message {
      color: green;
      visibility: hidden;
      margin-bottom: 20px;
    }
    #amount {
    	width: 45%;
     	height: 35px;
     	margin-right: 5%;
     	text-align: right;
    }
    #swipe-button {
    	width: 50%
    }
    .center {
    	text-align: center;
    }
    .headroom {
    	margin-top: 50px;
    }
    #name {
    	margin-bottom: 20px;
    }
     .error {
  		background: #ffe7e7;
  		color: #670000;
  		padding: 15px;
  		margin-bottom: 10px;
  		-moz-border-radius: 5px;
		border-radius: 5px;	
    }
    
    .success {
  		background: #daf7de;
  		color: #0f4416;
  		text-align: center;
  		padding: 5px;
  		inner-padding: 5px;
  		margin-bottom: 10px;
  		-moz-border-radius: 5px;
		border-radius: 5px;	
    }
    
</style>
</head>
<body>

<div class="pure-g-r headroom">
	<div class="pure-u-1-3"></div> <!-- SPACERS -->
	<div class="pure-u-1-3">
		
		<!--  THE ERROR RIBBON -->
		<div class="pure-g-r">
			<% if(!errorMessage.isEmpty()) { %>
				<div class="pure-u-1 error">
					<p><strong>An error occurred while processing the request:</strong></p>
					<ul> 
						<%= errorMessage %>
					</ul>
				</div>
			<% } %>
			<% if (success) { %>
				<div class="pure-u-1 success">
					<p>The card issuer was successfully added to the database.</p>
				</div>
			<% } %>
		</div>
		
		<div class="pure-g-r">
		    <form class="pure-form" method="post">
		    <fieldset>
		    <legend class="center pure-u-1">Add Card Issuer</legend>
			 
			 <div class="pure-g-r">
			 	<div class="pure-u-3-8">
			 		<input class="pure-u-7-8" type="text" id="name" name="name" placeholder="Issuer Name" required autofocus>
			 	</div>
			 	<div class="pure-u-1-8">
			 		<input class="pure-u-1" type="text" id="iin" name="iin" placeholder="IIN" required>
			 	</div>
			 	<div class="pure-u-1-8"></div> <!--  spacer  -->
			    <div class="pure-u-3-8" style="margin-top: 5px;">
					<label><input type="checkbox" name="expiry" value="true"> Enforce Expiration Date</label>
				</div>
			 </div>
			 
			 <div class="pure-g">   
			 	<label class="pure-u-3-8" for="length">Account Number Length</label>
			    <input class="pure-u-1-8" type="text" id="length" name="length" placeholder="16" value="16" maxlength="2" required>
			    <div class="pure-u-1-8"></div>
			    <div class="pure-u-3-8" style="margin-top: 5px;">
					<label><input type="checkbox" name="luhn" value="true"> Luhn Validation</label>
				</div>
			</div>
		    
		    <br>
			<input type="submit" class="pure-u-1 pure-button pure-button-primary" value="Register Card Issuer"> 
			
			</fieldset>
		    </form>
		</div>
	</div>
    <div class="pure-u-1-3"></div> <!-- SPACERS -->
</div>

</body>
</html>