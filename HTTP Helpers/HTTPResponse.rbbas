#tag Class
Protected Class HTTPResponse
	#tag Method, Flags = &h0
		Sub Constructor(Data As String, AuthRealm As String = "Restricted Content", RequireDigestAuth As Boolean = False)
		  Dim body As Integer = InStr(data, CRLF + CRLF)
		  Me.MessageBody = Right(data, data.Len - body)
		  'NthField(data, CRLF + CRLF, 2)
		  data = Replace(data, Me.MessageBody, "").Trim
		  Dim line As String
		  line = NthField(data, CRLF, 1)
		  data = Replace(data, line + CRLF, "")
		  data = Replace(data, Me.MessageBody, "")
		  Me.Headers = New HTTPHeaders(data)
		  Me.Method = NthField(line, " ", 1).Trim
		  Me.ProtocolVersion = CDbl(Replace(NthField(line, " ", 1).Trim, "HTTP/", ""))
		  Me.StatusCode = Val(NthField(line, " ", 2))
		  Me.StatusMessage = HTTPCodeToMessage(Me.StatusCode)
		  Me.AuthRealm = AuthRealm
		  Me.AuthSecure = RequireDigestAuth
		  If Headers.GetHeader("Content-Encoding") = "gzip" Then
		    Me.GZipped = True
		    #If GZIPAvailable Then
		      Dim size As Integer = Val(Headers.GetHeader("Content-Length"))
		      Me.MessageBody = GZip.Uncompress(Me.MessageBody, size^2)
		    #endif
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString() As String
		  Dim data As String = Me.MessageBody
		  #If GZIPAvailable Then
		    If Me.GZipped Then
		      data = GZipPage(data)
		    End If
		  #endif
		  
		  Return HTTPResponse(Me.StatusCode) + CRLF + Me.Headers.Source + CRLF + CRLF + data
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		AuthRealm As String
	#tag EndProperty

	#tag Property, Flags = &h0
		AuthSecure As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		GZipped As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Headers As HTTPHeaders
	#tag EndProperty

	#tag Property, Flags = &h0
		MessageBody As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Method As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Modified As Date
	#tag EndProperty

	#tag Property, Flags = &h0
		Path As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ProtocolVersion As Single
	#tag EndProperty

	#tag Property, Flags = &h0
		StatusCode As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		StatusMessage As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="AuthRealm"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AuthSecure"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="GZipped"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MessageBody"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Method"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Path"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ProtocolVersion"
			Group="Behavior"
			Type="Single"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StatusCode"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StatusMessage"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
