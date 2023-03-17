/// RTSP Headers
enum RTSPHeaders {
  cSeq('CSeq'),
  server('Server'),
  public('Public'),
  transport('Transport'),
  session('Session');

  final String name;

  const RTSPHeaders(this.name);
}