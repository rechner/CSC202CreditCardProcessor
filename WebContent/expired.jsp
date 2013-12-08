<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Expired Card</title>
<script src="http://codeorigin.jquery.com/jquery-2.0.3.min.js"></script>
<script type="text/javascript"> 

var x=1;
var set;

function Timer() 
{
    set=1;
    if(x==0 && set==1) {
        document.bgColor='#ff0000';
        x=1;
        set=0;
    }
    if(x==1 && set==1) {
        document.bgColor='#FFFFFF';
        x=0;
        set=0;
    }
}

var timerInterval = null;

startBlinking = function() {
   if(timerInterval === null)
       timerInterval = setInterval(Timer, 200);
}

stopBlinking = function() {
    if(timerInterval !== null) {
        clearInterval(timerInterval)
        timerInterval = null
    }
}
</script>

<style>
	#expiredCard {
		font-size: 200pt;
		font-weight: bold;
		font-family: impact;
		text-decoration: none;
	}
</style>
</head>
<body onload="startBlinking();">
	<a href="virtualterminal.jsp" id="expiredCard">Your Card Expired Asshole!</a>
</body>

</html>