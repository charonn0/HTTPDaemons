#tag Class
Protected Class HTTPDaemon
Inherits TCPSocket
	#tag Event
		Sub DataAvailable()
		  Dim data As MemoryBlock = Me.ReadAll
		  Dim clientrequest As New Request(data)
		  
		  Dim tmp As Request = clientrequest
		  If TamperRequest(tmp) Then
		    clientrequest = tmp
		  End If
		  If Me.AuthenticationRequired Then
		    Dim pw As String = ClientRequest.Headers.GetHeader("Authorization")
		    pw = pw.Replace("Basic ", "")
		    If Not Authenticate(pw) Then
		      Dim doc As Document = New Document(401, clientrequest.Path)
		      doc.Headers.SetHeader("WWW-Authenticate", "Basic realm=""" + Me.AuthenticationRealm + """")
		      Me.SendResponse(doc)
		      Return
		    End If
		  End If
		  
		  If Not Redirects.HasKey(clientrequest.Path) Then
		    HandleRequest(clientrequest)
		  Else
		    SendResponse(Redirects.Value(clientrequest.Path))
		  End If
		  
		Exception Err
		  If Err IsA EndException Or Err IsA ThreadEndException Then Raise Err
		  'Return an HTTP 500 Internal Server Error page.
		  Dim errpage As Document
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
		  errpage = New Document(500, stack)
		  
		  Me.SendResponse(errpage)
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub SendComplete(userAborted as Boolean)
		  #pragma Unused userAborted
		  Me.Close
		  If Me.KeepListening Then
		    Me.Listen
		  End If
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AddRedirect(HTTPpath As String, Page As Document)
		  Me.Redirects.Value(HTTPpath) = Page
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub CacheCleaner(Sender As Timer)
		  #pragma Unused Sender
		  PageCache = New Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function IsCached(ClientRequest As Request) As Boolean
		  If PageCache.HasKey(ClientRequest.Path) And UseCache Then
		    'Dim reqDate As Date = HTTPDate(ClientRequest.Headers.GetHeader("If-Modified-Since"))
		    'Dim cache As HTMLDocument = PageCache.Value(ClientRequest.Path)
		    'If reqDate <> Nil And reqDate.TotalSeconds >= Cache.Modified.TotalSeconds Then
		    Return True
		    'End If
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Log(Message As String, Severity As Integer)
		  RaiseEvent Log(Message.Trim + EndofLine, Severity)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveRedirect(HTTPpath As String)
		  If Me.Redirects.HasKey(HTTPpath) Then
		    Me.Redirects.Remove(HTTPpath)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub SendResponse(ResponseDocument As Document)
		  If Not ResponseDocument.FromCache Then
		    Dim tmp As Document = ResponseDocument
		    If TamperResponse(tmp) Then
		      Me.Log("Outbound tamper.", -2)
		      ResponseDocument  = tmp
		    End If
		    
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
		    If Me.KeepListening Then
		      ResponseDocument.Headers.SetHeader("Connection", "keep-alive")
		    Else
		      ResponseDocument.Headers.SetHeader("Connection", "close")
		    End If
		  End If
		  If UseCache Then PageCache.Value(ResponseDocument.Path) = ResponseDocument
		  Me.Log(HTTPResponse(ResponseDocument.StatusCode), 0)
		  Me.Log(ResponseDocument.Headers.Source, -1)
		  Me.Write(ResponseDocument.ToString)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Write(Text As String)
		  Super.Write(Text)
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Authenticate(AuthString As String) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event HandleRequest(ClientRequest As Request)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Log(Message As String, Severity As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event TamperRequest(ByRef Request As Request) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event TamperResponse(ByRef Response As Document) As Boolean
	#tag EndHook


	#tag Property, Flags = &h0
		AuthenticationRealm As String = """Restricted Area"""
	#tag EndProperty

	#tag Property, Flags = &h0
		AuthenticationRequired As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared CacheTimer As Timer
	#tag EndProperty

	#tag Property, Flags = &h0
		KeepListening As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mPageCache As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRedirects As Dictionary
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
		Protected Redirects As Dictionary
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
			Name="Index"
			Visible=true
			Group="ID"
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
