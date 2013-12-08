<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page isThreadSafe="false" %>
<!DOCTYPE html>
<html>
<head>


<!-- CDN WITCHERY -->
<link rel="stylesheet" href="http://yui.yahooapis.com/pure/0.3.0/pure-min.css">
<script src="http://codeorigin.jquery.com/jquery-2.0.3.min.js"></script>
<script src="autoNumeric.js"></script>
<!-- CDN WITCHERY -->

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Deposit to Account</title>
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
    
</style>
</head>
<body>

<div class="pure-g-r headroom">
	<div class="pure-u-1-3"></div> <!-- SPACERS -->
	<div class="pure-u-1-3">
		<div class="pure-g-r">
		    <form class="pure-form">
		    <fieldset>
		    <legend class="center pure-u-1">Deposit Funds</legend>
			 
			 <div class="pure-g-r">   
			    <input class="pure-u-1-2" type="text" id="amount" name="amount" autofocus required>
			    
			    <button class="pure-u-1-2 pure-button" id="swipe-button" type="button" onclick="setfocus();">
			    	Click to Swipe Card
			    </button>
			</div>
			<input class="pure-u-1" type="text" id="ccn" name="ccn" onblur="hidemessage();" 
			 required title="Please press the button above and slide a card to continue.">
			
			<div class="pure-u-1 center" id="message" >Ready to Swipe</div>
		    
			<input type="submit" class="pure-u-1 pure-button pure-button-primary" value="Process Deposit"> 
			
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
            e.target.setCustomValidity("Please enter amount to be credited.");
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