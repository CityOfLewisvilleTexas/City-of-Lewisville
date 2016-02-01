'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
'Use Google oAuth to obtain an Access_token that is sent to the client to utilize in our webservices
'
'Uses a Google-Developer-Console account at:
'  https://console.developers.google.com/apis/credentials?project=round-dreamer-796
'  As of 11/12/2015, jkirkland, clee, emayes and clarson were owners of this project
'@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

Imports System.Net
Imports System.IO
Imports System.Runtime.Serialization.Json
Imports System.Runtime.Serialization.Formatters
Imports System.Text

Partial Class _Default
    Inherits System.Web.UI.Page
    
    Public oAuthClientId As String = "819027772449-2us5mt2tu1ec84nve9353qka8i6mfj68.apps.googleusercontent.com"
    Public oAuthClientSecret As String = "HE9RS70btK6bwiMty2waAtDm"
    
    'Local Cookies:
    ' - googlerefreshtoken
    ' - googleaccesstoken
    ' - googleaccesstokenexpiration
    
    '--------------------------------------------------------------------------------------------
    'PAGE LOAD
    '--------------------------------------------------------------------------------------------
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
    
        '`````````````````````````````````````````````````````````````
        'OAUTH DANCE
        '`````````````````````````````````````````````````````````````
        
       '1) Page_Load: Url contain DOES NOT CONTAIN a &code parameter. 
        If Request.QueryString("code") Is Nothing Then
        
            'Save any QueryString parameters to a session variable so we can reapply them at the end
             Session("OriginalUrl") = Request.Url.AbsoluteUri.ToString()
        
            'Is user already logged-in?
            
           'A) User has not been authenticated yet by Google. Go get a refresh_token (and the first access_token). We'll use the refresh_token to get more access_tokens as they expire
            If Len(getLocalCookieValue("googlerefreshtoken")) = 0 Then
                Dim url As String = "https://accounts.google.com/o/oauth2/auth?response_type=code"
                url += "&scope="
                url += "https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+"
                url += "https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile"
                url += "&redirect_uri=" & Request.Url.AbsoluteUri.ToString.ToLower.Split("?")(0)
                url += "&client_id=" & oAuthClientId
                url += "&access_type=offline"
                url += "&approval_prompt=force"  '<--Force Google to send us a refresh_token
                Response.Redirect(url)
            
           'B) We already have a refresh_token stored in a local cookie. Use it to get a new access_token
            Else
            
               'Use refresh_token to get a new access_token from Google
                Dim _oauth As New oAuthService
                Dim _tokenResponse As String = _oauth.GetToken( _
                    code:="", _
                    clientID:=oAuthClientId, _
                    clientSecret:=oAuthClientSecret, _
                    redirectURIs:=Request.Url.AbsoluteUri.ToString.ToLower.Split("?")(0), _
                    refreshToken:=getLocalCookieValue("googlerefreshtoken") _
                )
                             
              'Send the Google 0auth data to the front-end (this will include the short-life access_token, access_token_expiration, email_address) (NO REFRESH_TOKEN. It only is received on the very first visit)
               Dim _oauthResults As String = "{""access_token"": """ & _tokenResponse.split("|")(0) & """,""email_address"": """ & _tokenResponse.split("|")(3) & """}"
               Dim _javascriptAutoRefreshAccessToken As String = _
                  "setInterval(function(){" & _
                  "  $.ajax({ " & _
                  "     type: 'POST'," & _
                  "     url: 'https://www.googleapis.com/oauth2/v3/token'," & _
                  "     contentType:'application/x-www-form-urlencoded'," & _
                  "     dataType: 'json'," & _
                  "     data: 'client_id="& oAuthClientId &"&client_secret="& oAuthClientSecret &"&refresh_token="& getLocalCookieValue("googlerefreshtoken") & "&grant_type=refresh_token'," & _
                  "     success: function(e) { OAUTH.access_token = e.access_token; } " & _
                  "  }); " & _
                  "}, 900000) //Run every 15 minutes"
               Dim cs As ClientScriptManager = Page.ClientScript
               cs.RegisterStartupScript(Me.GetType(),"oauthscript","<script>var OAUTH = "& _oauthResults &"; " & _javascriptAutoRefreshAccessToken & "</script>") 
            End If           

        '2) Page_Load: Url CONTAINS "&code" parameter. We assume Google-oAuth is returning us to our app after user logged-in at Google
        Else
            'Use the &code value to get a new Access_token and Refresh_token. 
            Dim _oauth As New oAuthService
            Dim _tokenResponse As String = _oauth.GetToken( _
                code:=Request.QueryString("code"), _
                clientID:=oAuthClientId, _
                clientSecret:=oAuthClientSecret, _
                redirectURIs:=Request.Url.AbsoluteUri.ToString.ToLower.Split("?")(0), _
                refreshToken:="" _
            )
            
           'Once we have the oauth response, store its results
            If( Len(_tokenResponse.split("|")(1)) > 0 ) Then
                Response.Cookies("googlerefreshtoken").Value = _tokenResponse.split("|")(1)
            End If
                                          
           'Send the Google oAuth data to the front-end (this will include the short-life access_token refresh_token, access_token_expiration, email_address),
            Dim _oauthResults As String = "{""access_token"": """ & _tokenResponse.split("|")(0) & """,""email_address"": """ & _tokenResponse.split("|")(3) & """}" 
            Dim _javascriptAutoRefreshAccessToken As String = _
               "setInterval(function(){" & _
               "  $.ajax({ " & _
               "     type: 'POST'," & _
               "     url: 'https://www.googleapis.com/oauth2/v3/token'," & _
               "     contentType:'application/x-www-form-urlencoded'," & _
               "     dataType: 'json'," & _
               "     data: 'client_id="& oAuthClientId &"&client_secret="& oAuthClientSecret &"&refresh_token="& getLocalCookieValue("googlerefreshtoken") & "&grant_type=refresh_token'," & _
               "     success: function(e) { OAUTH.access_token = e.access_token; } " & _
               "  }); " & _
               "}, 900000) //Run every 15 minutes"
            Dim cs As ClientScriptManager = Page.ClientScript
            cs.RegisterStartupScript(Me.GetType(),"oauthscript","<script>var OAUTH = "& _oauthResults &"; " & _javascriptAutoRefreshAccessToken & "</script>") 
            
           'Rebuild the original url that the user went to (remove Google &code and reattach any QueryString parameters)
            Response.Redirect(Session("OriginalUrl"))
        End If
    End Sub
    
    Public Function getLocalCookieValue(ByVal cookieName As String) As String
        Dim i As Integer
        Dim val As String = ""
        Dim aCookie As HttpCookie

        For i = 0 To Request.Cookies.Count - 1
            aCookie = Request.Cookies(i)
            If aCookie.Name = cookieName Then
                val = aCookie.Value
            End If
        Next

        Return val
    End Function
End Class







Public Class oAuthService
    Inherits System.Web.Services.WebService


    Public Function GetToken(ByVal code As String, ByVal clientID As String, ByVal clientSecret As String, ByVal redirectURIs As String, ByVal refreshToken As String) As String

        Dim gId As New GoogleId()
        Dim emailAddress As String
        Dim _token As String = ""
        Dim _refreshtoken As String = ""
        Dim _expirationseconds As String = ""

        'Validate the authorization code received and pass back to google
        Dim responseFromServer As New GoogleResponse()
        Dim requestToken As HttpWebRequest = DirectCast(WebRequest.Create("https://accounts.google.com/o/oauth2/token"), HttpWebRequest)
        requestToken.Method = "POST"
        Dim postData As [String] = ""

        'What type of oauth method are we going to use? Original user-authorization CODE or an existing REFRESH_TOKEN?
        If refreshToken = "" Then
            postData = [String].Format( _
                "code={0}&client_id={1}&client_secret={2}&redirect_uri={3}&grant_type=authorization_code", _
                code, clientID, clientSecret, redirectURIs _
            )
        Else
            postData = [String].Format( _
                "refresh_token={0}&client_id={1}&client_secret={2}&redirect_uri={3}&grant_type=refresh_token", _
                refreshToken, clientID, clientSecret, redirectURIs _
            )
        End If

        'the token endpoint will respond with a JSON array that describes the token or an error.
        Dim byteArray As Byte() = Encoding.UTF8.GetBytes(postData)
        requestToken.ContentType = "application/x-www-form-urlencoded"
        requestToken.ContentLength = byteArray.Length

        Using dataStream As Stream = requestToken.GetRequestStream()
            dataStream.Write(byteArray, 0, byteArray.Length)
            dataStream.Close()
            Dim response As WebResponse = requestToken.GetResponse()
            If DirectCast(response, HttpWebResponse).StatusCode = HttpStatusCode.OK Then
                Using reader As New StreamReader(response.GetResponseStream())
                    responseFromServer = Deserialise(Of GoogleResponse)(reader.ReadToEnd())
                    reader.Close()
                    dataStream.Close()
                    response.Close()
                End Using
            Else
                emailAddress = "Error: Google denied your email request"
                dataStream.Close()

                response.Close()
            End If
        End Using

        If responseFromServer IsNot Nothing AndAlso Not String.IsNullOrEmpty(responseFromServer.access_token) Then
            _token = responseFromServer.access_token
            _refreshtoken = responseFromServer.refresh_token
            _expirationseconds = responseFromServer.expires_in

            'second validation
            'after google returns an access token send access token back to Google to get user's basic profile information
            Dim url As String = [String].Format("https://www.googleapis.com/oauth2/v1/userinfo?access_token={0}", responseFromServer.access_token)
            Dim requestUserInfo As HttpWebRequest = DirectCast(WebRequest.Create(url), HttpWebRequest)
            Dim responseUserInfo As HttpWebResponse = DirectCast(requestUserInfo.GetResponse(), HttpWebResponse)
            If DirectCast(responseUserInfo, HttpWebResponse).StatusCode = HttpStatusCode.OK Then
                Using receiveStream As Stream = responseUserInfo.GetResponseStream()
                    Dim encode As Encoding = System.Text.Encoding.GetEncoding("utf-8")
                    Using readStream As New StreamReader(receiveStream, encode)
                        ' puts information into appropriate fields in GoogleId class
                        gId = Deserialise(Of GoogleId)(readStream.ReadToEnd())
                        responseUserInfo.Close()
                        readStream.Close()
                        emailAddress = gId.email
                    End Using
                End Using

            End If
        End If

        Return _token & "|" & _refreshtoken & "|" & _expirationseconds & "|" & gId.email

    End Function

    Public Shared Function Deserialise(Of T)(ByVal json As String) As T
        Using ms = New MemoryStream(Encoding.Unicode.GetBytes(json))
            Dim serialiser = New DataContractJsonSerializer(GetType(T))
            Return DirectCast(serialiser.ReadObject(ms), T)
        End Using
    End Function
    Public Class GoogleResponse
        Public Property access_token() As [String]
            Get
                Return m_access_token
            End Get
            Set(ByVal value As [String])
                m_access_token = value
            End Set
        End Property
        Private m_access_token As [String]
        Public Property refresh_token() As [String]
            Get
                Return m_refresh_token
            End Get
            Set(ByVal value As [String])
                m_refresh_token = value
            End Set
        End Property
        Private m_refresh_token As [String]
        Public Property expires_in() As [String]
            Get
                Return m_expires_in
            End Get
            Set(ByVal value As [String])
                m_expires_in = value
            End Set
        End Property
        Private m_expires_in As [String]
        Public Property token_type() As [String]
            Get
                Return m_token_type
            End Get
            Set(ByVal value As [String])
                m_token_type = value
            End Set
        End Property
        Private m_token_type As [String]
    End Class
    Public Class GoogleId
        Public Property id() As [String]
            Get
                Return m_id
            End Get
            Set(ByVal value As [String])
                m_id = value
            End Set
        End Property
        Private m_id As [String]
        Public Property email() As [String]
            Get
                Return m_email
            End Get
            Set(ByVal value As [String])
                m_email = value
            End Set
        End Property
        Private m_email As [String]
        Public Property verified_email() As [Boolean]
            Get
                Return m_verified_email
            End Get
            Set(ByVal value As [Boolean])
                m_verified_email = value
            End Set
        End Property
        Private m_verified_email As [Boolean]
        Public Property name() As [String]
            Get
                Return m_name
            End Get
            Set(ByVal value As [String])
                m_name = value
            End Set
        End Property
        Private m_name As [String]
        Public Property given_name() As [String]
            Get
                Return m_given_name
            End Get
            Set(ByVal value As [String])
                m_given_name = value
            End Set
        End Property
        Private m_given_name As [String]
        Public Property family_name() As [String]
            Get
                Return m_family_name
            End Get
            Set(ByVal value As [String])
                m_family_name = value
            End Set
        End Property
        Private m_family_name As [String]
        Public Property link() As [String]
            Get
                Return m_link
            End Get
            Set(ByVal value As [String])
                m_link = value
            End Set
        End Property
        Private m_link As [String]
        Public Property picture() As [String]
            Get
                Return m_picture
            End Get
            Set(ByVal value As [String])
                m_picture = value
            End Set
        End Property
        Private m_picture As [String]
        Public Property gender() As [String]
            Get
                Return m_gender
            End Get
            Set(ByVal value As [String])
                m_gender = value
            End Set
        End Property
        Private m_gender As [String]
        Public Property locale() As [String]
            Get
                Return m_locale
            End Get
            Set(ByVal value As [String])
                m_locale = value
            End Set
        End Property
        Private m_locale As [String]
    End Class
End Class


