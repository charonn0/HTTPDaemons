#tag Class
Protected Class RBScriptDocument
Inherits HTTPResponse
	#tag Event
		Function TamperMessageBody(ByRef Data As String) As Boolean
		  Document = Data
		  Runtime = New RbScript
		  Runtime.Source = Me.ScriptSource
		  Runtime.Context = Me
		  Runtime.Run
		  Data = Document
		  Return True
		End Function
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor(Path As String)
		  Dim f As FolderItem = GetTemporaryFolderItem()
		  Super.Constructor(f, Path)
		  Me.StatusCode = 200
		  Me.Modified = New Date
		  Me.Path = Path
		  Me.Expires = New Date
		  Me.Expires.TotalSeconds = Me.Expires.TotalSeconds + 60
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetHeader(Index As Integer) As String
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetHeader(Name As String) As String
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetHeaderName(Index As Integer) As String
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function HeaderCount() As Integer
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetHeader(Name As String, Value As String)
		  Super.SetHeader(Name, Value)
		End Sub
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If Headers.HasHeader("Content-Type") Then
			    return Headers.Value("Content-Type")
			  End If
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Headers.SetHeader("Content-Type", value)
			End Set
		#tag EndSetter
		ContentType As String
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private Document As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Runtime As RbScript
	#tag EndProperty

	#tag Property, Flags = &h0
		ScriptSource As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="AuthRealm"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="HTTPResponse"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AuthSecure"
			Group="Behavior"
			Type="Boolean"
			InheritedFrom="HTTPResponse"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ContentType"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FromCache"
			Group="Behavior"
			Type="Boolean"
			InheritedFrom="HTTPResponse"
		#tag EndViewProperty
		#tag ViewProperty
			Name="GZipped"
			Group="Behavior"
			Type="Boolean"
			InheritedFrom="HTTPResponse"
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
			InheritedFrom="HTTPResponse"
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
			InheritedFrom="HTTPResponse"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ProtocolVersion"
			Group="Behavior"
			Type="Single"
			InheritedFrom="HTTPResponse"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ScriptSource"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StatusCode"
			Group="Behavior"
			Type="Integer"
			InheritedFrom="HTTPResponse"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StatusMessage"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="HTTPResponse"
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
