|%
+=  job-type  $?  %parse
                  %compile
                  %invalid
              ==
+=  job-status  $?
                %busy
                %ok
                %fail
                ==
+=  error-kind  $?
                %syntax-error
                %nest-fail
                %mint-vain
                %mint-lost
                %find
                %find-fork
                %unknown
                ==
+=  src-loc   [row=@ud col=@ud]
+=  job-error  [loc=(list src-loc) kind=error-kind hint=tape]
+=  job  [type=job-type id=@ud stat=job-status src=tape blob=(unit hoon) err=(unit job-error) res=tape]
--
