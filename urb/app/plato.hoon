::
::  Plato - an interactive Urbit editor
::
::  Copyright (C) 2018 ~ponmep-litsem
::
/-  plato
/=  env  /~  !>(.)
=,  userlib

|%
+=  move  [bone card]
+=  card  $%  [%diff %plato-job job:plato]
      ==

:: State is a map of jobs
+=  jobs  (map @ud job:plato)
--

|_  [bow=bowl:gall jobs=jobs]

++  prep
    |=  old=(unit *)
    ::~&  plato+"prep"
    [~ ..prep(+<+ *^jobs)]

++  wall-to-tape
    |=  w=wall
    (weld `tape`(zing `(list tape)`w) (trip `@tas`10))

++  print-tang
   |=  tg=tang
   ^-  tape
   (wall-to-tape (turn (turn tg |=(t=tank (wash [0 80] t))) |=(w=wall (wall-to-tape w))))

++  tang-to-tape-list
   |=  tg=tang
   ^-  (list tape)
   %-  turn  :*  tg
       |=  t=tank
       (wall-to-tape (wash [0 80] t))
       ==

++  parse-err-find
    ;~  plug
    (cold %find (jest '-find.'))
    ;~  sfix
        (plus prn)
        (just '\0a')
        ==
    ==

++  parse-err-fork
;~  plug
    (cold %find-fork (jest 'find-fork-'))
    ;~  sfix
        (plus prn)
        (just '\0a')
        ==
    ==
++  parse-err-what
    |=  what=tape
    ^-  [error-kind:plato tape]
    %-  scan
    :*  what
    ;~  pose
        (cold [%syntax-error ""] (jest 'syntax error\0a')) :: FIXME get rid of ugly 0a
        (cold [%nest-fail ""] (jest 'nest-fail\0a'))
        (cold [%mint-vain ""] (jest 'mint-vain\0a'))
        (cold [%mint-lost ""] (jest 'mint-lost\0a'))
        parse-err-find
        parse-err-fork
    ==
    ==

++  parser-err-loc
    |=  where=tape
    ^-  (list src-loc:plato)
    :~
    %-  region-dec-row
    =<  [row=- col=+]
    %+  scan
        where
        %+  ifix
        [(just '{') (jest '}\0a')]
        ;~  (glue gaw)
        dem
        dem
        ==
    ==


++  parse-compiler-location
    |=  where=tape
        ::~&  compiler+err+loc+where
        %+  scan
            where
            %+  ifix  [(jest '/:') (just '\0a')]
                total-location

++  total-location
    %+  ifix
        [(just '<') (just '>')]
        ;~  (glue dot)
            parse-loc-pair
            parse-loc-pair
            ==

++  parse-loc-pair
    %+  ifix
        [(just '[') (just ']')]
        ;~  (glue gaw)
            dem
            dem
            ==

++  region-dec-row
    |=  reg=[row=@ col=@]
    [row=(sub row.reg 1) col=col.reg]

++  compiler-err-loc
    |=  where=tape
    ^-  (list src-loc:plato)
    =/  region  (parse-compiler-location where)
    =/  start=[@ @]  (region-dec-row -.region) :: Row -1 bc we add !: to src
    =/  end=[@ @]  (region-dec-row +.region)
    ::~&  actual+start+start
    ::~&  actual+end+end
    :~(start end)

++  parse-err-loc
    |=  [what=error-kind:plato where=tape]
    ?+  what
        (compiler-err-loc where)
        %syntax-error  (parser-err-loc where)
        ==

++  parse-error
    |=  errdata=(list tape)
    ^-  (unit job-error:plato)
    =/  what  (parse-err-what (snag 0 errdata))
    ?:  =(-.what %find-fork) :: Find fork is followed by find
        =/  what  (parse-err-what (snag 1 errdata))
        =/  where  (parse-err-loc -.what (snag 2 errdata))
        %-  some
            :*  loc=where
                kind=-.what
                hint=+.what
                ==
        :: Normal case
        =/  where  (parse-err-loc -.what (snag 1 errdata))
        %-  some
            :*  loc=where
                kind=-.what
                hint=+.what
                ==

++  classify-error
  |=  err=tang
  ^-  (unit job-error:plato)
  =/  tl=(list tape)  (tang-to-tape-list err)
  ::~&  err+tang+is+(tang-to-tape-list err)
  (parse-error tl)


++  job-parse
  |=  j=job:plato
      ^-  job:plato
      =/  par  (mule |.((ream (crip (weld "!:\0a" src.j)))))
          ?-  -.par
              %&
              =/  blob=hoon  p.par
              =:  stat.j  %ok
                  res.j  "Parse Ok"
                  blob.j  [~ u=blob]
                  ==  j
              %|
              =:  stat.j  %fail
                  res.j  (print-tang p.par)
                  err.j  (classify-error p.par)
                  ==  j
              ==


++  job-compile
  |=  j=job:plato
      ^-  job:plato

      ?^  blob.j

      =/  com  (mule |.((slap env u.blob.j)))
          ?-  -.com
              %&
              =/  res  p.com
              =:  stat.j  %ok
                  res.j  (text res)
                  err.j  ~
                  ==  j
              %|
              =:  stat.j  %fail
                  res.j  (print-tang p.com)
                  err.j  (classify-error p.com)
                  ==  j
              ==
     =:  stat.j  %fail
         ==  j


++  update-job
  |=  j=job:plato
      ^-  ^jobs
      ::~&  plato+put+job+j
      (~(put by jobs) [id.j j])


++  poke-plato-job
    |=  job=job:plato
        ^-  (quip move _+>)
        :_  +>
        %+  turn  (prey:pubsub /job bow)
            =/  res  ?-  type.job
                :: We can compile only jobs which were parsed
                %compile
                (job-compile (job-parse job))

                %parse
                (job-parse job)

                %invalid
                *job:plato
                ==

                |=([o=bone *] [o %diff %plato-job res])


++  peer-job
    |=  wir=wire
        ::~&  plato+peer-notify+wir
        ::~&  plato+source+[ship+src.bow wire+wir]
        [~ +>]
--
