#tag Class
Protected Class HTTPDaemon
Inherits TCPSocket
	#tag Event
		Sub DataAvailable()
		  Dim data As MemoryBlock = Me.ReadAll
		  Dim clientrequest As New HTTPRequest(data, AuthenticationRealm, DigestAuthenticationOnly)
		  Me.Log(ClientRequest.MethodName + " " + ClientRequest.Path + " " + "HTTP/" + Format(ClientRequest.ProtocolVersion, "#.0"), 0)
		  Me.Log(ClientRequest.Headers.Source, -1)
		  
		  Dim tmp As HTTPRequest = clientrequest
		  If TamperRequest(tmp) Then
		    clientrequest = tmp
		  End If
		  
		  Dim doc As HTTPDocument
		  
		  If Me.AuthenticationRequired Then
		    If Not Authenticate(clientrequest) Then
		      doc = New HTTPDocument(401, clientrequest.Path)
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
		  
		  
		  If doc = Nil Then
		    doc = HandleRequest(clientrequest)
		  End If
		  
		  SendResponse(doc)
		  
		  
		Exception Err
		  If Err IsA EndException Or Err IsA ThreadEndException Then Raise Err
		  'Return an HTTP 500 Internal Server Error page.
		  Dim errpage As HTTPDocument
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
		  errpage = New HTTPDocument(500, stack)
		  
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
		 Shared Sub AddRedirect(Page As HTTPDocument)
		  HTTPDaemon.Redirects.Value(Page.Path) = Page
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub CacheCleaner(Sender As Timer)
		  #pragma Unused Sender
		  For Each Path As String In PageCache.Keys
		    Dim doc As HTTPDocument = PageCache.Value(Path)
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
		Protected Shared Function GZipPage(PageData As String) As String
		  'This function requires the GZip plugin available at http://sourceforge.net/projects/realbasicgzip/
		  'Returns the passed PageData after being compressed. If GZIPAvailable = false, returns the original PageData unchanged.
		  #If GZipAvailable Then'
		    Dim size As Single = PageData.LenB
		    If size > 2^26 Then Return PageData 'if bigger than 64MB, don't try compressing it.
		    System.DebugLog(App.ExecutableFile.Name + ": About to GZip data. Size: " + FormatBytes(size))
		    PageData = GZip.Compress(PageData)
		    size = PageData.LenB * 100 / size
		    System.DebugLog(App.ExecutableFile.Name + ": GZip done. New size: " + FormatBytes(PageData.LenB) + " (" + Format(size, "##0.0##\%") + " of original.)")
		    If GZip.Error <> 0 Then
		      Raise New RuntimeException
		    End If
		    Dim mb As New MemoryBlock(PageData.LenB + 8)
		    'magic
		    mb.Byte(0) = &h1F
		    mb.Byte(1) = &h8B
		    mb.Byte(2) = &h08
		    mb.StringValue(8, PageData.LenB) = PageData
		    Return mb
		  #Else
		    'QnDHTTPd.GZIPAvailable must be set to True and the GZip plugin must be installed.
		    #pragma Warning "The GZip Plugin is not available or has been disabled."
		    Return PageData
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function IsCached(ClientRequest As HTTPRequest) As Boolean
		  If PageCache.HasKey(ClientRequest.Path) And UseCache Then
		    'Dim reqDate As Date = HTTPDate(ClientRequest.Headers.GetHeader("If-Modified-Since"))
		    'Dim cache As HTTPDocument = PageCache.Value(ClientRequest.Path)
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
		Private Sub SendResponse(ResponseDocument As HTTPDocument)
		  Dim tmp As HTTPDocument = ResponseDocument
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
		        gz = GZipPage(Replace(ResponseDocument.PageData, "%PAGEGZIPSTATUS%", "Compressed with GZip " + GZip.Version))
		        ResponseDocument.pagedata = gz
		      Catch Error
		        'Just send the uncompressed data
		        ResponseDocument.Headers.SetHeader("Content-Encoding", "Identity")
		      End Try
		      ResponseDocument.Headers.SetHeader("Content-Length", Str(ResponseDocument.Pagedata.LenB))
		    #else
		      ResponseDocument.PageData = Replace(ResponseDocument.PageData, "%PAGEGZIPSTATUS%", "No compression.")
		    #endif
		    
		    ResponseDocument.Headers.SetHeader("Connection", "close")
		    
		  End If
		  If ResponseDocument.Method = RequestMethod.HEAD Then
		    ResponseDocument.Headers.SetHeader("Content-Length", Str(ResponseDocument.Pagedata.LenB))
		    ResponseDocument.Pagedata = ""
		    If PageCache.HasKey(ResponseDocument.Path) Then PageCache.Remove(ResponseDocument.Path)
		  End If
		  Me.Log(HTTPResponse(ResponseDocument.StatusCode), 0)
		  Me.Log(ResponseDocument.Headers.Source(True), -1)
		  If ResponseDocument.StatusCode = 405 Then 'Method not allowed
		    ResponseDocument.Headers.SetHeader("Allow", "GET, HEAD, POST")
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
		Event HandleRequest(ClientRequest As HTTPRequest) As HTTPDocument
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Log(Message As String, Severity As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event TamperRequest(ByRef HTTPRequest As HTTPRequest) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event TamperResponse(ByRef Response As HTTPDocument) As Boolean
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

	#tag Constant, Name = GZIPAvailable, Type = Boolean, Dynamic = False, Default = \"False", Scope = Public
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
