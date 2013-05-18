#tag Class
Protected Class HTTPDaemon
Inherits TCPSocket
	#tag Event
		Sub DataAvailable()
		  Dim data As MemoryBlock = Me.ReadAll
		  Dim clientrequest As HTTPRequest
		  Dim doc As HTTPResponse
		  Try
		    clientrequest = New HTTPRequest(data, AuthenticationRealm, DigestAuthenticationOnly)
		    Me.Log(ClientRequest.MethodName + " " + ClientRequest.Path + " " + "HTTP/" + Format(ClientRequest.ProtocolVersion, "#.0"), 0)
		    Me.Log(ClientRequest.Headers.Source, -1)
		    
		    Dim tmp As HTTPRequest = clientrequest
		    If TamperRequest(tmp) Then
		      clientrequest = tmp
		    End If
		  Catch err As UnsupportedFormatException
		    doc = New HTTPResponse(400, "") 'bad request
		    GoTo Send
		  End Try
		  
		  If clientrequest.ProtocolVersion < 1.0 Or clientrequest.ProtocolVersion >= 1.2 Then
		    doc = New HTTPResponse(505, Format(ClientRequest.ProtocolVersion, "#.0"))
		    GoTo Send
		  End If
		  
		  If Me.AuthenticationRequired Then
		    If Not Authenticate(clientrequest) Then
		      doc = New HTTPResponse(401, clientrequest.Path)
		      If Me.DigestAuthenticationOnly Or clientrequest.AuthDigest Then
		        'digest
		        'Work in progress
		        Dim rand As New Random
		        doc.Headers.SetHeader("WWW-Authenticate", "Digest realm=""" + clientrequest.AuthRealm + """,nonce=""" + Str(Rand.InRange(50000, 100000)) + """")
		      Else 'basic
		        doc.Headers.SetHeader("WWW-Authenticate", "Basic realm=""" + clientrequest.AuthRealm + """")
		        
		      End If
		    End If
		  End If
		  
		  If Redirects.HasKey(clientrequest.Path) And doc = Nil Then
		    doc = Redirects.Value(clientrequest.Path)
		    doc.FromCache = True
		    Me.Log("Using redirect.", -2)
		  End If
		  
		  Send:
		  If doc = Nil Then
		    doc = HandleRequest(clientrequest)
		  End If
		  
		  If doc = Nil Then
		    Select Case clientrequest.Method
		    Case RequestMethod.TRACE
		      doc = New HTTPResponse(200, "")
		      doc.Headers.SetHeader("Content-Length", Str(Data.Size))
		      doc.Headers.SetHeader("Content-Type", "message/http")
		      doc.MessageBody = Data
		    Case RequestMethod.OPTIONS
		      doc = New HTTPResponse(200, "")
		      doc.MessageBody = ""
		      doc.Headers.SetHeader("Content-Length", "0")
		      doc.Headers.SetHeader("Allow", "GET, HEAD, POST, TRACE, OPTIONS")
		      doc.Headers.SetHeader("Accept-Ranges", "bytes")
		    Case RequestMethod.GET, RequestMethod.HEAD
		      doc = New HTTPResponse(404, clientrequest.Path)
		    Else
		      If clientrequest.MethodName <> "" And clientrequest.Method = RequestMethod.InvalidMethod Then
		        doc = New HTTPResponse(501, clientrequest.MethodName) 'Not implemented
		      ElseIf clientrequest.MethodName = "" Then
		        doc = New HTTPResponse(400, "") 'bad request
		      ElseIf clientrequest.MethodName <> "" Then
		        doc = New HTTPResponse(405, clientrequest.MethodName)
		      End If
		    End Select
		  End If
		  
		  SendResponse(doc)
		  
		  
		Exception Err
		  If Err IsA EndException Or Err IsA ThreadEndException Then Raise Err
		  'Return an HTTP 500 Internal Server Error page.
		  Dim errpage As HTTPResponse
		  Dim stack As String
		  #If DebugBuild Then
		    If UBound(Err.Stack) <= -1 Then
		      stack = "<br />(empty)<br />"
		    Else
		      stack = Join(Err.Stack, "<br />")
		    End If
		    stack = "<b>Exception<b>: " + Introspection.GetType(Err).FullName + "<br />Error Number: " + Str(Err.ErrorNumber) + "<br />Message: " + Err.Message _
		    + "<br />Stack follows:<blockquote>" + stack + "</blockquote>" + EndOfLine
		  #endif
		  errpage = New HTTPResponse(500, stack)
		  
		  Me.SendResponse(errpage)
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub SendComplete(userAborted as Boolean)
		  #pragma Unused userAborted
		  Me.Close
		  If Me.KeepListening Then
		    Super.Listen
		  End If
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		 Shared Sub AddRedirect(Page As HTTPResponse)
		  HTTPDaemon.Redirects.Value(Page.Path) = Page
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub CacheCleaner(Sender As Timer)
		  #pragma Unused Sender
		  For Each Path As String In PageCache.Keys
		    Dim doc As HTTPResponse = PageCache.Value(Path)
		    Dim d As New Date
		    If doc.Expires.TotalSeconds < d.TotalSeconds Then
		      PageCache.Remove(Path)
		    End If
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function DecodeFormData(PostData As String) As Dictionary
		  Dim items() As String = Split(PostData, "&")
		  Dim form As New Dictionary
		  For i As Integer = 0 To UBound(items)
		    form.Value(URLDecode(NthField(items(i), "=", 1))) = URLDecode(NthField(items(i), "=", 2))
		  Next
		  
		  Return form
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function IsCached(ClientRequest As HTTPRequest) As Boolean
		  If PageCache.HasKey(ClientRequest.Path) And UseCache Then
		    'Dim reqDate As Date = HTTPDate(ClientRequest.Headers.GetHeader("If-Modified-Since"))
		    'Dim cache As HTTPResponse = PageCache.Value(ClientRequest.Path)
		    'If reqDate <> Nil And reqDate.TotalSeconds >= Cache.Modified.TotalSeconds Then
		    Return True
		    'End If
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Listen()
		  PageCache = New Dictionary
		  Super.Listen
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Log(Message As String, Severity As Integer)
		  RaiseEvent Log(Message.Trim + EndofLine, Severity)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Sub RemoveRedirect(HTTPpath As String)
		  If HTTPDaemon.Redirects.HasKey(HTTPpath) Then
		    HTTPDaemon.Redirects.Remove(HTTPpath)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SendResponse(ResponseDocument As HTTPResponse)
		  Dim tmp As HTTPResponse = ResponseDocument
		  If TamperResponse(tmp) Then
		    Me.Log("Outbound tamper.", -2)
		    ResponseDocument  = tmp
		  End If
		  If UseCache Then PageCache.Value(ResponseDocument.Path) = ResponseDocument
		  If Not ResponseDocument.FromCache Then
		    #If GZIPAvailable Then
		      Me.Log("Running gzip", -2)
		      ResponseDocument.Headers.SetHeader("Content-Encoding", "gzip")
		      Dim gz As String
		      Try
		        gz = GZipPage(Replace(ResponseDocument.MessageBody, "%PAGEGZIPSTATUS%", "Compressed with GZip " + GZip.Version))
		        ResponseDocument.MessageBody = gz
		      Catch Error
		        'Just send the uncompressed data
		        ResponseDocument.Headers.SetHeader("Content-Encoding", "Identity")
		      End Try
		      ResponseDocument.Headers.SetHeader("Content-Length", Str(ResponseDocument.MessageBody.LenB))
		    #else
		      ResponseDocument.MessageBody = Replace(ResponseDocument.MessageBody, "%PAGEGZIPSTATUS%", "No compression.")
		    #endif
		    
		    ResponseDocument.Headers.SetHeader("Connection", "close")
		    
		  End If
		  If ResponseDocument.Method = RequestMethod.HEAD Then
		    ResponseDocument.Headers.SetHeader("Content-Length", Str(ResponseDocument.MessageBody.LenB))
		    ResponseDocument.MessageBody = ""
		    If PageCache.HasKey(ResponseDocument.Path) Then PageCache.Remove(ResponseDocument.Path)
		  End If
		  Me.Log(HTTPReplyString(ResponseDocument.StatusCode), 0)
		  Me.Log(ResponseDocument.Headers.Source(True), -1)
		  If ResponseDocument.StatusCode = 405 Then 'Method not allowed
		    ResponseDocument.Headers.SetHeader("Allow", "GET, HEAD, POST, TRACE")
		  End If
		  
		  Me.Write(ResponseDocument.ToString)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Write(Text As String)
		  Super.Write(Text)
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Authenticate(ClientRequest As HTTPRequest) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event HandleRequest(ClientRequest As HTTPRequest) As HTTPResponse
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Log(Message As String, Severity As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event TamperRequest(ByRef HTTPRequest As HTTPRequest) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event TamperResponse(ByRef Response As HTTPResponse) As Boolean
	#tag EndHook


	#tag Property, Flags = &h0
		AuthenticationRealm As String = "Restricted Area"
	#tag EndProperty

	#tag Property, Flags = &h0
		AuthenticationRequired As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared CacheTimer As Timer
	#tag EndProperty

	#tag Property, Flags = &h0
		DigestAuthenticationOnly As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		KeepListening As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mPageCache As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mRedirects As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mUseCache As Boolean = True
	#tag EndProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  If mPageCache = Nil Then mPageCache = New Dictionary
			  return mPageCache
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mPageCache = value
			End Set
		#tag EndSetter
		Protected Shared PageCache As Dictionary
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  If mRedirects = Nil Then mRedirects = New Dictionary
			  return mRedirects
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mRedirects = value
			End Set
		#tag EndSetter
		Protected Shared Redirects As Dictionary
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mUseCache 'And Not GZIPAvailable
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value Then
			    CacheTimer = New Timer
			    CacheTimer.Period = 10000
			    AddHandler CacheTimer.Action, AddressOf CacheCleaner
			    CacheTimer.Mode = Timer.ModeMultiple
			  Else
			    CacheTimer = Nil
			  End If
			  mUseCache = value
			End Set
		#tag EndSetter
		Shared UseCache As Boolean
	#tag EndComputedProperty


	#tag Constant, Name = DaemonVersion, Type = String, Dynamic = False, Default = \"QnDHTTPd/1.0", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Address"
			Visible=true
			Group="Behavior"
			Type="String"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AuthenticationRealm"
			Visible=true
			Group="Behavior"
			InitialValue="""""Restricted Area"""""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AuthenticationRequired"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DigestAuthenticationOnly"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="KeepListening"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Port"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
			InheritedFrom="TCPSocket"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
