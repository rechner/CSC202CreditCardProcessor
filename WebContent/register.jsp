<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page isThreadSafe="false" %>
<%@ page import="CreditCardProcessor.*"
		 import="java.text.ParseException" 
		 import="java.net.URLEncoder"
%>

<%
	String errorMessage = "";
	boolean success = false;
	
	if("POST".equals(request.getMethod())) {
		
		String rawCardData = request.getParameter("ccn");
		String initialBalance = request.getParameter("amount");
		String cardholderName = request.getParameter("name");
		
		if ((rawCardData == null) || (initialBalance == null) || (cardholderName == null)) {
			errorMessage += "<li>Error validating input.  Please try again.</li>";
		} else {
			// add card to database:
			
			double funds = 0;
			//parse amount input:
			try {
				funds = PaymentCard.stringToDouble(initialBalance);
			} catch (ParseException e) {
				errorMessage += "<li>Unable to parse the amount specified.</li>";
			}
				
			PaymentGateway gateway = null;
			try {		
				PaymentCard paymentCard = new PaymentCard(rawCardData);
				
				gateway = new PaymentGateway("/tmp/paymentproxy.unread.db");
				CardIssuer issuer = gateway.findIssuer(paymentCard.iin);
				if(issuer == null) {
					// issuer not in the database
					errorMessage += "<li>The card issuer for the swiped card was"
						+ " not found in the database.  Click <a href=\"add-issuer.jsp\">here</a> to add one.</li>";
				}
				else {
					CardHolder cardHolder = gateway.getCardHolder(issuer, paymentCard.primaryAccountNumber);
					if(cardHolder == null) {
						// cardholder not found in database, so we'll add a new cardholder account:
						gateway.addCardholder(issuer.name, paymentCard.primaryAccountNumber, cardholderName, funds);
						success = true;
					}
					else {
						errorMessage += "<li>A card issuer with the same primary account number already exists. "+
						"click <a href=\"check-balance.jsp?ccn="+ 
						URLEncoder.encode(rawCardData, "UTF-8") +"\">here</a> to check account balence.</li>";
					}
				}
				
			// close this shit
			if (gateway != null) 
				gateway.close();
			
			} catch (CardReadException e) {
				//e.printStackRape();
				errorMessage += "<li>Could not read the card.  Swipe again.</li>";
			} catch (PaymentGatewayException e) {
				errorMessage += "<li>Could not access database: "+ e.getMessage() + "</li>";
			} finally { 
				
			}
			
		}
		
	}

%>

<!DOCTYPE html>
<html>
<head>


<!-- CDN WITCHERY -->
<link rel="stylesheet" href="http://yui.yahooapis.com/pure/0.3.0/pure-min.css">
<script src="http://codeorigin.jquery.com/jquery-2.0.3.min.js"></script>
<script src="autoNumeric.js"></script>
<!-- CDN WITCHERY -->

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Register Card</title>
<script>
    function setfocus() {
    	document.getElementById("ccn").value = "";
        document.getElementById("ccn").focus();
        document.getElementById("message").style.visibility = 'visible';
    }
    
    function hidemessage() {
        document.getElementById("message").style.visibility = 'hidden';
    }

</script>
<style>
    #ccn {
      position: absolute;
      left: -1000px;
      width: 2px;
      height: 25px;
      border: none;
      background: transparent;
      float:right;
      margin-right: 135px;
    }
    #message {
      margin-top: 20px;
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
    .primary-nav {
	    max-width: 820px;
	    margin: 0 auto;
	    margin-top: 10px;
	}
    
</style>
</head>
<body>

<div class="pure-menu pure-menu-open pure-menu-horizontal primary-nav">
    <ul>
        <li><a href="virtualterminal.jsp">Virtual Terminal</a></li>
        <li><a href="add-issuer.jsp">Add Card Issuer</a></li>
        <li class="pure-menu-selected"><a href="register.jsp">Add Cardholder</a></li>
        <li><a href="deposit.jsp">Deposit</a></li>
        <li><a href="check-balance.jsp">Balance Inquiry</a></li>
    </ul>
</div>

<div class="pure-g-r headroom">
	<div class="pure-u-1-3"></div> <!-- SPACERS -->
	<div class="pure-u-1-3">
		
		<!--  THE ERROR RIBBON -->
		<div class="pure-g-r">
			<% if(!errorMessage.isEmpty()) { %>
				<div class="pure-u-1 error">
					<p><strong>An error occured while processing the request:</strong></p>
					<ul> 
						<%= errorMessage %>
					</ul>
				</div>
			<% } %>
			<% if (success) { %>
				<div class="pure-u-1 success">
					<p>The card holder was successfully added to the database.</p>
				</div>
			<% } %>
		</div>
		
		<div class="pure-g-r">
		    <form class="pure-form" method="post">
		    <fieldset>
		    <legend class="center pure-u-1">Register Cardholder</legend>
			 
			 <div class="pure-g-r">
			 	<input class="pure-u-1" type="text" id="name" name="name" placeholder="Cardholder Name" required autofocus>
			 </div>
			 
			 <div class="pure-g-r">   
			    <input class="pure-u-1-2" type="text" id="amount" name="amount" required placeholder="Initial Balance">
			    
			    <button class="pure-u-1-2 pure-button" id="swipe-button" type="button" onclick="setfocus();">
			    	Click to Swipe Card
			    </button>
			</div>
			<input class="pure-u-1" type="text" id="ccn" name="ccn" onblur="hidemessage();" autocomplete="off" 
			 required title="Please press the button above and slide a card to continue.">
			
			<div class="pure-u-1 center" id="message" >Ready to Swipe</div>
		    
			<input type="submit" class="pure-u-1 pure-button pure-button-primary" value="Register Card"> 
			
			</fieldset>
		    </form>
		</div>
	</div>
    <div class="pure-u-1-3"></div> <!-- SPACERS -->
</div>

</body>

<!-- amount input mask  -->
<script type="text/javascript">
$(document).ready(function(){
    $("#amount").autoNumeric('init');
    
    ccn = document.getElementById("ccn");
    ccn.oninvalid = function(e) {
        e.target.setCustomValidity("");
        if (!e.target.validity.valid) {
            e.target.setCustomValidity("Please press the button above and slide a card to continue.");
        }
    };
    ccn.oninput = function(e) {
        e.target.setCustomValidity("");
    };
    
    ccn = document.getElementById("amount");
    ccn.oninvalid = function(e) {
        e.target.setCustomValidity("");
        if (!e.target.validity.valid) {
            e.target.setCustomValidity("Please enter a cost to be charged.");
        }
    };
    ccn.oninput = function(e) {
        e.target.setCustomValidity("");
    };

    
});

// was supposed to be for 
// #amount's input sanitation 
// onsubmit="checkInput()"
/* function checkInput() {
	alert(document.getElementById("amount").innerText);
} */

</script>
</html>