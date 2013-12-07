<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Merchant Virtual Terminal</title>
<script>
	function setfocus() {
		document.getElementById("ccn").focus();
	}
</script>
</head>
<body>

	<form>
	  <dl>
		<dt>Amount to charge:</dt>
		<dd><input type="text" name="ammount"></dd>
		<dt><button type="button" onclick="setfocus();" >Swipe Card</button>
		<input type="text" id="ccn" name="ccn" style="width: 1px; height: 1px;"></dt>
		<dd></dd>
		
	  </dl>
	  <input type="submit">
	</form>

</body>
</html>