<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="_Default" %>
<!DOCTYPE html>
<html lang="en">
	<head>
		<title>City of Lewisville Forms</title>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">
		<link rel="stylesheet" href="http://code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
		
		<style type="text/css">
			html, body {
				margin: 10px;
				padding: 0;
				font-family: arial;
				color: grey;
				height: 100%;
			}
		
			html .ui-autocomplete {
				height: 250px;
			}		
			
			.form-horizontal {
				border-style: solid;
				border-left-width: 1px;
			}
			
			#formLayout {
				padding: 25px;
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
			
			.section {
				font-size: 1.25em;
				background-color: rgb(204, 229, 255);
				border: 2px solid black;
				box-shadow: 3px 3px 1.5px #888888;
				padding: 2px 0px 2px 2px;
			}
			
			@media (min-width: 1200px){
			
				input[type=checkbox]{
					-ms-transform: scale(1); /* IE */
					-moz-transform: scale(1); /* FF */
					-webkit-transform: scale(1); /* Safari and Chrome */
					-0-transform: scale(1); /* Opera */
				}
				
				
				input, select, number {
					-ms-transform: scale(0.75); /* IE */
					-moz-transform: scale(0.75); /* FF */
					-webkit-transform: scale(0.75); /* Safari and Chrome */
					-0-transform: scale(0.75); /* Opera */					
					
				}			
			
			}
		</style>
	</head> 
	<body>
	
	
	<div class="container">
		<header id="userInfo" style= "font-size:1.25em;"><b>Welcome, </b></header>
		<hr>
		<div id="deleteInfo"> <h3>Are you sure you want to DELETE this form record?</h3>
			<button type="button" class="btn btn-danger" onclick="deleteData()" >YES</button>
			<button type="button" class="btn btn-info" onclick="resetWindow()">CANCEL</button>
			</div>
		
		<h2 id="formTitle"></h2>
	
		<div class="form-horizontal" role="form" id="formLayout" >
			
			<div id="6">
			
			</div>
			
		</div>
				
		
	</div>	
	
	
	
	
	<!--For oAuth----------------------------------------->

	<form id="form1" runat="server"></form>
	<!------------------------------------------->
	
	<script src="http://code.jquery.com/jquery-1.10.1.min.js"></script>
	<script>
		
		var _allQ = window.location.search;
		
		if (_allQ.indexOf('&') === -1){
		
			//No recordNumber Parameter so specify form value from url and set _rn blank.
			var _f = _allQ.split('=');
			var form = _f[1];
			var _rn = '';
		};
		
		if (_allQ.indexOf('&') != -1){
		
			//Has a recordNumber parameter so get both
			var _f = _allQ.split('&');
			var form = _f[0].split('=')[1];
			var _rn = _f[1].split('=')[1];
		};
		
		
		var form_storage = "form";
		var _userEmail = '';
				
		$(document).ready(function(){
			
			
			
			updateStoredForm();
			
			_userEmail = OAUTH.email_address;
			
			$("#userInfo").append(_userEmail + '!');
			
		});
		
		function init(){
			
			//add double click event to all date inputs which allows current data populated 
			$('input[type="date"]').dblclick(function() {
				var now = new Date();

				var day = ("0" + now.getDate()).slice(-2);
				var month = ("0" + (now.getMonth() + 1)).slice(-2);

				var today = now.getFullYear()+"-"+(month)+"-"+(day) ;
				
				$(this).val(today);
			});
			
			//add double click event to all time inputs which allows current data populated 
			$('input[type="time"]').dblclick(function() {
				
				var now = new Date();

				var day = ("0" + now.getDate()).slice(-2);
				var month = ("0" + (now.getMonth() + 1)).slice(-2);

				var today = now.getFullYear()+"-"+(month)+"-"+(day) ;
				
				// Create an array with the current hour, minute and second
				  var time = [ now.getHours(), now.getMinutes(), now.getSeconds() ];
				
				// Determine AM or PM suffix based on the hour
				  var suffix = ( time[0] < 12 ) ? "AM" : "PM";

				// Convert hour from military time
				//  time[0] = ( time[0] < 12 ) ? time[0] : time[0] - 12;

				// If hour is 0, set it to 12
				//  time[0] = time[0] || 12;
				
				// If seconds and minutes are less than 10, add a zero
				  for ( var i = 1; i < 3; i++ ) {
					if ( time[i] < 10 ) {
					  time[i] = "0" + time[i];
					}
				  }	
				// Return the formatted string
				var _finalTime = time.join(":");
				
				$(this).val(_finalTime);
			});
			
		};
		
		
		function updateStoredForm(){
			
		/*Check the server for updated form information*/
			$.ajax({
				type: "GET",
				url: "http://eservices.cityoflewisville.com/citydata/?datasetid=PSOFIA_Forms&form=" + form + "&RecordNumber=" + _rn + "&oauthToken=" + OAUTH.access_token + "&datasetformat=jsonp&callback=?",
				contentType: "application/json; charset=utf-8",
				dataType: 'jsonp',
				success: function(e) {
				
				triggerBuild(e);
				
				}
			});	
		};	
		
		function triggerBuild(value){
												
			buildForm(value);
			/*Global variable for record number*/
			_recordNumber = value.results[0].RecordNumber;
		};
		
		
		
		
		function buildForm(value){
			/*Populate Form Name*/
			
				var _formName = value.results[0].FormName;
				$("#formTitle").append(_formName);
												
				/*Build out Sections and form fields*/
				Object.keys(value.results).forEach(function(key)
					{
						var _section = value.results[key].SectionID;
						var _subSection = value.results[key].SubSectionID;
						
						if (value.results[key].NewSection == 1 && value.results[key].SectionID != 6){
							
							/*Needs new section html created, then add the field*/
							var _newSection = "<hr></hr><div id='" + _section  +  "' ><p class = 'section'>" + value.results[key].SectionName  + "</p></div>";
							
							$("#formLayout").append(_newSection);	
														
						} 
						
						if (value.results[key].NewSubSection == 1 && value.results[key].SubSectionID > 0 ){
							
							/*Needs new section html created, then add the field*/
							var _newSubSection = "<hr></hr><div id='s" + _subSection +  "' class='subsection'><p>" + value.results[key].SubSectionName  + "</p></div>";
							
							$("#" + _section ).append(_newSubSection);	
														
						} 
												
					
						/* Needs the field created and added*/
						var _newField = value.results[key].HTML; 
						
						if (value.results[key].SubSectionID = ''){
							 $("#s" + _section ).append(_newField);
						} else {
							 $("#" + _section ).append(_newField);
						}
						
					})
	
			//Add listner for double click on date inputs
			init();
			
		};
			
		function deleteData(){
			$.ajax({
				type: "GET",
				url: "http://eservices.cityoflewisville.com/citydata/?datasetid=PSOFIADel&form=" + form + "&RecordNumber=" + _rn + "&oauthToken=" + OAUTH.access_token + "&datasetformat=jsonp&callback=?",
				contentType: "application/json; charset=utf-8",
				dataType: 'jsonp',
				success: function(e) {
			
				
				//alert("Record was deleted.");
				window.location.assign("http://apps.cityoflewisville.com/psofia?form=" + form);
				}
			});	
			
		}
		
		function resetWindow(){
			
			window.location.assign("http://apps.cityoflewisville.com/psofia?form=" + form);
			
		}
		
	</script>
	
	
	
	
	</body>
</html>
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	