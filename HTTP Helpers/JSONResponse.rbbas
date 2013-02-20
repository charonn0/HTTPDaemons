#tag Class
Protected Class JSONResponse
Inherits Document
	#tag Method, Flags = &h0
		Sub Constructor(PageSource As String, MIME As String = "text/html")
		  Me.Pagedata = PageSource
		  Me.Headers.SetHeader("Content-Type", MIME)
		End Sub
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="FromCache"
			Group="Behavior"
			Type="Boolean"
			InheritedFrom="Document"
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
			Name="Pagedata"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="Document"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Path"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="Document"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StatusCode"
			Group="Behavior"
			Type="Integer"
			InheritedFrom="Document"
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
