<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="_Default" %>

<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Edit Validation Set</title>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
		<link rel="stylesheet" href="http://code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
		
		<style type="text/css">
			html, body {
				height: 100%;
				width: 100%;
				margin: 10px;
				padding: 0;
				overflow: auto;
				font-family: arial;
				color: grey;
			}	
	
		</style>
	</head>
	<body>
	
	
	<div class="container">
		<header id="userInfo" style= "font-size:1.25em;"><b>Welcome, </b></header>
		<hr>
		<div class="jumbotron"><h2>Edit drop-down values.</h2>
		<p>Edit values in the boxes below. After one line is edited, select SUBMIT to save the changes.</p> <p><b>This must be done for each row that is changed.</b></p>
		<ul>
			<li><small><b>Description</b> is what shows in the drop down.</small></li>
			<li><small><b>Value</b> is what is stored in the database.</small></li>
			<li><small><b>Active</b> is whether or not it shows up in the drop down. Mark FALSE to take it out of the list.</small></li>
			<li><small><b>Ordering</b> decides the order of that item in the drop down.</small></li>
		</ul>
		
		</div>
		
		<div id="ValSetReturn">
			
			
		</div>
	
	</div>
	
	<!-- For oauth -->
	<form id="form1" runat="server"></form>
	
	<script src="http://code.jquery.com/jquery-1.10.1.min.js"></script>
	<script>
	
	
		$(document).ready(function(){
			
			init();
			
			var _userEmail = OAUTH.email_address;
			$("#userInfo").append(_userEmail + '!');
			
		});
		
		function init(){
				
			var _allQ = window.location.search;
			
			if (_allQ.indexOf('&') === -1){
			
				//Only one Parameter so specify val set value
				var _f = _allQ.split('=');
				_valSet = _f[1];
				
				getData(_valSet);
			};
		
		};
		
		function getData(valSet){
					
			
			$.ajax({
				type: "GET",
				url: "http://apps.cityoflewisville.com/citydata/?datasetid=PSOFIA_ValSet&setid=" + valSet + "&oauthToken=" + OAUTH.access_token +"&datasetformat=jsonp&callback=?",
				contentType: "application/json; charset=utf-8",
				dataType: 'jsonp',
				success: function(e) {
					
					var _x = "<table id='Vals' class='table table-striped table-hover table-bordered'><caption><h3>" + e.results[0].ValSetName + ":</h3></caption><thead><th>Edit</th><th>Description</th><th>Value</th><th>Active</th><th>Ordering</th></thead><tbody>";
					
					Object.keys(e.results).forEach(function(key)
						{	
							_x += "<tr><td><button type = 'button' onclick=sendEdit(" + e.results[key].EntryID + ") class='btn-info'>Submit</button></td><td><input type='text' id='" + e.results[key].EntryID  + "_Description' value='" + e.results[key].Description 
									+ "'></input></input></td><td><input type='text' id='" + e.results[key].EntryID  + "_Value' value='" + e.results[key].Value 
									+ "'></input></input></td><td><input type='text' id='" + e.results[key].EntryID  + "_Active' value='" + e.results[key].Active 
									+ "'></input></input></td><td><input type='text' id='" + e.results[key].EntryID  + "_Ordering' value='" + e.results[key].Ordering + "'></input></input></td></tr>";
						})
					
					_x += "</tbody></table>";
				
					$("#ValSetReturn").html(_x);
				}
			});	
		};
		
		function sendEdit(EntryID){
			
			_entryID = EntryID;
			_d = $("#" + EntryID + "_Description").val();
			_v = $("#" + EntryID + "_Value").val();
			_a = $("#" + EntryID + "_Active").val();
			_o = $("#" + EntryID + "_Ordering").val();
			
			if (isNaN(_o)){
				
				_o = 0;
			}
						
			$.ajax({
				type: "GET",
				url: "http://apps.cityoflewisville.com/citydata/?datasetid=EditVSVal&SetID=" + _valSet + "&Desc=" + _d + "&Value=" + _v + "&Active=" + _a + "&Ordering=" + _o + "&EntryID=" + _entryID + "&oauthToken=" + OAUTH.access_token +"&datasetformat=jsonp&callback=?",
				contentType: "application/json; charset=utf-8",
				dataType: 'jsonp',
				success: function(e) {
					console.log("edited value for entry id " + EntryID);
				}
			})

		};
		
	</script>
	</body>
</html>