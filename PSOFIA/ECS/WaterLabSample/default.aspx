<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="_Default" %>

<!DOCTYPE html>
<html lang="en">
	<head>
		<title>ECS Water Lab Samples</title>
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
			 
			/* IE 6 doesn't support max-height
			* we use height instead, but this forces the menu to always be this tall
			*/
			* html .ui-autocomplete {
				height: 250px;
			}
			
			checkboxtext {
				font-size: 3 em;
			}	

			input[type=checkbox]{
				-ms-transform: scale(1.75); /* IE */
				-moz-transform: scale(1.75); /* FF */
				-webkit-transform: scale(1.75); /* Safari and Chrome */
				-0-transform: scale(1.75); /* Opera */
				margin-right: 10px;
							
			}
			
			.sectionNew p {
				color: red;
			}
			
			.form-horizontal {
				border-style: solid;
				border-left-width: 1px;
			}
			
			div p {
				font-size: 1.25em;
			}
			
			#formLayout {padding: 50px;}
			
			@media (min-width: 1200px){
				.col-lg-1{
					width: 100% !important;
					text-align: left !important;
					}
			}
			
		</style>
	</head> 
	<body>
	
	
	
	
	<div class="container">
		<header id="userInfo" style= "font-size:1.25em;"><b>Welcome, </b></header>
		<hr>
		<div class="jumbotron"><h2 id="formTitle">Environmental Control Services Water Laboratory Samples</h2></div>
		<br></br>
		<div class="row">
			<h4>To Run the Monthly submission report, select a Month and Year from the menu.</h4>
			<div class="col-md-4">
				<select id="SubmitMonth" class="form-control">
					<option value="1">January</option>
					<option value="2">February</option>
					<option value="3">March</option>
					<option value="4">April</option>
					<option value="5">May</option>
					<option value="6">June</option>
					<option value="7">July</option>
					<option value="8">August</option>
					<option value="9">September</option>
					<option value="10">October</option>
					<option value="11">November</option>
					<option value="12">December</option>
				</select>
			</div>	
			<div class="col-md-4">
				<select id="Years" class="form-control">
					<option value="currentyr"></option>
					<option value="lastyr"></option>
				</select>
			</div>	
			<div class="col-md-4">	
				<button type='submit' class='btn btn-default' onclick="submitMonthly()">Submit</button>
			</div>
		</div>
		

		
		<hr></hr>
	
		<div class="form-horizontal" role="form" id="formLayout" >
			
			<div>
			<div class="col-md-6"><a class="btn btn-default" href="http://apps.cityoflewisville.com/psofia/default.aspx?form=4&recordNumber=" target="_blank" role="button">Fill out New ECS Water Laboratory Sample</a></div>				
			</div>
			<br></br>
			<br></br>
			<div id="recent">
			
			</div>	
			
		</div>
		
	</div>
	
	<!--For oAuth----------------------------------------->

	<form id="form1" runat="server"></form>
	<!------------------------------------------->
	
	<script src="http://code.jquery.com/jquery-1.10.1.min.js"></script>
	<script>
	
	$(document).ready(function(){
		
		//Get the current year to populate the select box
			var currentYear = (new Date).getFullYear();
			
			//Populate the select box for year with the current year and previous year
			$("#Years option:first").text(currentYear);
			$("#Years option:first").val(currentYear);
			$("option[value='lastyr']").text(currentYear-1);
			$("option[value='lastyr']").val(currentYear-1);	
		
		var _userEmail = OAUTH.email_address;
		$("#userInfo").append(_userEmail + '!');
		
		//Get most recent submissions and display
		$.ajax({
			type: "POST",
			url: "http://apps.cityoflewisville.com/citydata/?datasetid=ECSRecentSamples" + "&oauthToken=" + OAUTH.access_token + "&datasetformat=jsonp&callback=?",
			contentType: "application/json; charset=utf-8",
			dataType: 'jsonp',
			success: function(e) {
				
				var _x = '<table class="table table-striped table-hover table-bordered"><thead><th>Sample Number</th><th>PWS Number</th><th>PWS Name</th><th>Collection Date</th><th>Collection Time</th><th>Received By</th><th>Entered By</th><th>Date Entered</th></thead><tbody>';
					
				
				Object.keys(e.results).forEach(function(key)
					{	
						_x += '<tr>'; 
						_x += '<td>'+ e.results[key].LabSampleID + '</td>';
						_x += '<td>'+ e.results[key].PWSNumber + '</td>';
						_x += '<td>'+ e.results[key].PWSName + '</td>';
						_x += '<td>'+ e.results[key].CollectionDate + '</td>';
						_x += '<td>'+ e.results[key].CollectionTime + '</td>';
						_x += '<td>'+ e.results[key].ReceivedBy + '</td>';
						_x += '<td>'+ e.results[key].EnteredBy + '</td>';
						_x += '<td>'+ e.results[key].DateEntered + '</td>';
						_x += '</tr>';
					
					})
								
				_x += '</tbody></table>';
				
				$("#recent").append(_x);
			
			}
		})
		
	});
	
	
	function submitMonthly(){
		
		var _mo = $("#SubmitMonth").val();
		var _yr = $("#Years").val();
		var _url = "http://apps.cityoflewisville.com/citydata/?datasetid=ECSMonthlySamples&Year=" + _yr + "&Month=" + _mo + "&oauthToken=" + OAUTH.access_token + "&datasetformat=csv";
		
		window.open(_url, '_blank');
				
	};
	
	
	</script>
		
	</body>
	</html>
	