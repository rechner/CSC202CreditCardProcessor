<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page 
		import="CreditCardProcessor.*" 
		import="java.text.NumberFormat"
		import="java.util.Locale"
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="http://yui.yahooapis.com/pure/0.3.0/pure-min.css">
<title>Transaction Complete</title>
</head>
<body>

<%
CardHolder cardHolder = (CardHolder) request.getSession().getAttribute("cardHolder");
String merchant = (String) request.getSession().getAttribute("merchant");
String chargeString = "" + request.getSession().getAttribute("toCharge");
double toCharge = 0;

if ((chargeString != null) && (!"null".equals(chargeString)))
	toCharge = Double.parseDouble(chargeString);
if(cardHolder == null || merchant == null || toCharge == 0.0) {
	// IDK
	cardHolder = new CardHolder();
	merchant = "undefined";
}
//create a money formatter
NumberFormat formatter = NumberFormat.getCurrencyInstance(Locale.US);
// format it
String amountString = formatter.format(toCharge);
%>

<div style="margin-top: 50px; text-align: center">
	<h1>Transaction complete.</h1>
	
	
      <p><%= cardHolder.name %> was charged <strong><%= amountString %></strong><br>
      Your remaining balance is <%= formatter.format(cardHolder.balance - toCharge) %>.<br><br>
      <a href="virtualterminal.jsp">Click here to continue.</a>  
	</p>
</div>

</body>
</html>