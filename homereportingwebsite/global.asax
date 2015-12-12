<%@ language="C#" %>
<script runat="server">
   
void Application_Start(object sender, EventArgs e)    {

}
void Session_Start(object sender, EventArgs e)    {
   
}
void Session_End(object sender, EventArgs e)    {
	
}
private void application_EndRequest(object sender, EventArgs e)
{
    HttpRequest request = HttpContext.Current.Request;
    HttpResponse response = HttpContext.Current.Response;

    if ((request.HttpMethod == "POST") &&
        (response.StatusCode == 404 && response.SubStatusCode == 13))
    {
        // Clear the response header but do not clear errors and transfer back to requesting page to handle error 
        response.ClearHeaders();
        Response.Write("Sorry, you have tired to upload a file which is over 4Mb in size. Please select a smaller file.");
        //HttpContext.Current.Server.Transfer(request.AppRelativeCurrentExecutionFilePath);
    }
} 

void Application_Error(object sender, EventArgs e)    {

	HttpException serverException;
		Exception innerException = null;
		// Get server exception
		serverException = (HttpException)Server.GetLastError();
		// Get inner exception
		
		if (serverException.InnerException != null) 
		innerException = serverException.InnerException;
		// Handle "Maximum request length exceeded." exception
		
	

}


</script>