#tag Class
Protected Class Request
	#tag Method, Flags = &h0
		Sub Constructor(Data As String)
		  Dim line, verb As String
		  line = NthField(data, CRLF, 1)
		  data = Replace(data, line + CRLF, "")
		  Me.PostContent = NthField(data, CRLF + CRLF, 2)
		  data = Replace(data, Me.PostContent, "")
		  Me.Headers = New HTTPHeaders(data)
		  verb = NthField(line, " ", 1).Trim
		  Select Case verb
		  Case "GET"
		    Me.Method = RequestMethod.GET
		  Case "HEAD"
		    Me.Method = RequestMethod.HEAD
		  Case "TRACE"
		    Me.Method = RequestMethod.TRACE
		  Case "DELETE"
		    Me.Method = RequestMethod.DELETE
		  Case "POST"
		    Me.Method = RequestMethod.POST
		  Case "PUT"
		    Me.Method = RequestMethod.PUT
		  End Select
		  
		  Me.Path = URLDecode(NthField(line, " ", 2).Trim)
		  Me.ProtocolVersion = CDbl(Replace(NthField(line, " ", 3).Trim, "HTTP/", ""))
		  Me.Cookies = Me.Headers.GetCookies
		  Me.Expiry = New Date
		  Me.Expiry.TotalSeconds = Me.Expiry.TotalSeconds + 60
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MethodName() As String
		  Select Case Me.Method
		  Case RequestMethod.GET
		    Return "GET"
		    
		  Case RequestMethod.DELETE
		    Return "DELETE"
		    
		  Case RequestMethod.HEAD
		    Return "HEAD"
		    
		  Case RequestMethod.POST
		    Return "POST"
		    
		  Case RequestMethod.PUT
		    Return "PUT"
		    
		  Case RequestMethod.TRACE
		    Return "TRACE"
		    
		  Else
		    Return "UNKNOWN"
		  End Select
		  
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Cookies() As Cookie
	#tag EndProperty

	#tag Property, Flags = &h0
		Expiry As Date
	#tag EndProperty

	#tag Property, Flags = &h0
		Headers As HTTPHeaders
	#tag EndProperty

	#tag Property, Flags = &h0
		Method As RequestMethod
	#tag EndProperty

	#tag Property, Flags = &h0
		Path As String
	#tag EndProperty

	#tag Property, Flags = &h0
		PostContent As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ProtocolVersion As Single
	#tag EndProperty


	#tag ViewBehavior
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
			Name="PostContent"
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
