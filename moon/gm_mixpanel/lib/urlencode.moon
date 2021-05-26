import byte, format, gsub from string
import concat from table

urlencode = {}

encode = (str) ->

  --Ensure all newlines are in CRLF form
  str = gsub str, "\r?\n", "\r\n"

  --Percent-encode all non-unreserved characters
  --as per RFC 3986, Section 2.3
  --(except for space, which gets plus-encoded)
  str = gsub(
    str, "([^%w%-%.%_%~ ])",
    (c) -> return format("%%%02X", byte(c))
  )

  --Convert spaces to plus signs
  gsub(str, " ", "+")

--Make this function available as part of the module
urlencode.string = encode

--URL encode a table as a series of parameters.
urlencode.table = (t) ->

  --table of argument strings
  argts = {}

  --insertion iterator
  i = 1

  --URL-encode every pair
  for k, v in pairs(t) do
    argts[i] = "#{encode k}=#{encode v}"
    i = i + 1

  concat(argts,'&')

urlencode
