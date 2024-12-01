const http = require("http")

http.createServer((req, res)=>{
  res.write("<h1>GloTogether</h1> <h2>Powered by Node.</h2>")
  res.end()
}).listen(3000)
