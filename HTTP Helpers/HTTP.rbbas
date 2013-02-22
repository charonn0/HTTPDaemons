#tag Module
Protected Module HTTP
	#tag Method, Flags = &h0
		Function CRLF() As String
		  Return EndOfLine.Windows
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FormatBytes(bytes As UInt64, precision As Integer = 2) As String
		  'Converts raw byte counts into SI formatted strings. 1KB = 1024 bytes.
		  'Optionally pass an integer representing the number of decimal places to return. The default is two decimal places. You may specify
		  'between 0 and 16 decimal places. Specifying more than 16 will append extra zeros to make up the length. Passing 0
		  'shows no decimal places and no decimal point.
		  
		  Const kilo = 1024
		  Static mega As UInt64 = kilo * kilo
		  Static giga As UInt64 = kilo * mega
		  Static tera As UInt64 = kilo * giga
		  Static peta As UInt64 = kilo * tera
		  Static exab As UInt64 = kilo * peta
		  
		  Dim suffix, precisionZeros As String
		  Dim strBytes As Double
		  
		  
		  If bytes < kilo Then
		    strbytes = bytes
		    suffix = "bytes"
		  ElseIf bytes >= kilo And bytes < mega Then
		    strbytes = bytes / kilo
		    suffix = "KB"
		  ElseIf bytes >= mega And bytes < giga Then
		    strbytes = bytes / mega
		    suffix = "MB"
		  ElseIf bytes >= giga And bytes < tera Then
		    strbytes = bytes / giga
		    suffix = "GB"
		  ElseIf bytes >= tera And bytes < peta Then
		    strbytes = bytes / tera
		    suffix = "TB"
		  ElseIf bytes >= tera And bytes < exab Then
		    strbytes = bytes / peta
		    suffix = "PB"
		  ElseIf bytes >= exab Then
		    strbytes = bytes / exab
		    suffix = "EB"
		  End If
		  
		  
		  While precisionZeros.Len < precision
		    precisionZeros = precisionZeros + "0"
		  Wend
		  If precisionZeros.Trim <> "" Then precisionZeros = "." + precisionZeros
		  
		  Return Format(strBytes, "#,###0" + precisionZeros) + suffix
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HTTPDate(d As Date) As String
		  Dim dt As String
		  d.GMTOffset = 0
		  Select Case d.DayOfWeek
		  Case 1
		    dt = dt + "Sun, "
		  Case 2
		    dt = dt + "Mon, "
		  Case 3
		    dt = dt + "Tue, "
		  Case 4
		    dt = dt + "Wed, "
		  Case 5
		    dt = dt + "Thu, "
		  Case 6
		    dt = dt + "Fri, "
		  Case 7
		    dt = dt + "Sat, "
		  End Select
		  
		  dt = dt  + Format(d.Day, "00") + " "
		  
		  Select Case d.Month
		  Case 1
		    dt = dt + "Jan "
		  Case 2
		    dt = dt + "Feb "
		  Case 3
		    dt = dt + "Mar "
		  Case 4
		    dt = dt + "Apr "
		  Case 5
		    dt = dt + "May "
		  Case 6
		    dt = dt + "Jun "
		  Case 7
		    dt = dt + "Jul "
		  Case 8
		    dt = dt + "Aug "
		  Case 9
		    dt = dt + "Sep "
		  Case 10
		    dt = dt + "Oct "
		  Case 11
		    dt = dt + "Nov "
		  Case 12
		    dt = dt + "Dec "
		  End Select
		  
		  dt = dt  + Format(d.Year, "0000") + " " + Format(d.Hour, "00") + ":" + Format(d.Minute, "00") + ":" + Format(d.Second, "00") + " GMT"
		  Return dt
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HTTPDate(Data As String) As Date
		  
		  'Sat, 29 Oct 1994 19:43:31 GMT
		  
		  Dim d As Date
		  Dim members() As String = Split(Data, " ")
		  If UBound(members) = 5 Then
		    Dim dom, mon, year, h, m, s, tz As Integer
		    
		    dom = Val(members(1))
		    
		    Select Case members(2)
		    Case "Jan"
		      mon = 1
		    Case "Feb"
		      mon = 2
		    Case "Mar"
		      mon = 3
		    Case "Apr"
		      mon = 4
		    Case "May"
		      mon = 5
		    Case "Jun"
		      mon = 6
		    Case "Jul"
		      mon = 7
		    Case "Aug"
		      mon = 8
		    Case "Sep"
		      mon = 9
		    Case "Oct"
		      mon = 10
		    Case "Nov"
		      mon = 11
		    Case "Dec"
		      mon = 12
		    End Select
		    
		    year = Val(members(3))
		    
		    Dim time As String = members(4)
		    h = Val(NthField(time, ":", 1))
		    m = Val(NthField(time, ":", 2))
		    s = Val(NthField(time, ":", 3))
		    tz = Val(members(5))
		    
		    
		    
		    d = New Date(year, mon, dom, h, m, s, tz)
		  End If
		  Return d
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HTTPResponse(Code As Integer) As String
		  'Returns the properly formatted HTTP response line for a given HTTP status code.
		  'e.g. HTTPResponse(404) = "HTTP/1.1 404 Not Found"
		  
		  Dim msg As String
		  
		  Select Case Code
		  Case 100
		    msg = "Continue"
		    
		  Case 101
		    msg = "Switching Protocols"
		    
		  Case 102
		    msg = "Processing"
		    
		  Case 200
		    msg = "OK"
		    
		  Case 201
		    msg = "Created"
		    
		  Case 202
		    msg = "Accepted"
		    
		  Case 203
		    msg = "Non-Authoritative Information"
		    
		  Case 204
		    msg = "No Content"
		    
		  Case 205
		    msg = "Reset Content"
		    
		  Case 206
		    msg = "Partial Content"
		    
		  Case 207
		    msg = "Multi-Status"
		    
		  Case 208
		    msg = "Already Reported"
		    
		    
		  Case 226
		    msg = "IM Used"
		    
		  Case 300
		    msg = "Multiple Choices"
		    
		  Case 301
		    msg = "Moved Permanently"
		    
		  Case 302
		    msg = "Found"
		    
		  Case 303
		    msg = "See Other"
		    
		  Case 304
		    msg = "Not Modified"
		    
		  Case 305
		    msg = "Use Proxy"
		    
		  Case 306
		    msg = "Switch Proxy"
		    
		  Case 307
		    msg = "Temporary Redirect"
		    
		  Case 308 ' https://tools.ietf.org/html/draft-reschke-http-status-308-07
		    msg = "Permanent Redirect"
		    
		  Case 400
		    msg = "Bad Request"
		    
		  Case 401
		    msg = "Unauthorized"
		    
		  Case 403
		    msg = "Forbidden"
		    
		  Case 404
		    msg = "Not Found"
		    
		  Case 405
		    msg = "Method Not Allowed"
		    
		  Case 406
		    msg = "Not Acceptable"
		    
		  Case 407
		    msg = "Proxy Authentication Required"
		    
		  Case 408
		    msg = "Request Timeout"
		    
		  Case 409
		    msg = "Conflict"
		    
		  Case 410
		    msg = "Gone"
		    
		  Case 411
		    msg = "Length Required"
		    
		  Case 412
		    msg = "Precondition Failed"
		    
		  Case 413
		    msg = "Request Entity Too Large"
		    
		  Case 414
		    msg = "Request-URI Too Long"
		    
		  Case 415
		    msg = "Unsupported Media Type"
		    
		  Case 416
		    msg = "Requested Range Not Satisfiable"
		    
		  Case 417
		    msg = "Expectation Failed"
		    
		  Case 418
		    msg = "I'm a teapot" ' https://tools.ietf.org/html/rfc2324
		    
		  Case 420
		    msg = "Enhance Your Calm" 'Nonstandard, from Twitter API
		    
		  Case 422
		    msg = "Unprocessable Entity"
		    
		  Case 423
		    msg = "Locked"
		    
		  Case 424
		    msg = "Failed Dependency"
		    
		  Case 425
		    msg = "Unordered Collection" 'Draft, https://tools.ietf.org/html/rfc3648
		    
		  Case 426
		    msg = "Upgrade Required"
		    
		  Case 428
		    msg = "Precondition Required"
		    
		  Case 429
		    msg = "Too Many Requests"
		    
		  Case 431
		    msg = "Request Header Fields Too Large"
		    
		  Case 444
		    msg = "No Response" 'Nginx
		    
		  Case 449
		    msg = "Retry With" 'Nonstandard, from Microsoft http://msdn.microsoft.com/en-us/library/dd891478.aspx
		    
		  Case 450
		    msg = "Blocked By Windows Parental Controls" 'Nonstandard, from Microsoft
		    
		  Case 451
		    msg = "Unavailable For Legal Reasons" 'Draft, https://tools.ietf.org/html/draft-tbray-http-legally-restricted-status-00
		    
		  Case 494
		    msg = "Request Header Too Large" 'nginx
		    
		  Case 495
		    msg = "Cert Error" 'nginx
		    
		  Case 496
		    msg = "No Cert" 'nginx
		    
		  Case 497
		    msg = "HTTP to HTTPS" 'nginx
		    
		  Case 499
		    msg = "Client Closed Request" 'nginx
		    
		  Case 500
		    msg = "Internal Server Error"
		    
		  Case 501
		    msg = "Not Implemented"
		    
		  Case 502
		    msg = "Bad Gateway"
		    
		  Case 503
		    msg = "Service Unavailable"
		    
		  Case 504
		    msg = "Gateway Timeout"
		    
		  Case 505
		    msg = "HTTP Version Not Supported"
		    
		  Case 506
		    msg = "Variant Also Negotiates" 'WEBDAV https://tools.ietf.org/html/rfc2295
		    
		  Case 507
		    msg = "Insufficient Storage" 'WEBDAV https://tools.ietf.org/html/rfc4918
		    
		  Case 508
		    msg = "Loop Detected" 'WEBDAV https://tools.ietf.org/html/rfc5842
		    
		  Case 509
		    msg = "Bandwidth Limit Exceeded" 'Apache, others
		    
		  Case 510
		    msg = "Not Extended"  'https://tools.ietf.org/html/rfc2774
		    
		  Case 511
		    msg = "Network Authentication Required" 'https://tools.ietf.org/html/rfc6585
		    
		  Else
		    msg = "Unknown Status Code"
		  End Select
		  
		  
		  
		  
		  Return "HTTP/1.1 " + Str(Code) + " " + msg
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function URLDecode(s as String) As String
		  'This method is from here: https://github.com/bskrtich/RBHTTPServer
		  // takes a Unix-encoded string and decodes it to the standard text encoding.
		  
		  // By Sascha RenÃ© Leib, published 11/08/2003 on the Athenaeum
		  
		  Dim r As String
		  Dim c As Integer ' current char
		  Dim i As Integer ' loop var
		  
		  // first, remove the unix-path-encoding:
		  
		  For i= 1 To LenB(s)
		    c = AscB(MidB(s, i, 1))
		    
		    If c = 37 Then ' %
		      r = r + ChrB(Val("&h" + MidB(s, i+1, 2)))
		      i = i + 2
		    Else
		      r = r + ChrB(c)
		    End If
		    
		  Next
		  
		  r = ReplaceAll(r,"+"," ")
		  
		  Return r
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function URLEncode(s as String) As String
		  'This method is from here: https://github.com/bskrtich/RBHTTPServer
		  // takes a locally encoded text string and converts it to a Unix-encoded string
		  
		  // By Sascha RenÃ© Leib, published 11/08/2003 on the Athenaeum
		  
		  Dim t As String ' encoded string
		  Dim r As String
		  Dim c As Integer ' current char
		  Dim i As Integer ' loop var
		  
		  Dim srcEnc, trgEnc As TextEncoding
		  Dim conv As TextConverter
		  
		  // in case the text converter is not available,
		  // use at least the standard encoding:
		  t = s
		  
		  // first, encode the string to UTF-8
		  srcEnc = GetTextEncoding(0, 0, 0) ' default encoding
		  trgEnc = GetTextEncoding(&h0100, 0, 2) ' Unicode 2.1: UTF-8
		  If srcEnc<>Nil And trgEnc<>Nil Then
		    conv = GetTextConverter(srcEnc, trgEnc)
		    If conv<>Nil Then
		      conv.clear
		      t = conv.convert(s)
		    End If
		  End If
		  
		  For i=1 To LenB(t)
		    c = AscB(MidB(t, i, 1))
		    
		    If c<=34 Or c=37 Or c=38 Then
		      r = r + "%" + RightB("0" + Hex(c), 2)
		    Elseif (c>=43 And c<=63) Or (c>=65 And c<=90) Or (c>=97 And c<=122) Then
		      r = r + Chr(c)
		    Else
		      r = r + "%" + RightB("0" + Hex(c), 2)
		    End If
		    
		  Next ' i
		  
		  Return r
		  
		End Function
	#tag EndMethod


	#tag Enum, Name = RequestMethod, Flags = &h0
		GET
		  HEAD
		  POST
		  PUT
		  DELETE
		TRACE
	#tag EndEnum


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
End Module
#tag EndModule
