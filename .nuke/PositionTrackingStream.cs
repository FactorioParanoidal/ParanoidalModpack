using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

// Workaround for https://github.com/adamhathcock/sharpcompress/issues/1231
public class PositionTrackingStream(Stream baseStream) : Stream
{
    private readonly Stream _baseStream = baseStream ?? throw new ArgumentNullException(nameof(baseStream));
    private long _position;

    public override bool CanRead => _baseStream.CanRead;
    public override bool CanSeek => false;
    public override bool CanWrite => false;
    public override long Length => throw new NotSupportedException();
    
    // Возвращаем реальную позицию вместо NotSupportedException
    public override long Position 
    {
        get => _position;
        set => throw new NotSupportedException();
    }

    public override int Read(byte[] buffer, int offset, int count)
    {
        var read = _baseStream.Read(buffer, offset, count);
        if (read > 0) _position += read;
        return read;
    }

    public override int Read(Span<byte> buffer)
    {
        var read = _baseStream.Read(buffer);
        if (read > 0) _position += read;
        return read;
    }

    public override async Task<int> ReadAsync(byte[] buffer, int offset, int count, CancellationToken cancellationToken)
    {
        var read = await _baseStream.ReadAsync(buffer, offset, count, cancellationToken).ConfigureAwait(false);
        if (read > 0) _position += read;
        return read;
    }

    public override async ValueTask<int> ReadAsync(Memory<byte> buffer, CancellationToken cancellationToken = default)
    {
        var read = await _baseStream.ReadAsync(buffer, cancellationToken).ConfigureAwait(false);
        if (read > 0) _position += read;
        return read;
    }

    public override void Flush() => _baseStream.Flush();
    public override long Seek(long offset, SeekOrigin origin) => throw new NotSupportedException();
    public override void SetLength(long value) => throw new NotSupportedException();
    public override void Write(byte[] buffer, int offset, int count) => throw new NotSupportedException();

    protected override void Dispose(bool disposing)
    {
        if (disposing) _baseStream.Dispose();
        base.Dispose(disposing);
    }

    public override async ValueTask DisposeAsync()
    {
        await _baseStream.DisposeAsync().ConfigureAwait(false);
        await base.DisposeAsync().ConfigureAwait(false);
    }
}