const http = require('http');

const srv = http.createServer( (req, res) => {
  let data, status;
  if(req.url === '/') {
    data = 'Hello world!';
    status = 200;
  } else {
    data = 'Not Found';
    status = 404;
  }
  res.writeHead(status, {
    'Content-Type': 'text/plain; encoding=utf-8',
    'Content-Length': data.length});
  res.end(data);
});


srv.listen(8080, '0.0.0.0');
