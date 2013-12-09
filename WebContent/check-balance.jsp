<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page isThreadSafe="false" %>
<%@ page 
	import="CreditCardProcessor.*" 
	import="java.util.Locale"
	import="java.text.NumberFormat"
	import="java.text.ParseException"
	import="com.almworks.sqlite4java.*"
	import="java.io.File" %>
<% 

	String errorMessage = "";
	boolean success = false;
	CardHolder cardHolder = new CardHolder();
	String ccn = request.getParameter("ccn");

	if ("POST".equals(request.getMethod()) || (("GET".equals(request.getMethod())) && (ccn != null))) {
		
		//validate
		if (ccn == null || ccn.equals("")) {
			errorMessage += "<li>No card swiped.</li>";
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
					cardHolder = gateway.getCardHolder(issuer, paymentCard.primaryAccountNumber);
					if(cardHolder == null) {
						// cardholder not in database
						errorMessage += "<li>Cardholder not in database</li>";
					}
					else {
						// we'll check for success and print balance in the form
						success = true;
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
<title>Balance Inquiry</title>
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
    input[type="submit"] {
    	position: absolute;
    	top: -100px
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
        <li><a href="register.jsp">Add Cardholder</a></li>
        <li><a href="deposit.jsp">Deposit</a></li>
        <li class="pure-menu-selected"><a href="check-balance.jsp">Balance Inquiry</a></li>
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
					<%=errorMessage%>
				</ul>
			</div>
		<% } %>
	</div>
	
	<div style="text-align: center">
		<% 
			if(success) {
				// create a money formatter	
				NumberFormat formatter = NumberFormat.getCurrencyInstance(Locale.US);
			%>
			
					<p>Remaining balance for <%= cardHolder.name %>: <strong><%= formatter.format(cardHolder.balance)  %></strong><br>
					(Account number: ****<%= cardHolder.primaryAccountNumber.substring(cardHolder.primaryAccountNumber.length() - 4) %> )
					</p>
		<% } %>
	</div>
	
		<div class="pure-g-r">
		    <form class="pure-form" method="post">
		    <fieldset>
		    <legend class="center pure-u-1">Balance Inquiry</legend>
			 
 		    
			    <button class="pure-u-1 pure-button" id="swipe-button" type="button" onclick="setfocus();">
			    	Swipe Card Now
			    </button>

			<input class="pure-u-1" type="text" id="ccn" name="ccn" onblur="hidemessage();" 
			 required title="Please press the button above and slide a card to continue.">
			
			<div class="pure-u-1 center" id="message" >Ready to Swipe</div>
		    
			<input type="submit" class="pure-u-1 pure-button pure-button-primary" value="Check Balance"> 
			
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
    
    setfocus();

});
</script>
</html>