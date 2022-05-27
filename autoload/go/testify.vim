" s:getTestName returns the name of the test function that preceeds the
" cursor.
function s:getTestName() abort
  " search flags legend (used only)
  " 'b' search backward instead of forward
  " 'c' accept a match at the cursor position
  " 'n' do Not move the cursor
  " 'W' don't wrap around the end of the file
  "
  " for the full list
  " :help search
  let l:funcline = search('func \(Test\|Example\)', "bcnW")
  let l:methline = search(') \(Test\|Example\)', 'bcnW')

  if l:funcline == 0
    return ''
  endif

  if l:methline > 0
     let l:funcdecl = getline(l:funcline)
     let l:methdecl = getline(l:methline)
     let l:funcname = split(split(l:funcdecl, " ")[1], "(")[0]
     let l:methname = split(split(l:methdecl, " ")[3], "(")[0]
     return join([l:funcname, l:methname], '/')
  endif

  let l:funcname = getline(l:funcline)
  return split(split(l:funcname, " ")[1], "(")[0]
endfunction

" Testfunc runs a single test that surrounds the current cursor position.
" Arguments are passed to the `go test` command.
function! go#testify#Func(bang, ...) abort
  let l:test = s:getTestName()
  if l:test is ''
    call go#util#EchoWarning("[test] no test found immediate to cursor")
    return
  endif
  let args = [a:bang, 0, "-run", l:test . "$"]

  if a:0
    call extend(args, a:000)
  else
    " only add this if no custom flags are passed
    let timeout = go#config#TestTimeout()
    call add(args, printf("-timeout=%s", timeout))
  endif

  call call('go#test#Test', args)
endfunction
