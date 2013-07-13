window.onload=function(){
	document.body.innerHTML = "<br/><br/>" +
		"<div id='loginform' class='center'>" +
		"<form method='post' action='/login'>" +
		"<h1>Login</h1><br/>" +
		"<LABEL>Username:</LABEL> <INPUT type='text' name='username' /> <br/>" +
		"<LABEL>Password:&nbsp;&nbsp;</LABEL> <INPUT type='password' name='password' /> <br/>" +
		"<INPUT type='submit' value='Login' />" +
		"</form>" +
		"</div>";
}