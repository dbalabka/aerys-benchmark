var http = require('http');

var srv = http.createServer(function (req, res) {
  var data, status;
  if(req.url === '/') {
    data = 'Hello world!';
    status = 200;
  } else {
    data = 'Not Found';
    status = 404;
  }
  res.writeHead(status, {
      'Content-Type': 'text/plain; charset=utf-8',
      'Content-Length': data.length,
      'X-Powered-By': 'Node Server'
  });
  res.end(data);
});

srv.listen(8080, '0.0.0.0');
