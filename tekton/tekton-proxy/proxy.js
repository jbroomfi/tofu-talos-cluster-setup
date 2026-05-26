const http = require('http');
const httpProxy = require('http-proxy');

const proxy = httpProxy.createProxyServer({});

const PORT = 9100;

// Create a server that forwards all requests to localhost:9097
const server = http.createServer((req, res) => {
  proxy.web(req, res, { target: 'http://127.0.0.1:9097' }, (err) => {
    console.error('Proxy error:', err);
    res.writeHead(502);
    res.end('Bad gateway');
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Proxy listening on 0.0.0.0:${PORT}, forwarding to 127.0.0.1:9097`);
});
