/// RTSP Headers
enum RTSPHeaders {
  cSeq('CSeq'),
  server('Server'),
  public('Public'),
  transport('Transport'),
  range('Range'),
  contentLength('Content-Length'),
  contentType('Content-Type'),
  contentBase('Content-Base'),
  rtpInfo('RTP-Info'),
  session('Session');

  final String name;

  const RTSPHeaders(this.name);
}
