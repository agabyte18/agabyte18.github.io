const http = require("http")

http.createServer((req, res)=>{
  res.write("Welcome to GloTogether")
  res.end()
}).listen(3000)
