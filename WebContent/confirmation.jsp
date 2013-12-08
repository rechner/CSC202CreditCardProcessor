<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page 
		import="CreditCardProcessor.*" 
		import="java.text.NumberFormat"
		import="java.util.Locale"
%>
<%
	CardHolder cardHolder = request.getSession.getAttribute("cardHolder");
	String merchant 	  = request.getSession.getAttribute("merchant");
	double toCharge 	  = request.getSession.getAttribute("toCharge");
	if(cardHolder == null || merchant == null || toCharge == 0.0) {
		// IDK
	}
%>
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" href="http://yui.yahooapis.com/pure/0.3.0/pure-min.css">

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
<script src="http://codeorigin.jquery.com/jquery-2.0.3.min.js"></script>
<script src="signature.js"></script> <!-- signature -->
<script>
	$(function() {
		sig_init($("#sigpad canvas")[0]);
        
		$("#clear").click(function() {      
            clear_canvas($("#sigpad canvas")[0]);
        }).click();
		
		 function validate_signature() {
	            var encodedSignature = $("#sigpad canvas")[0].encode();
	            if (encodedSignature != "0") {
	            	$("#canvas-validation").val("a");
				}
	        }
	        
			$("#checkOut").click(function() {      
	            validate_signature();
	        });
			
		
		//document.getElementById("canvas-validation").setCustomValidity("Please sign the signature pad");
	});
</script>
    
<style>
	#sigpad {
	  background-color: white;
	  border: 1px solid #CCCCCC;
	  border-radius: 3px 3px 3px 3px;
	  box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) inset;
	  height: 200px;
	  width: 500px;
	  
	  margin-left: auto;
	  margin-right: auto;
	  width: 500px;
	}

	#sigpad > div {
	  border-top: 2px solid #BBBBBB;
	  color: #888888;
	  display: inline-block;
	  font: 12px cursive;
	  margin: 150px 4% 0;
	  padding-top: 3px;
	  width: 92%;
	}

	#sigpad canvas {
	  display: block;
	  margin: -172px auto 0;
	  position: absolute;
	  cursor: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAPUlEQVQYlWNgIBaIBE8RBeJkKBZFlzQG4g9A/B+KQWxjZAVnkCRh+Biygp9YFHwmyQT8bkDyRRoQZyL7AgAI8EC4llBEhQAAAABJRU5ErkJggg==") 4 4, crosshair;
	}
	
	#content {
	   margin-left: auto;
	   margin-right: auto;
	   width: 500px;
	}
	
	.button-group {
		float: right;
		margin-top: 10px;
	}
	
	#canvas-validation {
		width: 1px;
		height: 1px;
		position: relative;
		top: -60px;
		left: -220px;		
		border: none;
   		background-color: transparent;
	}
	
	[required] {
    	color:red;
    	box-shadow: none;
	}
	
	.pretty {
	
		text-align: center;
		margin-top: 30px;
		margin-bottom: 20px;
	
	}
	
	body {
		font-family: Helvetica;
	}
</style>
</head>
<body>
	
	<div id="content">
	
	<%
		// create a money formatter
		NumberFormat formatter = NumberFormat.getCurrencyInstance(Locale.US);
		// format it
		String amountString = formatter.format(toCharge);
	%>
	
      <p style="text-align: left; color: grey"><%= cardHolder.name %> will be charged <strong><%= amountString %></strong><br>
			By signing I authorize this electronic funds transfer.</p>

	
		<div id="sigpad">
			<div>
	          Sign Here
	        </div>
				<canvas width="500" height="200" data-strokestyle="#145394" 
					data-linecap="round" data-linewidth="2">
	       		</canvas>
		</div>
		
		
		
		<div class="button-group">
		<form id="sigform">
			<input type="text" required id="canvas-validation">
			<button id="clear" class="pure-button sigPadButton" type="button">Clear</button>
			<button id="checkOut" class="pure-button sigPadButton" type="submit">Check Out!</button>
		</form>
		</div>
		
	</div>
</body>
</html>