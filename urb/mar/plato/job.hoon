/-  plato
=,  format


|_  job=job:plato
++  grab
  |%
  ++  json
      |=  jo=^json
          =/  par  =-  ((ot:dejs -) jo)
                   :~
                       id+ni:dejs
                       type+sa:dejs
                       src+sa:dejs
                       ==
                   =/  id  -.par
                   =/  src  +>.par
                   ?+  (crip +<.par)
                       [type=%invalid id=0 stat=%fail src="" blob=~ err=~ res=""]

                       %parse  [type=%parse id=`@ud`id stat=%busy src=src blob=~ err=~ res=""]
                       %compile  [type=%compile id=`@ud`id stat=%busy src=src blob=~ err=~ res=""]
                       ==

  --
++  grow
    |%
    ++  json
        %-  pairs:enjs
            :~      ['id' (numb:enjs id.job)]
                :-  'type'  %-  tape:enjs  ?-  type.job
                            %parse  "parse"
                            %compile  "compile"
                            %invalid  "invalid"
                            ==
                :-  'status'  %-  tape:enjs  ?-  stat.job
                            %busy  "busy"
                            %ok  "ok"
                            %fail  "fail"
                            ==
                :-  'error'  ?~  err.job
                             ~
                             =/  err=job-error:plato  +.err.job
                             %-  pairs:enjs
                             :~
                                 :-  'error-kind'  %-  tape:enjs
                                 ?-  kind.err
                                     %syntax-error  "syntax-error"
                                     %nest-fail     "nest-fail"
                                     %mint-vain     "mint-vain"
                                     %mint-lost     "mint-lost"
                                     %find          "find"
                                     %find-fork     "find-fork"
                                     %unknown       "unknown"
                                 ==

                                 ['hint' (tape:enjs hint.err)]

                                 :-  'region'  =/  start-loc  (snag 0 loc.err)
                                            =/  end-loc
                                            ?:  (gth (lent loc.err) 1)
                                                (snag 1 loc.err)
                                                (snag 0 loc.err)
                                            %-  pairs:enjs
                                            :~
                                            :-  'start'
                                                %-  pairs:enjs
                                                    :~  ['row' (numb:enjs row.start-loc)]
                                                        ['col' (numb:enjs col.start-loc)]
                                                        ==
                                            :-  'end'
                                                %-  pairs:enjs
                                                    :~  ['row' (numb:enjs row.end-loc)]
                                                        ['col' (numb:enjs col.end-loc)]
                                                        ==
                                            ==
                                 ==

                ['result' (tape:enjs res.job)]
            ==
    --
--
