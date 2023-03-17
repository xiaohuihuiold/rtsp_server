/// RTSP Headers
enum RTSPHeaders {
  cSeq('CSeq'),
  server('Server'),
  public('Public'),
  transport('Transport'),
  range('Range'),
  session('Session');

  final String name;

  const RTSPHeaders(this.name);
}