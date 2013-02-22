#tag Class
Protected Class URLShortener
Inherits HTTPDaemon
	#tag Event
		Sub Connected()
		  Me.AddRedirect(New Document("/", "/Create"))
		End Sub
	#tag EndEvent

	#tag Event
		Sub HandleRequest(ClientRequest As Request)
		  Dim doc As Document
		  
		  Select Case ClientRequest.Method
		  Case RequestMethod.GET
		    If ClientRequest.Path = "/Create" Then
		      doc = New Document(200, ClientRequest.Path)
		      doc.Pagedata = NEWURLPAGE
		    Else
		      doc = ClickSavedURL(ClientRequest.Path)
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
		 Shared Function ClickSavedURL(ShortPath As String) As Document
		  Dim doc As Document
		  Dim rs As RecordSet = URLDB.SQLSelect("SELECT Address, Clicks FROM urls WHERE Keyword='" + Replace(ShortPath, "/", "") + "'")
		  If rs.RecordCount > 0 Then
		    doc = New Document(ShortPath, rs.Field("Address").StringValue)
		    rs.Edit
		    rs.Field("Clicks").IntegerValue = rs.Field("Clicks").IntegerValue + 1
		    rs.Update()
		    URLDB.Commit
		    
		  Else
		    doc = New Document(404, ShortPath)
		  End If
		  
		  Return doc
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CreateShortURL(ShortPath As String, Location As String) As Document
		  Dim doc As Document
		  Dim rs As RecordSet = URLDB.SQLSelect("SELECT Address, Clicks FROM urls WHERE Keyword='" + Replace(ShortPath, "/", "") + "'")
		  If rs.RecordCount <= 0 Then
		    Dim dr As New DatabaseRecord
		    dr.Column("CreatorIP") = Me.RemoteAddress
		    dr.IntegerColumn("Clicks") = 0
		    dr.Column("Keyword") = Replace(ShortPath, "/", "")
		    dr.Column("Address") = Location
		    dr.DateColumn("CreationDate") = New Date
		    URLDB.InsertRecord("urls", dr)
		    URLDB.Commit
		    
		    doc = New Document(ShortPath, Location)
		    
		  Else
		    doc = New Document("/", "/Create?Success=True")
		  End If
		  
		  Return doc
		End Function
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


	#tag Property, Flags = &h21
		Private Shared mURLDB As REALSQLDatabase
	#tag EndProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  If mURLDB = Nil Then
			    mURLDB = New REALSQLDatabase
			    mURLDB.DatabaseFile = SpecialFolder.Desktop.Child("urls.db") 'CHANGE ME
			    If Not mURLDB.Connect Then
			      Raise New RuntimeException
			    End If
			  End If
			  return mURLDB
			End Get
		#tag EndGetter
		Protected Shared URLDB As REALSQLDatabase
	#tag EndComputedProperty


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
