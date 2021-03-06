" vim600: set foldmethod=marker:
" $Id: cvscommand.vim,v 1.1 2004-03-03 10:35:58 ken Exp $
"
" Vim plugin to assist in working with CVS-controlled files.
"
" Last Change:   $Date: 2004-03-03 10:35:58 $
" Maintainer:    Bob Hiestand <bob@hiestandfamily.org>
" License:       This file is placed in the public domain.
" Credits:       Mathieu Clabaut for many suggestions and improvements
"
"                Suresh Govindachar and Jeeva Chelladhurai for finding waaaay
"                too many bugs.
"
"                Albrecht Gass for the Delete-on-Hide behavior suggestion.
"
" Section: Documentation {{{1
"
" Provides functions to invoke various CVS commands on the current file.
" The output of the commands is captured in a new scratch window.  For
" convenience, if the functions are invoked on a CVS output window, the
" original file is used for the cvs operation instead after the window is
" split.  This is primarily useful when running CVSCommit and you need to see
" the changes made, so that CVSDiff is usable and shows up in another window.
"
" Function documentation {{{2
"
" CVSAdd        Performs "cvs add" on the current file.
"
" CVSAnnotate   Performs "cvs annotate" on the current file.  If not given an
"               argument, uses the most recent version of the file on the current
"               branch.  Otherwise, the argument is used as a revision number.
"
" CVSCommit     This is a two-stage command.  The first step opens a buffer to
"               accept a log message.  When that buffer is written, it is
"               automatically closed and the file is committed using the
"               information from that log message.  If the file should not be
"               committed, just destroy the log message buffer without writing
"               it.
"
" CVSDiff       With no arguments, this performs "cvs diff" on the current
"               file.  With one argument, "cvs diff" is performed on the
"               current file against the specified revision.  With two
"               arguments, cvs diff is performed between the specified
"               revisions of the current file.  This command uses the
"               'CVSCommandDiffOpt' variable to specify diff options.  If that
"               variable does not exist, then 'wbBc' is assumed.  If you wish
"               to have no options, then set it to the empty string.
"
" CVSEdit       Performs "cvs edit" on the current file.
"
" CVSLog        Performs "cvs log" on the current file.
"
" CVSRevert     Replaces the modified version of the current file with the
"               most recent version from the repository.
"
" CVSReview     Retrieves a particular version of the current file.  If no
"               argument is given, the most recent version of the file on
"               the current branch is retrieved.  The specified revision is
"               retrieved into a new buffer.
"
" CVSStatus     Performs "cvs status" on the current file.
"
" CVSUnedit     Performs "cvs unedit" on the current file.
"
" CVSUpdate     Performs "cvs update" on the current file.
"
" CVSVimDiff    With no arguments, this prompts the user for a revision and
"               then uses vimdiff to display the differences between the current
"               file and the specified revision.  If no revision is specified,
"               the most recent version of the file on the current branch is used.
"               With one argument, that argument is used as the revision as
"               above.  With two arguments, the differences between the two
"               revisions is displayed using vimdiff.
"
"               With either zero or one argument, the original buffer is used
"               to perform the vimdiff.  When the other buffer is closed, the
"               original buffer will be returned to normal mode.
"
" Mapping documentation: {{{2
"
" By default, a mapping is defined for each command.  User-provided mappings
" can be used instead by mapping to <Plug>CommandName, for instance:
"
" nnoremap ,ca <Plug>CVSAdd
"
" The default mappings are as follow:
"
"   <Leader>ca CVSAdd
"   <Leader>cn CVSAnnotate
"   <Leader>cc CVSCommit
"   <Leader>cd CVSDiff
"   <Leader>ce CVSEdit
"   <Leader>cl CVSLog
"   <Leader>cr CVSReview
"   <Leader>cs CVSStatus
"   <Leader>ct CVSUnedit
"   <Leader>cu CVSUpdate
"   <Leader>cv CVSVimDiff
"
" Options documentation: {{{2
"
" Several variables are checked by the script to determine behavior as follow:
"
" CVSCommandDeleteOnHide
"   This variable, if set to a non-zero value, causes the temporary CVS result
"   buffers to automatically delete themselves when hidden.
"
" CVSCommandDiffOpt
"   This variable, if set, determines the options passed to the diff command
"   of CVS.  If not set, it defaults to 'wbBc'.
"
" CVSCommandNameResultBuffers
"   This variable, if set to a true value, causes the cvs result buffers to be
"   named in the old way ('<source file name> _<cvs command>_').  If not set
"   or set to a false value, the result buffer is nameless.
"
" CVSCommandNameMarker
"   This variable, if set, configures the special attention-getting characters
"   that appear on either side of the cvs buffer type in the buffer name.
"   This has no effect unless 'CVSCommandNameResultBuffers' is set to a true
"   value.  If not set, it defaults to '_'.  
"
" CVSCommandSplit
"   This variable controls the orientation of the various window splits that
"   may occur (such as with CVSVimDiff, when using a CVS command on a CVS
"   command buffer, or when the 'CVSCommandEdit' variable is set to 'split'.
"   If set to 'horizontal', the resulting windows will be on stacked on top of
"   one another.  If set to 'vertical', the resulting windows will be
"   side-by-side.  If not set, it defaults to 'horizontal' for all but
"   CVSVimDiff windows.
"
" CVSCommandDiffSplit
"   This variable overrides the CVSCommandSplit variable, but only for buffers
"   created with CVSVimDiff.
"
" CVSCommandEdit
"   This variable controls whether the original buffer is replaced ('edit') or
"   split ('split').  If not set, it defaults to 'edit'.
"
" CVSCommandInteractive
"   This variable, if set to a non-zero value, causes appropriate functions (for
"   the moment, only CVSReview) to query the user for a revision to use
"   instead of the current revision if none is specified.
"
" CVSCommandEnableBufferSetup
"   This variable, if set to a non-zero value, activates CVS buffer management
"   mode.  This mode means that two buffer variables, 'CVSRevision' and
"   'CVSBranch', are set if the file is CVS-controlled.  This is useful for
"   displaying version information in the status bar.
"
" Event documentation {{{2
"   For additional customization, cvscommand.vim uses User event autocommand
"   hooks.  Each event is in the CVSCommand group, and different patterns
"   match the various hooks.
"
"   For instance, the following could be added to the vimrc to provide a 'q'
"   mapping to quit a CVS buffer:
"
"   augroup CVSCommand
"     au CVSCommand User CVSBufferCreated silent! nmap <unique> <buffer> q:bwipeout<cr> 
"   augroup END
"
"   The following hooks are available:
"
"   CVSBufferCreated           This event is fired just after a cvs command
"                              result buffer is created and filled with the
"                              result of a cvs command.  It is executed within
"                              the context of the CVS command buffer.

" Section: Plugin header {{{1
" loaded_cvscommand is set to 1 when the initialization begins, and 2 when it
" completes.  This allows various actions to only be taken by functions after
" system initialization.

if exists("loaded_cvscommand")
   finish
endif
let loaded_cvscommand = 1

" Section: Event group setup {{{1

augroup CVSCommand
augroup END

" Section: Plugin initialization {{{1
silent do CVSCommand User CVSPluginInit

" Section: Useful pattern constants {{{1

let s:CVSCommandTagPattern='\a[A-Za-z0-9-_]*'

" Section: Utility functions {{{1

" Function: s:CVSResolveLink() {{{2
" Fully resolve the given file name to remove shortcuts or symbolic links.

function! s:CVSResolveLink(fileName)
  let resolved = resolve(a:fileName)
  if resolved != a:fileName
    let resolved = s:CVSResolveLink(resolved)
  endif
  return resolved
endfunction

" Function: s:CVSChangeToCurrentFileDir() {{{2
" Go to the directory in which the current CVS-controlled file is located.
" If this is a CVS command buffer, first switch to the original file.

function! s:CVSChangeToCurrentFileDir(fileName)
  let oldCwd=getcwd()
  let fileName=s:CVSResolveLink(a:fileName)
  let newCwd=fnamemodify(fileName, ':h')
  if strlen(newCwd) > 0
    execute 'cd' escape(newCwd, ' ')
  endif
  return oldCwd
endfunction

" Function: s:CVSGetOption(name, default) {{{2
" Grab a user-specified option to override the default provided.  Options are
" searched in the window, buffer, then global spaces.

function! s:CVSGetOption(name, default)
  if exists("w:" . a:name)
    execute "return w:".a:name
  elseif exists("b:" . a:name)
    execute "return b:".a:name
  elseif exists("g:" . a:name)
    execute "return g:".a:name
  else
    return a:default
  endif
endfunction

" Function: s:CVSEditFile(name, origBuffNR) {{{2
" Wrapper around the 'edit' command to provide some helpful error text if the
" current buffer can't be abandoned.  If name is provided, it is used;
" otherwise, a nameless scratch buffer is used.
" Returns: 0 if successful, -1 if an error occurs.

function! s:CVSEditFile(name, origBuffNR)
  let v:errmsg = ""
  let editCommand = s:CVSGetOption('CVSCommandEdit', 'edit')
  if editCommand != 'edit' 
    if s:CVSGetOption('CVSCommandSplit', 'horizontal') == 'horizontal'
      if a:name == ""
        let editCommand = 'rightbelow new'
      else
        let editCommand = 'rightbelow split ' . a:name
      endif
    else
      if a:name == ""
        let editCommand = 'vert rightbelow new'
      else
        let editCommand = 'vert rightbelow split ' . a:name
      endif
    endif
  else
    if a:name == ""
      let editCommand = 'enew'
    else
      let editCommand = 'edit ' . a:name
    endif
  endif

  " Protect against useless buffer set-up
  let g:CVSCommandEditFileRunning = 1
  execute editCommand
  unlet g:CVSCommandEditFileRunning

  if v:errmsg != ""
    if &modified && !&hidden
      echoerr "Unable to open command buffer because 'nohidden' is set and the current buffer is modified (see :help 'hidden')."
    else
      echoerr "Unable to open command buffer" v:errmsg
    endif
    return -1
  endif
  let b:CVSOrigBuffNR=a:origBuffNR
  let b:CVSCommandEdit='split'
endfunction

" Function: s:CVSCreateCommandBuffer(cmd, cmdName, statusText, filename) {{{2
" Creates a new scratch buffer and captures the output from execution of the
" given command.  The name of the scratch buffer is returned.

function! s:CVSCreateCommandBuffer(cmd, cmdName, statusText, origBuffNR)
  let fileName=bufname(a:origBuffNR)

  let resultBufferName=''

  if s:CVSGetOption("CVSCommandNameResultBuffers", 0)
    let nameMarker = s:CVSGetOption("CVSCommandNameMarker", '_')
    if strlen(a:statusText) > 0
      let bufName=a:cmdName . ' -- ' . a:statusText
    else
      let bufName=a:cmdName
    endif
    let bufName=fileName . ' ' . nameMarker . bufName . nameMarker
    let counter=0
    let resultBufferName = bufName
    while buflisted(resultBufferName)
      let counter=counter + 1
      let resultBufferName=bufName . ' (' . counter . ')'
    endwhile
    let resultBufferName = escape(resultBufferName, ' *\')
  endif

  if s:CVSEditFile(resultBufferName, a:origBuffNR) == -1
    return -1
  endif

  set buftype=nofile
  set noswapfile
  set filetype=

  if s:CVSGetOption("CVSCommandDeleteOnHide", 0)
    set bufhidden=delete
  endif

  silent execute a:cmd
  $d
  1

  " Define the environment and execute user-defined hooks.

  let b:CVSSourceFile=fileName
  let b:CVSCommand=a:cmdName
  if a:statusText != ""
    let b:CVSStatusText=a:statusText
  endif

  silent do CVSCommand User CVSBufferCreated
  return bufnr("%")
endfunction

" Function: s:CVSBufferCheck(cvsBuffer) {{{2
" Attempts to locate the original file to which CVS operations were applied
" for a given buffer.

function! s:CVSBufferCheck(cvsBuffer)
  let origBuffer = getbufvar(a:cvsBuffer, "CVSOrigBuffNR")
  if origBuffer
    if bufexists(origBuffer)
      return origBuffer
    else
      " Original buffer no longer exists.
      return -1 
    endif
  else
    " No original buffer
    return a:cvsBuffer
  endif
endfunction

" Function: s:CVSCurrentBufferCheck() {{{2
" Attempts to locate the original file to which CVS operations were applied
" for the current buffer.

function! s:CVSCurrentBufferCheck()
  return s:CVSBufferCheck(bufnr("%"))
endfunction

" Function: s:CVSToggleDeleteOnHide() {{{2
" Toggles on and off the delete-on-hide behavior of CVS buffers

function! s:CVSToggleDeleteOnHide()
  if exists("g:CVSCommandDeleteOnHide")
    unlet g:CVSCommandDeleteOnHide
  else
    let g:CVSCommandDeleteOnHide=1
  endif
endfunction

" Function: s:CVSDoCommand(cvscmd, cmdName, statusText) {{{2
" General skeleton for CVS function execution.
" Returns: name of the new command buffer containing the command results

function! s:CVSDoCommand(cmd, cmdName, statusText)
  let cvsBufferCheck=s:CVSCurrentBufferCheck()
  if cvsBufferCheck == -1 
    echo "Original buffer no longer exists, aborting."
    return -1
  endif

  let fileName=bufname(cvsBufferCheck)
  let realFileName = fnamemodify(s:CVSResolveLink(fileName), ':t')
  let oldCwd=s:CVSChangeToCurrentFileDir(fileName)
  let fullCmd = '0r!' . a:cmd . ' "' . realFileName . '"'
  let resultBuffer=s:CVSCreateCommandBuffer(fullCmd, a:cmdName, a:statusText, cvsBufferCheck)
  execute 'cd' escape(oldCwd, ' ')
  return resultBuffer
endfunction


" Function: s:CVSGetStatusVars(revision, branch) {{{2
"
" Obtains a CVS revision number and branch name.  The 'revisionVar' and
" 'branchVar' arguments, if non-empty, contain the names of variables to hold
" the corresponding results.
"
" Returns: string to be exec'd that sets the multiple return values.

function! s:CVSGetStatusVars(revisionVar, branchVar)
  let cvsBufferCheck=s:CVSCurrentBufferCheck()
  if cvsBufferCheck == -1 
    return ""
  endif
  let fileName=bufname(cvsBufferCheck)
  let realFileName = fnamemodify(s:CVSResolveLink(fileName), ':t')
  let oldCwd=s:CVSChangeToCurrentFileDir(fileName)
  let statustext=system("cvs status " . escape(realFileName, " *?\\"))
  if(v:shell_error)
    execute 'cd' escape(oldCwd, ' ')
    return ""
  endif
  let revision=substitute(statustext, '^\_.*Working revision:\s*\(\d\+\%(\.\d\+\)\+\|New file!\)\_.*$', '\1', "")

  " We can still be in a CVS-controlled directory without this being a CVS
  " file
  if match(revision, '^New file!$') >= 0 
    let revision="NEW"
  elseif match(revision, '^\d\+\.\d\+\%(\.\d\+\.\d\+\)*$') >=0
  else
    execute 'cd' escape(oldCwd, ' ')
    return ""
  endif

  let returnExpression = "let " . a:revisionVar . "='" . revision . "'"

  if a:branchVar != ""
    let branch=substitute(statustext, '^\_.*Sticky Tag:\s\+\(' . s:CVSCommandTagPattern . '\|(none)\).*$', '\1', "")
    let returnExpression=returnExpression . " | let " . a:branchVar . "='" . branch . "'"
  endif

  execute 'cd' escape(oldCwd, ' ')
  return returnExpression
endfunction

" Function: s:CVSSetupBuffer() {{{2
" Attempts to set the b:CVSBranch and b:CVSRevision variables.

function! s:CVSSetupBuffer()
  if (exists("b:CVSBufferSetup") && b:CVSBufferSetup)
    return
  endif

  if !s:CVSGetOption("CVSCommandEnableBufferSetup", 0)
        \ || @% == ""
        \ || exists("g:CVSCommandEditFileRunning")
        \ || exists("b:CVSOrigBuffNR")
    unlet! b:CVSRevision
    unlet! b:CVSBranch
    return
  endif

  let revision=""
  let branch=""

  exec s:CVSGetStatusVars('revision', 'branch')
  if revision != ""
    let b:CVSRevision=revision
  else
    unlet! b:CVSRevision
  endif
  if branch != ""
    let b:CVSBranch=branch
  else
    unlet! b:CVSBranch
  endif
  let b:CVSBufferSetup=1
endfunction

" Function: s:CVSMarkOrigBufferForSetup(cvsbuffer) {{{2
" Resets the buffer setup state of the original buffer for a given CVS buffer.
" Returns:  The CVS buffer number in a passthrough mode.

function! s:CVSMarkOrigBufferForSetup(cvsBuffer)
  if a:cvsBuffer != -1
    let origBuffer = s:CVSBufferCheck(a:cvsBuffer)
    "This should never not work, but I'm paranoid
    if origBuffer != a:cvsBuffer
      call setbufvar(origBuffer, "CVSBufferSetup", 0)
    endif
  endif
  return a:cvsBuffer
endfunction

" Section: Public functions {{{1

" Function: CVSGetRevision() {{{2
" Global function for retrieving the current buffer's CVS revision number.
" Returns: Revision number or an empty string if an error occurs.

function! CVSGetRevision()
  let revision=""
  exec s:CVSGetStatusVars('revision', '')
  return revision
endfunction

" Function: CVSDisableBufferSetup() {{{2
" Global function for deactivating the buffer autovariables.

function! CVSDisableBufferSetup()
  let g:CVSCommandEnableBufferSetup=0
  silent! augroup! CVSCommandPlugin
endfunction

" Function: CVSEnableBufferSetup() {{{2
" Global function for activating the buffer autovariables.

function! CVSEnableBufferSetup()
  let g:CVSCommandEnableBufferSetup=1
  augroup CVSCommandPlugin
    au!
    au BufEnter * call s:CVSSetupBuffer()
  augroup END

  " Only auto-load if the plugin is fully loaded.  This gives other plugins a
  " chance to run.
  if g:loaded_cvscommand == 2
    call s:CVSSetupBuffer()
  endif
endfunction

" Function: CVSGetStatusLine() {{{2
" Default (sample) status line entry for CVS files.  This is only useful if
" CVS-managed buffer mode is on (see the CVSCommandEnableBufferSetup variable
" for how to do this).

function! CVSGetStatusLine()
  if exists('b:CVSSourceFile')
    " This is a result buffer
    let value='[' . b:CVSCommand . ' ' . b:CVSSourceFile
    if exists('b:CVSStatusText')
      let value=value . ' ' . b:CVSStatusText
    endif
    let value = value . ']'
    return value
  endif

  if exists('b:CVSRevision')
        \ && b:CVSRevision != ''
        \ && exists('b:CVSBranch')
        \ && b:CVSBranch != ''
        \ && exists('g:CVSCommandEnableBufferSetup')
        \ && g:CVSCommandEnableBufferSetup
    return '[CVS ' . b:CVSBranch . '/' . b:CVSRevision . ']'
  else
    return ''
  endif
endfunction

" Section: CVS command functions {{{1

" Function: s:CVSAdd() {{{2
function! s:CVSAdd()
  return s:CVSMarkOrigBufferForSetup(s:CVSDoCommand('cvs add', 'cvsadd', ''))
endfunction

" Function: s:CVSAnnotate(...) {{{2
function! s:CVSAnnotate(...)
  let cvsBufferCheck=s:CVSCurrentBufferCheck()
  if cvsBufferCheck == -1 
    echo "Original buffer no longer exists, aborting."
    return -1
  endif

  let fileName=bufname(cvsBufferCheck)
  let realFileName = fnamemodify(s:CVSResolveLink(fileName), ':t')
  let oldCwd=s:CVSChangeToCurrentFileDir(fileName)

  let currentLine=line(".")

  if a:0 == 0
    let revision=CVSGetRevision()
    if revision == ""
      echo "Unable to obtain status for " . fileName
      execute 'cd' escape(oldCwd, ' ')
      return -1
    endif
  else
    let revision=a:1
  endif

  if revision == "NEW"
    echo "No annotatation available for new file " . fileName
    execute 'cd' escape(oldCwd, ' ')
    return -1
  endif

  let resultBuffer=s:CVSCreateCommandBuffer('0r!cvs -q annotate -r ' . revision . ' "' . realFileName . '"', 'cvsannotate', '', cvsBufferCheck) 
  if resultBuffer !=  -1
    exec currentLine
    set filetype=CVSAnnotate
  endif

  execute 'cd' escape(oldCwd, ' ')
  return resultBuffer
endfunction

" Function: s:CVSCommit() {{{2
function! s:CVSCommit()
  let cvsBufferCheck=s:CVSCurrentBufferCheck()
  if cvsBufferCheck ==  -1
    echo "Original buffer no longer exists, aborting."
    return -1
  endif

  let messageFileName = tempname()

  let fileName=bufname(cvsBufferCheck)
  let realFilePath=s:CVSResolveLink(fileName)
  let newCwd=fnamemodify(realFilePath, ':h')
  let realFileName=fnamemodify(realFilePath, ':t')

  execute 'au BufWritePost' messageFileName 'call s:CVSFinishCommit("' . messageFileName . '", "' . newCwd . '", "' . realFileName . '", ' . cvsBufferCheck . ') | au! * ' messageFileName
  execute 'au BufDelete' messageFileName 'au! * ' messageFileName

  if s:CVSEditFile(messageFileName, cvsBufferCheck) == -1
    execute 'au! *' messageFileName
  else
    0put ='CVS: ----------------------------------------------------------------------'
    put =\"CVS: Enter Log.  Lines beginning with `CVS:' are removed automatically\"
    put ='CVS: ----------------------------------------------------------------------'
    $
    let b:CVSSourceFile=fileName
    let b:CVSCommand='CVSCommit'
  endif
endfunction

" Function: s:CVSDiff(...) {{{2
function! s:CVSDiff(...)
  if a:0 == 1
    let revOptions = '-r' . a:1
    let caption = a:1 . ' -> current'
  elseif a:0 == 2
    let revOptions = '-r' . a:1 . ' -r' . a:2
    let caption = a:1 . ' -> ' . a:2
  else
    let revOptions = ''
    let caption = ''
  endif

  let cvsdiffopt=s:CVSGetOption('CVSCommandDiffOpt', 'wbBc')

  if cvsdiffopt == ""
    let diffoptionstring=""
  else
    let diffoptionstring=" -" . cvsdiffopt . " "
  endif

  let resultBuffer = s:CVSDoCommand('cvs diff ' . diffoptionstring . revOptions , 'cvsdiff', caption)
  if resultBuffer != -1 
    set filetype=diff
  endif
  return resultBuffer
endfunction

" Function: s:CVSEdit() {{{2
function! s:CVSEdit()
  return s:CVSDoCommand('cvs edit', 'cvsedit', '')
endfunction

" Function: s:CVSFinishCommit(messageFile, targetDir, targetFile) {{{2
function! s:CVSFinishCommit(messageFile, targetDir, targetFile, origBuffNR)
  if filereadable(a:messageFile)
    let oldCwd=getcwd()
    if strlen(a:targetDir) > 0
      execute 'cd' escape(a:targetDir, ' ')
    endif
    let resultBuffer=s:CVSCreateCommandBuffer('0r!cvs commit -F "' . a:messageFile . '" "'. a:targetFile . '"', 'cvscommit', '', a:origBuffNR)
    execute 'cd' escape(oldCwd, ' ')
    execute 'bw' escape(a:messageFile, ' *?\')
    silent execute '!rm' a:messageFile
    return s:CVSMarkOrigBufferForSetup(resultBuffer)
  else
    echo "Can't read message file; no commit is possible."
    return -1
  endif
endfunction

" Function: s:CVSLog() {{{2
function! s:CVSLog(...)
  if a:0 == 0
    let versionOption = ""
    let caption = ''
  else
    let versionOption=" -r" . a:1
    let caption = a:1
  endif

  let resultBuffer=s:CVSDoCommand('cvs log' . versionOption, 'cvslog', caption)
  if resultBuffer != ""
    set filetype=rcslog
  endif
  return resultBuffer
endfunction

" Function: s:CVSRevert() {{{2
function! s:CVSRevert()
  return s:CVSMarkOrigBufferForSetup(s:CVSDoCommand('cvs update -C', 'cvsrevert', ''))
endfunction

" Function: s:CVSReview(...) {{{2
function! s:CVSReview(...)
  if a:0 == 0
    let versiontag=""
    if s:CVSGetOption('CVSCommandInteractive', 0)
      let versiontag=input('Revision:  ')
    endif
    if versiontag == ""
      let versiontag="(current)"
      let versionOption=""
    else
      let versionOption=" -r " . versiontag . " "
    endif
  else
    let versiontag=a:1
    let versionOption=" -r " . versiontag . " "
  endif

  let origFileType=&filetype

  let resultBuffer = s:CVSDoCommand('cvs -q update -p' . versionOption, 'cvsreview', versiontag)

  let &filetype=origFileType
  return resultBuffer
endfunction

" Function: s:CVSStatus() {{{2
function! s:CVSStatus()
  return s:CVSDoCommand('cvs status', 'cvsstatus', '')
endfunction

" Function: s:CVSUnedit() {{{2
function! s:CVSUnedit()
  return s:CVSDoCommand('cvs unedit', 'cvsunedit', '')
endfunction

" Function: s:CVSUpdate() {{{2
function! s:CVSUpdate()
  return s:CVSMarkOrigBufferForSetup(s:CVSDoCommand('cvs update', 'update', ''))
endfunction

" Function: s:CVSVimDiff(...) {{{2
function! s:CVSVimDiff(...)
  if(a:0 == 0)
    let resultBuffer=s:CVSReview()
    diffthis
  elseif(a:0 == 1)
    let resultBuffer=s:CVSReview(a:1)
    diffthis
  else
    call s:CVSReview(a:1)
    diffthis
    " If no split method is defined, cheat, and set it to vertical.
    if s:CVSGetOption('CVSCommandDiffSplit', s:CVSGetOption('CVSCommandSplit', 'dummy')) == 'dummy'
      let b:CVSCommandSplit='vertical'
    endif
    let resultBuffer=s:CVSReview(a:2)
    diffthis
    return resultBuffer
  endif

  let originalBuffer=b:CVSOrigBuffNR
  let originalWindow=bufwinnr(originalBuffer)

  " Don't remove the just-created buffer
  let savedHideOption = getbufvar(resultBuffer, '&bufhidden')
  call setbufvar(resultBuffer, '&bufhidden', 'hide')

  execute "hide b" originalBuffer
  let resultBufferName=escape(fnamemodify(bufname(resultBuffer), ':p'), ' \')

  " If there's already a VimDiff'ed window, restore it.
  " There may only be one CVSVimDiff original window at a time.

  if exists("g:CVSCommandRestoreVimDiffStateCmd")
    execute g:CVSCommandRestoreVimDiffStateCmd
  endif

  " Store the state of original buffer so that it can reset when the CVS
  " buffer departs.

  let g:CVSCommandRestoreVimDiffSourceBuffer = originalBuffer
  let g:CVSCommandRestoreVimDiffScratchBuffer = resultBuffer
  let g:CVSCommandRestoreVimDiffStateCmd = 
        \    "call setbufvar(".originalBuffer.", \"&diff\", ".getwinvar(originalWindow, '&diff').")"
        \ . "|call setbufvar(".originalBuffer.", \"&foldcolumn\", ".getwinvar(originalWindow, '&foldcolumn').")"
        \ . "|call setbufvar(".originalBuffer.", \"&foldmethod\", '". getwinvar(originalWindow, '&foldmethod')."')"
        \ . "|call setbufvar(".originalBuffer.", \"&scrollbind\", ".getwinvar(originalWindow, '&scrollbind').")"
        \ . "|call setbufvar(".originalBuffer.", \"&wrap\", ".getwinvar(originalWindow, '&wrap').")"


  diffthis

  let g:CVSCommandEditFileRunning = 1
  if s:CVSGetOption('CVSCommandDiffSplit', s:CVSGetOption('CVSCommandSplit', 'vertical')) == 'horizontal'
    execute "silent rightbelow sbuffer" . resultBuffer
  else
    execute "silent vert rightbelow sbuffer" . resultBuffer
  endif
  unlet g:CVSCommandEditFileRunning

  call setbufvar(resultBuffer, '&bufhidden', savedHideOption)

  return resultBuffer
endfunction

" Section: Command definitions {{{1
" Section: Primary commands {{{2
com! CVSAdd call s:CVSAdd()
com! -nargs=? CVSAnnotate call s:CVSAnnotate(<f-args>)
com! CVSCommit call s:CVSCommit()
com! -nargs=* CVSDiff call s:CVSDiff(<f-args>)
com! CVSEdit call s:CVSEdit()
com! -nargs=? CVSLog call s:CVSLog(<f-args>)
com! CVSRevert call s:CVSRevert()
com! -nargs=? CVSReview call s:CVSReview(<f-args>)
com! CVSStatus call s:CVSStatus()
com! CVSUnedit call s:CVSUnedit()
com! CVSUpdate call s:CVSUpdate()
com! -nargs=* CVSVimDiff call s:CVSVimDiff(<f-args>)

" Section: CVS buffer management commands {{{2
com! CVSDisableBufferSetup call CVSDisableBufferSetup()
com! CVSEnableBufferSetup call CVSEnableBufferSetup()

" Allow reloading cvscommand.vim
com! CVSReload unlet! loaded_cvscommand | runtime plugin/cvscommand.vim

" Section: Plugin command mappings {{{1
nnoremap <silent> <Plug>CVSAdd :CVSAdd<CR>
nnoremap <silent> <Plug>CVSAnnotate :CVSAnnotate<CR>
nnoremap <silent> <Plug>CVSCommit :CVSCommit<CR>
nnoremap <silent> <Plug>CVSDiff :CVSDiff<CR>
nnoremap <silent> <Plug>CVSEdit :CVSEdit<CR>
nnoremap <silent> <Plug>CVSLog :CVSLog<CR>
nnoremap <silent> <Plug>CVSRevert :CVSRevert<CR>
nnoremap <silent> <Plug>CVSReview :CVSReview<CR>
nnoremap <silent> <Plug>CVSStatus :CVSStatus<CR>
nnoremap <silent> <Plug>CVSUnedit :CVSUnedit<CR>
nnoremap <silent> <Plug>CVSUpdate :CVSUpdate<CR>
nnoremap <silent> <Plug>CVSVimDiff :CVSVimDiff<CR>

" Section: Default mappings {{{1
if !hasmapto('<Plug>CVSAdd')
  nmap <unique> <Leader>ca <Plug>CVSAdd
endif
if !hasmapto('<Plug>CVSAnnotate')
  nmap <unique> <Leader>cn <Plug>CVSAnnotate
endif
if !hasmapto('<Plug>CVSCommit')
  nmap <unique> <Leader>cc <Plug>CVSCommit
endif
if !hasmapto('<Plug>CVSDiff')
  nmap <unique> <Leader>cd <Plug>CVSDiff
endif
if !hasmapto('<Plug>CVSEdit')
  nmap <unique> <Leader>ce <Plug>CVSEdit
endif
if !hasmapto('<Plug>CVSLog')
  nmap <unique> <Leader>cl <Plug>CVSLog
endif
if !hasmapto('<Plug>CVSRevert')
  nmap <unique> <Leader>cq <Plug>CVSRevert
endif
if !hasmapto('<Plug>CVSReview')
  nmap <unique> <Leader>cr <Plug>CVSReview
endif
if !hasmapto('<Plug>CVSStatus')
  nmap <unique> <Leader>cs <Plug>CVSStatus
endif
if !hasmapto('<Plug>CVSUnedit')
  nmap <unique> <Leader>ct <Plug>CVSUnedit
endif
if !hasmapto('<Plug>CVSUpdate')
  nmap <unique> <Leader>cu <Plug>CVSUpdate
endif
if !hasmapto('<Plug>CVSVimDiff')
  nmap <unique> <Leader>cv <Plug>CVSVimDiff
endif

" Section: Menu items {{{1
amenu <silent> &Plugin.CVS.&Add      <Plug>CVSAdd
amenu <silent> &Plugin.CVS.A&nnotate <Plug>CVSAnnotate
amenu <silent> &Plugin.CVS.&Commit   <Plug>CVSCommit
amenu <silent> &Plugin.CVS.&Diff     <Plug>CVSDiff
amenu <silent> &Plugin.CVS.&Edit     <Plug>CVSEdit
amenu <silent> &Plugin.CVS.&Log      <Plug>CVSLog
amenu <silent> &Plugin.CVS.Revert    <Plug>CVSRevert
amenu <silent> &Plugin.CVS.&Review   <Plug>CVSReview
amenu <silent> &Plugin.CVS.&Status   <Plug>CVSStatus
amenu <silent> &Plugin.CVS.Unedi&t   <Plug>CVSUnedit
amenu <silent> &Plugin.CVS.&Update   <Plug>CVSUpdate
amenu <silent> &Plugin.CVS.&VimDiff  <Plug>CVSVimDiff

" Section: Autocommands to restore vimdiff state {{{1
function! s:CVSVimDiffRestore(vimDiffBuff)
  if exists("g:CVSCommandRestoreVimDiffScratchBuffer")
        \ && a:vimDiffBuff == g:CVSCommandRestoreVimDiffScratchBuffer
    if exists("g:CVSCommandRestoreVimDiffSourceBuffer")
      " Only restore if the source buffer is still in Diff mode
      if getbufvar(g:CVSCommandRestoreVimDiffSourceBuffer, "&diff")
        if exists("g:CVSCommandRestoreVimDiffStateCmd")
          execute g:CVSCommandRestoreVimDiffStateCmd
          unlet g:CVSCommandRestoreVimDiffStateCmd
        endif
      endif
      unlet g:CVSCommandRestoreVimDiffSourceBuffer
    endif
    unlet g:CVSCommandRestoreVimDiffScratchBuffer
  endif
endfunction

augroup CVSVimDiffRestore
  au!
  au BufUnload * call s:CVSVimDiffRestore(expand("<abuf>"))
augroup END

" Section: Optional activation of buffer management {{{1

if s:CVSGetOption('CVSCommandEnableBufferSetup', 0)
  call CVSEnableBufferSetup()
endif

" Section: Plugin completion {{{1
let loaded_cvscommand=2
silent do CVSCommand User CVSPluginFinish
