%.md: %.q ~/qnote/qnote 
	qnote $<| sed 's/q)~~~q/~~~q\nq)/'|sed 's/q)~~~/~~~\n/'| tail +4|tr -d '\r' > $@
watch:
	fswatch *.q|xargs -n1 basename|sed -u 's/.q/.md/'|xargs -n1 make
