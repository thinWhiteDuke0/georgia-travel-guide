using Grpc.Core;
using GeorgiaGuide.Auth.Data;
using GeorgiaGuide.Auth.Protos;

namespace GeorgiaGuide.Auth.Services;

public class AuthGrpcService : AuthService.AuthServiceBase
{
    private readonly UserRepository _users;
    private readonly JwtService _jwt;

    public AuthGrpcService(UserRepository users, JwtService jwt)
    {
        _users = users;
        _jwt = jwt;
    }

    public override async Task<TokenResponse> Register(RegisterRequest req, ServerCallContext ctx)
    {
        if (string.IsNullOrWhiteSpace(req.Email) || req.Password.Length < 6)
            throw new RpcException(new Status(StatusCode.InvalidArgument, "email and 6+ char password required"));

        if (await _users.FindByEmail(req.Email) is not null)
            throw new RpcException(new Status(StatusCode.AlreadyExists, "email already registered"));

        var hash = BCrypt.Net.BCrypt.HashPassword(req.Password);
        var id = await _users.Create(req.Email, hash, req.FullName ?? "");
        return Tokens(id);
    }

    public override async Task<TokenResponse> Login(LoginRequest req, ServerCallContext ctx)
    {
        var user = await _users.FindByEmail(req.Email);
        if (user is null || !BCrypt.Net.BCrypt.Verify(req.Password, user.PasswordHash))
            throw new RpcException(new Status(StatusCode.Unauthenticated, "invalid credentials"));
        return Tokens(user.Id);
    }

    public override Task<TokenResponse> Refresh(RefreshRequest req, ServerCallContext ctx)
    {
        var id = _jwt.ValidateRefresh(req.RefreshToken);
        if (id is null)
            throw new RpcException(new Status(StatusCode.Unauthenticated, "invalid refresh token"));
        return Task.FromResult(Tokens(id.Value));
    }

    public override async Task<Profile> GetProfile(GetProfileRequest req, ServerCallContext ctx)
    {
        var u = await _users.FindById(req.UserId)
                ?? throw new RpcException(new Status(StatusCode.NotFound, "user not found"));
        return new Profile { Id = u.Id, Email = u.Email, FullName = u.FullName, AvatarUrl = u.AvatarUrl };
    }

    public override async Task<Profile> UpdateProfile(UpdateProfileRequest req, ServerCallContext ctx)
    {
        await _users.UpdateProfile(req.UserId, req.FullName ?? "", req.AvatarUrl ?? "");
        return await GetProfile(new GetProfileRequest { UserId = req.UserId }, ctx);
    }

    private TokenResponse Tokens(long userId) => new()
    {
        AccessToken = _jwt.CreateAccess(userId),
        RefreshToken = _jwt.CreateRefresh(userId),
        UserId = userId,
    };
}
