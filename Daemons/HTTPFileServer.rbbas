#tag Class
Protected Class HTTPFileServer
Inherits HTTPDaemon
	#tag Event
		Sub Connected()
		  Me.KeepListening = True
		End Sub
	#tag EndEvent

	#tag Event
		Function HandleRequest(ClientRequest As HTTPRequest) As HTTPDocument
		  Dim doc As HTTPDocument 'The response object
		  Dim item As FolderItem = FindItem(ClientRequest.Path)
		  
		  Select Case ClientRequest.Method
		  Case RequestMethod.GET, RequestMethod.HEAD
		    If IsCached(ClientRequest) Then
		      'Cache hit
		      Dim cache As HTTPDocument = PageCache.Value(ClientRequest.Path)
		      doc = New HTTPDocument(cache, ClientRequest.Path)
		      doc.FromCache = True
		      Me.Log("Page from cache", -2)
		      
		    ElseIf item = Nil Then
		      '404 Not found
		      Me.Log("Page not found", -2)
		      doc = New HTTPDocument(404, ClientRequest.Path)
		      
		    ElseIf item.Directory And Not Me.DirectoryBrowsing Then
		      '403 Forbidden!
		      Me.Log("Page is directory and DirectoryBrowsing=False", -2)
		      doc = New HTTPDocument(403, ClientRequest.Path)
		      
		    ElseIf ClientRequest.Path = "/" And Not item.Directory Then
		      '302 redirect from "/" to "/" + item.name
		      doc = New HTTPDocument(302, ClientRequest.Path)
		      doc.Headers.SetHeader("Location", "http://" + Me.LocalAddress + ":" + Format(Me.Port, "######") + "/" + Item.Name)
		    Else
		      '200 OK
		      Me.Log("Found page", -2)
		      doc = New HTTPDocument(item, ClientRequest.Path)
		    End If
		    
		  Case RequestMethod.POST, RequestMethod.TRACE, RequestMethod.DELETE, RequestMethod.PUT, RequestMethod.InvalidMethod
		    
		    doc = New HTTPDocument(405, ClientRequest.MethodName)
		    
		  Else
		    doc = New HTTPDocument(400, ClientRequest.MethodName)
		    
		  End Select
		  
		  doc.Method = ClientRequest.Method
		  Return doc
		  
		End Function
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function FindItem(Path As String) As FolderItem
		  Path = Path.ReplaceAll("/", "\")
		  
		  If Not Document.Directory And "\" + Document.Name = path Then
		    Return Document
		  End If
		  
		  Path = ReplaceAll(Document.AbsolutePath + Path, "\\", "\")
		  Dim item As FolderItem = GetTrueFolderItem(Path, FolderItem.PathTypeAbsolute)
		  
		  If item <> Nil And item.Exists Then
		    Return item
		  End If
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		DirectoryBrowsing As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		Document As FolderItem
	#tag EndProperty


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
			InheritedFrom="HTTPDaemon"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AuthenticationRequired"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			InheritedFrom="HTTPDaemon"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DigestAuthenticationOnly"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			InheritedFrom="HTTPDaemon"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DirectoryBrowsing"
			Visible=true
			Group="Behavior"
			InitialValue="True"
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
			InheritedFrom="HTTPDaemon"
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
