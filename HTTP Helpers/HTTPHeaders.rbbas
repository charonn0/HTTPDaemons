#tag Class
Protected Class HTTPHeaders
Inherits InternetHeaders
	#tag Method, Flags = &h1000
		Sub Constructor(Data As String)
		  // Calling the overridden superclass constructor.
		  Super.Constructor
		  Dim lines() As String = data.Split(CRLF)
		  
		  For i As Integer = 0 To UBound(lines)
		    Dim line As String = lines(i)
		    If Instr(line, ": ") <= 1  Or line.Trim = "" Then Continue
		    Me.AppendHeader(NthField(line, ": ", 1), NthField(line, ": ", 2))
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Copy(CopyTo As HTTPHeaders)
		  Dim lines() As String = Me.Source.Split(CRLF)
		  If CopyTo = Nil Then CopyTo = New HTTPHeaders
		  For i As Integer = 0 To UBound(lines)
		    Dim line As String = lines(i)
		    If Instr(line, ": ") <= 1  Or line.Trim = "" Then Continue
		    CopyTo.AppendHeader(NthField(line, ": ", 1), NthField(line, ": ", 2))
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetCookies() As Cookie()
		  'Returns a string array of all HTTP cookies
		  Dim cookies() As Cookie
		  Dim head As String = Me.GetHeader("Cookie")
		  Dim c() As String = Split(head, ";")
		  For Each cook As String In c
		    Dim l, r As String
		    l = NthField(cook, "=", 1).Trim
		    r = NthField(cook, "=", 2).Trim
		    cookies.Append(New Cookie(l, r))
		  Next
		  
		  Return cookies
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetHeader(Headername As String) As String
		  For i As Integer = 0 To Me.Count - 1
		    If Me.Name(i) = headername Then
		      Return Me.Value(i)
		    End If
		  Next
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasHeader(HeaderName As String) As Boolean
		  For i As Integer = 0 To Me.Count - 1
		    If Me.Name(i) = HeaderName Then Return True
		  Next
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetCookie(c As Cookie)
		  Dim data As String
		  If Me.HasHeader("Set-Cookie") Then
		    data = Me.Value("Set-Cookie") + ";" + c.Name + "=" + c.Right
		  Else
		    data = c.Name + "=" + c.Right
		  End If
		  Me.SetHeader("Set-Cookie", data)
		End Sub
	#tag EndMethod


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
