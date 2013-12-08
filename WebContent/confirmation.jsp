<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
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
          $("#code").val("");
          $("#size").text("");
          sig_decode($("#sigpad canvas")[0]);
        }).click();
        
        $("#encode").click(function() {
          var data = $("#sigpad canvas")[0].encode();
          $("#code").val(data);
          $("#size").text(data.length + " bytes");
        })
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
	}
</style>
</head>
<body>
	<div id="sigpad">
		<div>
          Sign Here
        </div>
			<canvas width="500" height="200" data-strokestyle="#145394" 
				data-linecap="round" data-linewidth="2">
       		</canvas>
	</div>
	<br/>
	<button id="clear" class="btn" type="button">Clear</button>
	<button id="encode" class="btn" type="button">Encode</button>

</body>
</html>