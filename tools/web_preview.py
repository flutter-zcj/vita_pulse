"""VitaPulse Web 预览服务。

单端口同时提供静态资源与后端接口转发，避免浏览器跨域与端口映射问题。

用法：
    python3 web_preview.py [--port 8080] [--api http://127.0.0.1:9099]
"""

import argparse
import os
import posixpath
import urllib.error
import urllib.request
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

# 需要转发到后端服务的路径前缀
API_PREFIXES = (
    '/login',
    '/logout',
    '/getInfo',
    '/captchaImage',
    '/health',
    '/vital',
    '/system',
    '/dev-api',
)


class PreviewHandler(SimpleHTTPRequestHandler):
    """静态资源与接口转发处理器。"""

    api_base = 'http://127.0.0.1:9099'

    def __init__(self, *args, **kwargs):
        """初始化处理器。

        :param args: 位置参数
        :param kwargs: 关键字参数，directory 指定静态根目录
        """
        super().__init__(*args, **kwargs)

    def _is_api(self, path: str) -> bool:
        """判断请求是否属于后端接口。

        :param path: 请求路径
        :return: 是否转发
        """
        for prefix in API_PREFIXES:
            if path == prefix or path.startswith(prefix + '/') or path.startswith(prefix + '?'):
                return True
        return False

    def _proxy(self) -> None:
        """将当前请求转发到后端服务。"""
        length = int(self.headers.get('Content-Length') or 0)
        body = self.rfile.read(length) if length else None
        target = self.api_base.rstrip('/') + self.path
        request = urllib.request.Request(target, data=body, method=self.command)
        for key, value in self.headers.items():
            if key.lower() in ('host', 'content-length', 'connection', 'accept-encoding'):
                continue
            request.add_header(key, value)
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                payload = response.read()
                self.send_response(response.status)
                for key, value in response.headers.items():
                    if key.lower() in ('content-length', 'transfer-encoding', 'connection', 'content-encoding'):
                        continue
                    self.send_header(key, value)
                self.send_header('Content-Length', str(len(payload)))
                self.end_headers()
                self.wfile.write(payload)
        except urllib.error.HTTPError as error:
            payload = error.read()
            self.send_response(error.code)
            self.send_header('Content-Type', error.headers.get('Content-Type', 'application/json'))
            self.send_header('Content-Length', str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
        except Exception as error:  # noqa: BLE001
            message = ('{"code":502,"msg":"proxy error: %s"}' % error).encode('utf-8')
            self.send_response(502)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Content-Length', str(len(message)))
            self.end_headers()
            self.wfile.write(message)

    def do_GET(self) -> None:  # noqa: N802
        """处理 GET 请求。"""
        if self._is_api(self.path):
            self._proxy()
            return
        super().do_GET()

    def do_POST(self) -> None:  # noqa: N802
        """处理 POST 请求。"""
        if self._is_api(self.path):
            self._proxy()
            return
        self.send_error(404)

    def do_PUT(self) -> None:  # noqa: N802
        """处理 PUT 请求。"""
        if self._is_api(self.path):
            self._proxy()
            return
        self.send_error(404)

    def do_DELETE(self) -> None:  # noqa: N802
        """处理 DELETE 请求。"""
        if self._is_api(self.path):
            self._proxy()
            return
        self.send_error(404)

    def do_OPTIONS(self) -> None:  # noqa: N802
        """处理预检请求。"""
        self.send_response(204)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Headers', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS')
        self.end_headers()

    def log_message(self, fmt: str, *args) -> None:
        """精简访问日志。

        :param fmt: 日志格式
        :param args: 格式参数
        """
        print('%s - %s' % (self.address_string(), fmt % args), flush=True)


def main() -> None:
    """启动预览服务。"""
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=8080)
    parser.add_argument('--api', type=str, default='http://127.0.0.1:9099')
    parser.add_argument('--root', type=str, default=os.path.join(os.path.dirname(__file__), 'web'))
    args = parser.parse_args()
    PreviewHandler.api_base = args.api
    os.chdir(args.root)
    server = ThreadingHTTPServer(('0.0.0.0', args.port), PreviewHandler)
    print('serving %s on http://0.0.0.0:%d -> %s' % (args.root, args.port, args.api), flush=True)
    server.serve_forever()


if __name__ == '__main__':
    main()
