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
		  Me.Log(ClientRequest.MethodName + " " + ClientRequest.Path + " " + "HTTP/" + Format(ClientRequest.ProtocolVersion, "#.0"), 0)
		  Me.Log(ClientRequest.Headers.Source, -1)
		  
		  Dim doc As HTMLDocument
		  Select Case ClientRequest.Method
		  Case RequestMethod.GET
		    Dim item As FolderItem = FindItem(ClientRequest.Path)
		    If PageCache.HasKey(ClientRequest.Path) And UseCache Then
		      Dim cache As HTMLDocument = PageCache.Value(ClientRequest.Path)
		      doc = New HTMLDocument(cache, ClientRequest.Path)
		      
		    ElseIf item = Nil Then
		      doc = New HTMLDocument(404, ClientRequest.Path)
		      
		    ElseIf item.Directory And Not Me.DirectoryBrowsing Then
		      doc = New HTMLDocument(403, ClientRequest.Path)
		      
		    Else
		      doc = New HTMLDocument(item, ClientRequest.Path)
		    End If
		    PageCache.Value(ClientRequest.Path) = doc
		    
		  Case RequestMethod.HEAD
		    Dim item As FolderItem = FindItem(ClientRequest.Path)
		    If item = Nil Then
		      doc = New HTMLDocument(404, ClientRequest.Path)
		    Else
		      doc = New HTMLDocument(item, ClientRequest.Path)
		    End If
		    doc.Pagedata = ""
		    
		  Case RequestMethod.POST
		    
		  Case RequestMethod.TRACE
		    
		  Case RequestMethod.DELETE, RequestMethod.PUT
		    doc = New HTMLDocument(405, ClientRequest.MethodName)
		    doc.Pagedata = ""
		  Else
		    doc = New HTMLDocument(400, ClientRequest.MethodName)
		    doc.Pagedata = ""
		  End Select
		  
		  If doc <> Nil Then
		    Me.SendResponse(doc)
		  End If
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub CacheCleaner(Sender As Timer)
		  #pragma Unused Sender
		  PageCache = New Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FindItem(Path As String) As FolderItem
		  Dim s As String
		  Path = Path.ReplaceAll("/", "\")
		  
		  If Not Document.Directory And "\" + Document.Name = path Then
		    Return Document
		  End If
		  
		  s = ReplaceAll(Document.AbsolutePath + Path, "\\", "\")
		  Dim item As FolderItem = GetTrueFolderItem(s, FolderItem.PathTypeAbsolute)
		  If item <> Nil And item.Exists Then
		    Return item
		  End If
		  
		Exception Err
		  If Err IsA EndException Or Err IsA ThreadEndException Then Raise Err
		  ReRaise(Err)
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		CachePeriod As Integer = 1200000
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CacheTimer As Timer
	#tag EndProperty

	#tag Property, Flags = &h0
		DirectoryBrowsing As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		Document As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared mPageCache As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUseCache As Boolean = True
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
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
		Shared PageCache As Dictionary
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mUseCache And Not GZIPAvailable
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value Then
			    CacheTimer = New Timer
			    CacheTimer.Period = Me.CachePeriod
			    AddHandler CacheTimer.Action, AddressOf CacheCleaner
			    CacheTimer.Mode = Timer.ModeMultiple
			  Else
			    CacheTimer = Nil
			    
			  End If
			  mUseCache = value
			End Set
		#tag EndSetter
		UseCache As Boolean
	#tag EndComputedProperty


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
