/// RTSP Headers
enum RTSPHeaders {
  cSeq('CSeq'),
  server('Server'),
  public('Public'),
  session('Session');

  final String name;

  const RTSPHeaders(this.name);
}