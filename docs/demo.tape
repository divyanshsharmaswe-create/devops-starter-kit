# Record with: vhs docs/demo.tape  (run from repo root after `make install`)
Output docs/demo.gif
Set Shell "bash"
Set FontSize 14
Set Width 1300
Set Height 340
Set Padding 18
Set Theme "Dracula"
Set TypingSpeed 40ms

Hide
Type "export PS1='$ ' && rm -f local.db && (.venv/bin/uvicorn app.main:app --port 8080 >/dev/null 2>&1 &) && sleep 2 && clear" Enter
Sleep 3s
Show

Type "make test 2>/dev/null | tail -1" Sleep 300ms Enter
Sleep 3s
Type "curl -s localhost:8080/healthz; echo" Sleep 300ms Enter
Sleep 1s
Type `curl -s -X POST localhost:8080/api/notes -H 'content-type: application/json' -d '{"text":"ship it"}'; echo` Sleep 300ms Enter
Sleep 1s
Type "curl -s localhost:8080/metrics | grep '^http_requests_total'" Sleep 300ms Enter
Sleep 2s
Type "ls infra/ .github/workflows/" Sleep 300ms Enter
Sleep 3s

Hide
Type "pkill -f 'uvicorn app.main:app'; rm -f local.db test.db" Enter
