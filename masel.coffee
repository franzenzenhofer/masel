$ = (s) -> document.querySelectorAll(s)
console.log(window.document)

report_error = (msg) -> console.log(msg)
not_set_error = (name) -> report_error(name+' not set')
if_not_set_error = (name, value) -> if not value then not_set_error(name) 

report_success = (msg) -> console.log(msg)

get_element_value = (query_selector) ->
  element_value = $(query_selector)?[0]?.value.trim() ? false
  if element_value isnt '' and element_value isnt undefined and element_value.length > 0
    return element_value
  else 
    return false

set_element_value = (query_selector, data) ->
  $qs = $(query_selector)
  console.log($qs)
  if not $qs?[0] then return false
  $qs[0].value = data
  return true


get_input = () -> get_element_value('#input')
get_password = () -> get_element_value('#password')
get_output = () -> get_element_value('#output')
get_messageurl = () -> get_element_value('#messageurl')

fetch_data = () ->  [get_input(), get_password(), get_output()]

set_output= (data) -> set_element_value('#output', data)
set_input= (data) -> set_element_value('#input', data)
set_messageurl = (data) -> set_element_value('#messageurl', data)

init_url_to_copy = (data) -> 
  if data
    set_messageurl(window.document.location.protocol+'//'+window.document.location.host+window.document.location.pathname+'?'+encodeURIComponent(data))
    $('#messageurl')[0].focus()
    $('#messageurl')[0].select()
    $('#copy')[0].style.display = 'block'
    return true
  else
    set_messageurl('')
    $('#copy')[0].style.display = 'none'
    return false




masel_encrypt = (input, password) ->
  out = sjcl.encrypt(password, input, {"ks":256})
  console.log(out)
  out = RawDeflate.deflate(out)
  out = Base64.toBase64(out)

masel_decrypt = (input, password) ->
  out = Base64.fromBase64(input)
  out = RawDeflate.inflate(out)
  out = sjcl.decrypt(password, out, {"ks":256})
  

x_crypt = (modus='en') ->
  [input, password]=fetch_data()
  if input and password
    try
      if modus is 'en'
        out = masel_encrypt(input, password) #sjcl.encrypt(password, input)
      else if modus is 'de'
        out = masel_decrypt(input, password) #sjcl.decrypt(password, input)
      else
        report_error('modus'+modus+'crypt not recognized')
    catch error
      report_error(error)
      return false

    if set_output(out)
      report_success('success '+modus+'crypt')
      if modus is 'en'
        init_url_to_copy(out)
      else
        init_url_to_copy(false)

    else
      report_error(modus+'crypt did not work')
  else
    if_not_set_error('input', input)
    if_not_set_error('password', password)

move_output_to_input = () -> 
  [_notused,_notused,output] = fetch_data()
  set_input(output or '')
  set_output('')
  init_url_to_copy(false)
  return true

init_input_with_url = () ->
  data = decodeURIComponent(window.location?.search?.replace(/^(#|\?)/, ''))
  if data
    set_input(data)
    set_output('')
    init_url_to_copy(false)
    $('#password')[0].focus()
    return true
  else
    $('#input')[0].focus()
    return false

encrypt = () -> x_crypt('en')
decrypt = () -> x_crypt('de')

tweet = () ->
  window.document.location = 'http://twitter.com/intent/tweet?text='+encodeURIComponent('MASEL Encrypted Message')+'&url='+encodeURIComponent(get_messageurl())

fb = () ->
  window.document.location = 'https://www.facebook.com/sharer.php?u='+encodeURIComponent(get_messageurl())+'&t='+encodeURIComponent('MASEL Encrypted Message')

$('#encrypt')[0].addEventListener('click', encrypt)
$('#decrypt')[0].addEventListener('click', decrypt)
$('#output')[0].addEventListener('click', (()->$('#output')[0].select()))
$('#messageurl')[0].addEventListener('click', (()->$('#messageurl')[0].select()))
$('#up')[0].addEventListener('click', move_output_to_input)
$('#gotourl')[0].addEventListener('click', (()->window.document.location = get_messageurl()))
$('#tweet')[0].addEventListener('click', tweet)
$('#fb')[0].addEventListener('click', fb)
#this must always be the last statement

window.addEventListener('load', init_input_with_url)

