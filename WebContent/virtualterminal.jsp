<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page isThreadSafe="false" %>
<%@ page 
	import="CreditCardProcessor.*" 
	import="java.util.Locale"
	import="java.text.ParseException"
%>

<% 

	String errorMessage = "";

	if ("POST".equals(request.getMethod())) {
		double toCharge = -1;
		String amount = request.getParameter("amount");
		String ccn = request.getParameter("ccn");
		
		//parse amount input:
		try {
			toCharge = PaymentCard.stringToDouble(amount);
		} catch (ParseException e) {
			errorMessage += "<li>Unable to parse the amount specified.</li>";
		}
		
		// parameter
		if (amount == null || amount.equals("") || ccn == null || ccn.equals("")) {
			errorMessage += "<li>Parameters are empty or null.</li>";
		} else if (toCharge <= 0) {
			errorMessage += "<li>Insufficient amount to be charged: "+toCharge+"</li>";
		} else { 
			
			try {		
				PaymentCard paymentCard = new PaymentCard(ccn);
				PaymentGateway gateway = new PaymentGateway("paymentproxy.unread.db");
				CardIssuer issuer = gateway.findIssuer(paymentCard.iin);
				if(issuer == null) {
					// issuer not in the database
					errorMessage += "<li>Card issuer not the database.</li>";
					throw new PaymentGatewayException(null);
				}
				else {
					CardHolder cardHolder = gateway.getCardHolder(issuer, paymentCard.primaryAccountNumber);
					if(cardHolder == null) {
						// cardholder not in database
						errorMessage += "<li>Cardholder not in database</li>";
						throw new PaymentGatewayException(null);
					}
					else {
						//TODO: CHANGE THE FUCKING ARGS to doTransaction() YOU GIT!
						boolean success = gateway.doTransaction(cardHolder, "NOVA Cafe", toCharge);
						if (!success) {
							errorMessage += "<li>Insufficient funds.</li>";
						}
					}
				}
				// close this shit
				gateway.close();
			} catch(CardReadException e) {
				//e.printStackRape();
				errorMessage += "<li>Could not read the card.  Swipe again.<li>";
			} catch(PaymentGatewayException e) {
				errorMessage += "<li>Could not access database: "+ e.getMessage() + "<li>";
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
<title>Merchant Virtual Terminal</title>
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
    .error {
  		background: #ffe7e7;
  		color: #670000;
  		padding: 15px;
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
		<div class="pure-u-1 error">
			<% if(!errorMessage.isEmpty()) { %>
				<p><strong>An error occured while processing the request:</strong></p>
				<ul> 
					<%=errorMessage%>
				</ul>
			<% } %>
		</div>
	</div>
	
		<div class="pure-g-r">
		    <form class="pure-form" method="post" action="virtualterminal.jsp">
		    <fieldset>
		    <legend class="center pure-u-1">Charge Amount</legend>
			 
			 <div class="pure-g-r">   
			    <input class="pure-u-1-2" type="text" id="amount" name="amount" autofocus required>
			    
			    <button class="pure-u-1-2 pure-button" id="swipe-button" type="button" onclick="setfocus();">
			    	Click to Swipe Card
			    </button>
			</div>
			<input class="pure-u-1" type="text" id="ccn" name="ccn" onblur="hidemessage();" 
			 required title="Please press the button above and slide a card to continue.">
			
			<div class="pure-u-1 center" id="message" >Ready to Swipe</div>
		    
			<input type="submit" class="pure-u-1 pure-button pure-button-primary" value="Charge It!"> 
			
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
</script>
</html>