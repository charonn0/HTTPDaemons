#tag Class
Protected Class JSONRPC
Inherits HTTPDaemon
	#tag Event
		Sub HandleRequest(ClientRequest As Request)
		  Dim js As JSONItem
		  Dim data As String = ClientRequest.PostContent
		  js = New JSONItem(data)
		  RPCMessage(js, ClientRequest.Headers, ClientRequest.Method)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub SendRPCOutput(Output As JSONItem)
		  Output.Compact = True
		  Dim doc As New JSONResponse(Output.ToString, "text/json")
		  doc.StatusCode = 200
		  Me.SendResponse(doc)
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event RPCMessage(Message As JSONItem, Headers As HTTPHeaders, HTTPMethod As RequestMethod)
	#tag EndHook


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
