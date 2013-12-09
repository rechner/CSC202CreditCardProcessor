<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page isThreadSafe="false" %>
<%@ page 
	import="CreditCardProcessor.*" 
	import="java.util.Locale"
	import="java.text.ParseException"
	import="com.almworks.sqlite4java.*"
	import="java.io.File"
%>

<% 
	session.setAttribute("virtualTerminal", true);
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
			
			PaymentGateway gateway = null;
			try {		
				PaymentCard paymentCard = new PaymentCard(ccn);
				
				gateway = new PaymentGateway("/tmp/paymentproxy.unread.db");
				CardIssuer issuer = gateway.findIssuer(paymentCard.iin);
				if(issuer == null) {
					// issuer not in the database
					errorMessage += "<li>Card issuer not the database.</li>";
				}
				else {
					CardHolder cardHolder = gateway.getCardHolder(issuer, paymentCard.primaryAccountNumber);
					if(cardHolder == null) {
						// cardholder not in database
						errorMessage += "<li>Cardholder not in database</li>";
					}
					else {
						// insufficent funds... duh
						if(cardHolder.balance < toCharge) {
							errorMessage += "<li>Insufficient funds.</li>";
						}
						//set session variables
						//TODO: MERCHANT IS HARDCODED
						request.getSession().setAttribute("cardHolder", cardHolder);
						request.getSession().setAttribute("merchant", "NOVA Cafe");
						request.getSession().setAttribute("toCharge", toCharge);
						// redirect that shit!
						response.sendRedirect("confirmation.jsp");
					}
				}
			} catch (CardReadException e) {
				//e.printStackRape();
				errorMessage += "<li>Could not read the card.  Swipe again.</li>";
			} catch (PaymentGatewayException e) {
				errorMessage += "<li>Could not access database: "+ e.getMessage() + "</li>";
			} finally { 
				// close this shit
				if (gateway != null) 
					gateway.close();
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
    .error {
  		background: #ffe7e7;
  		color: #670000;
  		padding: 15px;
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
        <li class="pure-menu-selected"><a href="#">Virtual Terminal</a></li>
        <li><a href="add-issuer.jsp">Add Card Issuer</a></li>
        <li><a href="register.jsp">Add Cardholder</a></li>
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
				<p><strong>An error occurred while processing the request:</strong></p>
				<ul> 
					<%=errorMessage%>
				</ul>
			</div>
		<% } %>
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
			<input class="pure-u-1" type="text" id="ccn" name="ccn" onblur="hidemessage();" autocomplete="off"
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
        	console.log(ccn.value);
            e.target.setCustomValidity("Please press the button above and slide a card to continue.");
        }
    };
    ccn.oninput = function(e) {
        e.target.setCustomValidity("");
    };
    
    amnt = document.getElementById("amount");
    amnt.oninvalid = function(e) {
        e.target.setCustomValidity("");
        if (!e.target.validity.valid) {
        	console.log(amnt.value);
            e.target.setCustomValidity("Please enter a cost to be charged.");
        }
    };
    amnt.oninput = function(e) {
        e.target.setCustomValidity("");
    };

    
});
</script>
</html>