<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
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
	
	.sigPadButton {
	  margin-left: auto;
	  margin-right: auto;
	  width: 50px;
	}
</style>
</head>
<body>
	
	
	cardholder name
	amount to be charged
	
		<div id="sigpad">
			<div>
	          Sign Here
	        </div>
				<canvas width="500" height="200" data-strokestyle="#145394" 
					data-linecap="round" data-linewidth="2">
	       		</canvas>
		</div>
		<button id="clear" class="pure-button sigPadButton" type="button">Clear</button>
		<button id="checkOut" class="pure-button sigPadButton" type="button">Check Out!</button>
</body>
</html>