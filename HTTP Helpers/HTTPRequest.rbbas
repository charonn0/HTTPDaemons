#tag Class
Protected Class HTTPRequest
	#tag Method, Flags = &h0
		Sub Constructor()
		  'Construct an empty HTTPRequest
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Data As String, AuthRealm As String, RequireDigestAuth As Boolean)
		  Dim line As String
		  line = NthField(data, CRLF, 1)
		  
		  If CountFields(line.Trim, " ") <> 3 Then
		    Raise New UnsupportedFormatException
		  End If
		  
		  data = Replace(data, line + CRLF, "")
		  Dim h As String = NthField(data, CRLF + CRLF, 1)
		  Me.Headers = New HTTPHeaders(h)
		  Me.MessageBody = Replace(data, h, "")
		  If Me.Headers.HasHeader("Content-Type") Then
		    Dim type As String = Me.Headers.GetHeader("Content-Type")
		    If InStr(type, "multipart/form-data") > 0 Then
		      Dim boundary As String = NthField(type, "boundary=", 2).Trim
		      Me.MultiPart = MultipartForm.FromData(Me.MessageBody, boundary)
		    End If
		  End If
		  
		  Me.Method = HTTP.HTTPMethod(NthField(line, " ", 1).Trim)
		  If Me.Method = RequestMethod.InvalidMethod Then mTrueMethodName = NthField(line, " ", 1).Trim
		  
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
		  If Me.Method <> RequestMethod.InvalidMethod Then
		    Return HTTPMethodName(Me.Method)
		  Else
		    Return mTrueMethodName
		  End If
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MethodName(Assigns Name As String)
		  Me.Method = HTTPMethod(Name)
		  mTrueMethodName = Name
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString() As String
		  Dim args As String
		  If Me.Arguments.Ubound > -1 Then
		    args = "?" + Join(Me.Arguments, "&")
		  End If
		  Dim data As String = MethodName + " " + URLEncode(Path) + URLEncode(args) + " " + "HTTP/" + Format(ProtocolVersion, "#.0") + CRLF
		  If Me.MultiPart <> Nil Then
		    Me.Headers.SetHeader("Content-Type", "multipart/form-data; boundary=" + Me.MultiPart.Boundary)
		    Me.MessageBody = Me.MultiPart.ToString
		    Me.Headers.SetHeader("Content-Length", Str(Me.MessageBody.LenB))
		  End If
		  If Headers.Count > 0 Then
		    data = data + Headers.Source + CRLF
		  End If
		  data = data + CRLF + MessageBody.Trim
		  
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
		MessageBody As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mMethod
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mMethod = value
			  
			  Select Case Me.Method
			  Case RequestMethod.GET
			    mTrueMethodName = "GET"
			    
			  Case RequestMethod.DELETE
			    mTrueMethodName = "DELETE"
			    
			  Case RequestMethod.HEAD
			    mTrueMethodName = "HEAD"
			    
			  Case RequestMethod.POST
			    mTrueMethodName = "POST"
			    
			  Case RequestMethod.PUT
			    mTrueMethodName = "PUT"
			    
			  Case RequestMethod.TRACE
			    mTrueMethodName = "TRACE"
			    
			  Case RequestMethod.OPTIONS
			    mTrueMethodName = "OPTIONS"
			    
			  End Select
			  
			  
			End Set
		#tag EndSetter
		Method As RequestMethod
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mMethod As RequestMethod
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTrueMethodName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		MultiPart As MultipartForm
	#tag EndProperty

	#tag Property, Flags = &h0
		Path As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ProtocolVersion As Single
	#tag EndProperty


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
			Name="MessageBody"
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
