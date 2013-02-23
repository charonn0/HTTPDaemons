#tag Class
Protected Class URLShortener
Inherits HTTPDaemon
	#tag Event
		Sub HandleRequest(ClientRequest As Request)
		  Dim doc As Document
		  
		  Select Case ClientRequest.Method
		  Case RequestMethod.GET
		    If ClientRequest.Path = "/Create" Then
		      doc = New Document(200, ClientRequest.Path)
		      doc.Pagedata = NEWURLPAGE
		    Else
		      doc = ClickShortURL(ClientRequest.Path)
		    End If
		    
		  Case RequestMethod.POST
		    Dim formdata As Dictionary = DecodeFormData(ClientRequest.PostContent)
		    doc = CreateShortURL(formdata.Value("ShortName"), formdata.Value("URL"))
		    
		  Else
		    
		  End Select
		  
		  Me.SendResponse(doc)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		 Shared Function ClickShortURL(ShortPath As String) As Document
		  Dim doc As Document
		  If Left(Shortpath, 1) = "/" Then Shortpath = Replace(Shortpath, "/", "")
		  If URLDB.HasKey(Shortpath) Then
		    doc = URLDB.Value(Shortpath)
		    
		  Else
		    doc = New Document(404, ShortPath)
		  End If
		  
		  Return doc
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  // Note that this may need modifications if there are multiple constructor choices.
		  // Possible constructor calls:
		  // Constructor() -- From TCPSocket
		  // Constructor() -- From SocketCore
		  Super.Constructor
		  Me.AddRedirect(New Document("/", "/Create"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CreateShortURL(ShortPath As String, Location As String) As Document
		  URLDB.Value(ShortPath) = New Document(ShortPath, Location)
		  Return URLDB.Value(ShortPath)
		End Function
	#tag EndMethod


	#tag Constant, Name = NEWURLPAGE, Type = String, Dynamic = False, Default = \"<html>\r\t<head>\r\t\t<title>HTML Online Editor Sample</title>\r\t</head>\r\t<body>\r\t\t<form action\x3D\"/Create\" enctype\x3D\"application/x-www-form-urlencoded\" id\x3D\"URLs\" method\x3D\"post\" name\x3D\"URLs\" target\x3D\"_self\">\r\t\t\t<br />\r\t\t\t<input maxlength\x3D\"25\" name\x3D\"ShortName\" size\x3D\"25\" type\x3D\"text\" />&nbsp; <input maxlength\x3D\"255\" name\x3D\"URL\" size\x3D\"50\" type\x3D\"text\" value\x3D\"http://\" /> <input name\x3D\"Submit\" type\x3D\"submit\" value\x3D\"Shorten\" />&nbsp;</form>\r\t</body>\r</html>", Scope = Public
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
