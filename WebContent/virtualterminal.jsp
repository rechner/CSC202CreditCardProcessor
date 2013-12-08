<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page isThreadSafe="false" %>
<!DOCTYPE html>
<html>
<head>


<!-- CDN WITCHERY -->
<link rel="stylesheet" href="http://yui.yahooapis.com/pure/0.3.0/pure-min.css">
<script src="http://codeorigin.jquery.com/jquery-2.0.3.min.js"></script>
<script src="https://raw.github.com/RobinHerbots/jquery.inputmask/2.x/dist/jquery.inputmask.bundle.min.js""></script>
<!-- CDN WITCHERY -->


<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Merchant Virtual Terminal</title>
<script>
    function setfocus() {
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
    }
    #message {
      color: green;
      visibility: hidden;
    }
    .center {
    	text-align: center;
    }
   
</style>
</head>
<body>

<div class="pure-g-r">

	<div class="pure-u-1-2">&nbsp</div>
	<div class="pure-u-1-2">&nbsp</div>
	<div class="pure-u-1-2">&nbsp</div>
	<div class="pure-u-1-2">&nbsp</div>
	<div class="pure-u-1-3"></div> <!-- SPACERS -->
	<div class="pure-u-1-3">
	    <form class="pure-form">
	    <fieldset>
	    <legend class="center">Charge Amount</legend>
	    <input type="text" 
	    	id="amount" name="amount" data-inputmask="'alias': 'decimal', 'groupSeparator': ',', 'autoGroup': true">
	    
	    <button type="button" onclick="setfocus();" class="pure-button" >Click to Swipe Card</button>
	            <input type="text" id="ccn" name="ccn" onblur="hidemessage();">
	            <div id="message" >Ready to Swipe</div>
	    <input type="submit" class="pure-button pure-button-primary">    
	    </fieldset>
	    </form>
	</div>
    <div class="pure-u-1-3"></div> <!-- SPACERS -->
</div>

</body>

<!-- amount input mask  -->
<script type="text/javascript">
$(document).ready(function(){
    $("#amount").inputmask('9,999.99', { numericInput: true, radixPoint: "." });
});

// was supposed to be for 
// #amount's input sanitation 
// onsubmit="checkInput()"
/* function checkInput() {
	alert(document.getElementById("amount").innerText);
} */

</script>
</html>