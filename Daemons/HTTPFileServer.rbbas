#tag Class
Protected Class HTTPFileServer
Inherits HTTPDaemon
	#tag Event
		Sub Connected()
		  Me.KeepListening = True
		End Sub
	#tag EndEvent

	#tag Event
		Sub HandleRequest(ClientRequest As Request)
		  Dim doc As Document 'The response object
		  Dim item As FolderItem = FindItem(ClientRequest.Path)
		  
		  Select Case ClientRequest.Method
		  Case RequestMethod.GET, RequestMethod.HEAD
		    If IsCached(ClientRequest) Then
		      'Cache hit
		      Dim cache As Document = PageCache.Value(ClientRequest.Path)
		      doc = New Document(cache, ClientRequest.Path)
		      doc.FromCache = True
		      Me.Log("Page from cache", -2)
		      
		    ElseIf item = Nil Then
		      '404 Not found
		      Me.Log("Page not found", -2)
		      doc = New Document(404, ClientRequest.Path)
		      
		    ElseIf item.Directory And Not Me.DirectoryBrowsing Then
		      '403 Forbidden!
		      Me.Log("Page is directory and DirectoryBrowsing=False", -2)
		      doc = New Document(403, ClientRequest.Path)
		      
		    ElseIf ClientRequest.Path = "/" And Not item.Directory Then
		      '302 redirect from "/" to "/" + item.name
		      doc = New Document(302, ClientRequest.Path)
		      doc.Headers.SetHeader("Location", "http://" + Me.LocalAddress + ":" + Format(Me.Port, "######") + "/" + Item.Name)
		    Else
		      '200 OK
		      Me.Log("Found page", -2)
		      doc = New Document(item, ClientRequest.Path)
		    End If
		    
		  Case RequestMethod.POST
		    doc = New Document(405, ClientRequest.MethodName)
		    
		  Case RequestMethod.TRACE
		    doc = New Document(405, ClientRequest.MethodName)
		    
		  Case RequestMethod.DELETE, RequestMethod.PUT
		    doc = New Document(405, ClientRequest.MethodName)
		    
		  Else
		    doc = New Document(400, ClientRequest.MethodName)
		    
		  End Select
		  
		  If doc <> Nil Then
		    doc.Method = ClientRequest.Method
		    Me.SendResponse(doc)
		  End If
		End Sub
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
			Name="AuthType"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType="Enum"
			InheritedFrom="HTTPDaemon"
			#tag EnumValues
				"0 - None"
				"1 - Basic"
				"2 - Digest"
			#tag EndEnumValues
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
