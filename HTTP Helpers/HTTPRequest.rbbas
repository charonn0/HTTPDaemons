#tag Class
Protected Class HTTPRequest
	#tag Method, Flags = &h0
		Sub Constructor(Method As String)
		  Select Case Method
		  Case "GET"
		    Me.Method = HTTP.RequestMethod.GET
		    mTrueMethodName = "GET"
		  Case "HEAD"
		    Me.Method = HTTP.RequestMethod.HEAD
		    mTrueMethodName = "HEAD"
		  Case "DELETE"
		    Me.Method = HTTP.RequestMethod.DELETE
		    mTrueMethodName = "DELETE"
		  Case "POST"
		    Me.Method = HTTP.RequestMethod.POST
		    mTrueMethodName = "POST"
		  Case "PUT"
		    Me.Method = HTTP.RequestMethod.PUT
		    mTrueMethodName = "PUT"
		  Case "TRACE"
		    Me.Method = HTTP.RequestMethod.TRACE
		    mTrueMethodName = "TRACE"
		  Else
		    Me.Method = HTTP.RequestMethod.InvalidMethod
		    mTrueMethodName = Method
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Data As String, AuthRealm As String, RequireDigestAuth As Boolean)
		  Dim line As String
		  line = NthField(data, CRLF, 1)
		  data = Replace(data, line + CRLF, "")
		  Me.PostContent = NthField(data, CRLF + CRLF, 2)
		  data = Replace(data, Me.PostContent, "")
		  Me.Headers = New HTTPHeaders(data)
		  Me.Constructor(NthField(line, " ", 1).Trim)
		  
		  Me.Path = URLDecode(NthField(line, " ", 2).Trim)
		  Dim tmp As String = NthField(Me.Path, "?", 2)
		  path = Replace(path, "?" + tmp, "")
		  Me.Arguments = Split(tmp, "&")
		  Me.ProtocolVersion = CDbl(Replace(NthField(line, " ", 3).Trim, "HTTP/", ""))
		  Me.Expiry = New Date
		  Me.Expiry.TotalSeconds = Me.Expiry.TotalSeconds + 60
		  Me.AuthDigest = RequireDigestAuth
		  Me.AuthRealm = AuthRealm
		  Dim pw As String = Me.Headers.GetHeader("Authorization")
		  If Not Me.AuthDigest Then
		    pw = pw.Replace("Basic ", "")
		    pw = DecodeBase64(pw)
		    Me.AuthPassword = NthField(pw, ":", 2)
		    Me.AuthUsername = NthField(pw, ":", 1)
		    
		  Else
		    #pragma Warning "FixMe"
		    
		    
		    
		  End If
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
		    Return Me.TrueMethodName
		  End Select
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString() As String
		  Dim data As String = TrueMethodName + " " + Path + " " + "HTTP/" + Format(ProtocolVersion, "#.0") + CRLF
		  If Headers.Count > 0 Then
		    data = data + Headers.Source + CRLF
		  End If
		  data = data + CRLF + PostContent.Trim
		  
		  Return data
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Arguments() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		AuthDigest As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h0
		AuthPassword As String
	#tag EndProperty

	#tag Property, Flags = &h0
		AuthRealm As String
	#tag EndProperty

	#tag Property, Flags = &h0
		AuthUsername As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Cookies() As HTTPCookie
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

	#tag Property, Flags = &h21
		Private mTrueMethodName As String
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

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mTrueMethodName
			End Get
		#tag EndGetter
		TrueMethodName As String
	#tag EndComputedProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="AuthDigest"
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AuthPassword"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AuthRealm"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AuthUsername"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
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
		#tag ViewProperty
			Name="TrueMethodName"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
