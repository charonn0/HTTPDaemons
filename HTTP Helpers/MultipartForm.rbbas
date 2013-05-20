#tag Class
Protected Class MultipartForm
	#tag Method, Flags = &h0
		Sub AddFile(File As FolderItem)
		  Files.Append(File)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddFormElement(ElementName As String, ElementValue As String)
		  FormElements.Value(ElementName) = ElementValue
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function FromData(Data As String) As MultipartForm
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString() As String
		  Dim data As String
		  For Each key As String In FormElements.Keys
		    data = data + Me.Boundary + CRLF
		    data = data + "Content-Disposition: form-data; name=""" + key + """" + CRLF + CRLF
		    data = data + FormElements.Value(key) + CRLF
		  Next
		  
		  For i As Integer = 0 To UBound(Me.Files)
		    data = data + Me.Boundary + CRLF
		    data = data + "Content-Disposition: form-data; name=""file" + Str(i) + """; filename=""" + Me.Files(i).Name + """" + CRLF
		    data = data + "Content-Type: " + MIMEstring(Me.Files(i).Name) + CRLF + CRLF
		    Dim bs As BinaryStream = BinaryStream.Open(Me.Files(i))
		    data = data + bs.Read(bs.Length) + CRLF
		  Next
		  data = data + Me.Boundary + "--" + CRLF
		  
		  Return data
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Boundary As String = "--bOrEdOmSoFtBoUnDaRy"
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Files() As FolderItem
	#tag EndProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  If mFormElements = Nil Then mFormElements = New Dictionary
			  return mFormElements
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mFormElements = value
			End Set
		#tag EndSetter
		Protected FormElements As Dictionary
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mFormElements As Dictionary
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Boundary"
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
