#tag Class
Protected Class Cookie
Inherits Pair
	#tag Method, Flags = &h1000
		Sub Constructor(left As Variant, right As Variant)
		  // Calling the overridden superclass constructor.
		  Super.Constructor(left, right)
		  Me.Expiry = New Date
		  Me.Expiry.TotalSeconds = Me.Expiry.TotalSeconds + 3600 '1 hr
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Expires() As Date
		  Return Me.Expiry
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Expires(Assigns NewDate As String)
		  Me.Expiry = HTTPDate(NewDate)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Name() As String
		  Return Me.Left.StringValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value() As String
		  Return Me.Right.StringValue
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected Expiry As Date
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
