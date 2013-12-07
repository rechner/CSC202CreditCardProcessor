<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page isThreadSafe="false" %>
<!DOCTYPE html>
<html>
<head>

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
</style>
</head>
<body>

	<form>
	  <dl>
		<dt>Amount to charge:</dt>
		<dd><input type="text" name="amount"></dd>
		<dt>
			<button type="button" onclick="setfocus();" >Click to Swipe Card</button>
			<input type="text" id="ccn" name="ccn" onblur="hidemessage();">
			<div id="message" >Ready to Swipe</div>
		</dt>
		<dd></dd>
		
	  </dl>
	  <input type="submit">
	</form>

</body>
</html>