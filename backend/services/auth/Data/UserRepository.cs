using Dapper;
using Npgsql;

namespace GeorgiaGuide.Auth.Data;

public record UserRow(long Id, string Email, string PasswordHash, string FullName, string AvatarUrl);

public class UserRepository
{
    private readonly string _connString;

    public UserRepository()
    {
        var host = Env("DB_HOST", "postgres");
        var port = Env("DB_PORT", "5432");
        var user = Env("DB_USER", "guide");
        var pass = Env("DB_PASSWORD", "guide");
        var name = Env("DB_NAME", "guide");
        _connString = $"Host={host};Port={port};Username={user};Password={pass};Database={name}";
    }

    private static string Env(string k, string d) =>
        Environment.GetEnvironmentVariable(k) is { Length: > 0 } v ? v : d;

    private NpgsqlConnection Conn() => new(_connString);

    public async Task<UserRow?> FindByEmail(string email)
    {
        await using var c = Conn();
        return await c.QueryFirstOrDefaultAsync<UserRow>(
            "SELECT id AS Id, email AS Email, password_hash AS PasswordHash, full_name AS FullName, avatar_url AS AvatarUrl FROM users WHERE email=@e",
            new { e = email });
    }

    public async Task<UserRow?> FindById(long id)
    {
        await using var c = Conn();
        return await c.QueryFirstOrDefaultAsync<UserRow>(
            "SELECT id AS Id, email AS Email, password_hash AS PasswordHash, full_name AS FullName, avatar_url AS AvatarUrl FROM users WHERE id=@id",
            new { id });
    }

    public async Task<long> Create(string email, string passwordHash, string fullName)
    {
        await using var c = Conn();
        return await c.ExecuteScalarAsync<long>(
            "INSERT INTO users (email, password_hash, full_name) VALUES (@e,@p,@f) RETURNING id",
            new { e = email, p = passwordHash, f = fullName });
    }

    public async Task UpdateProfile(long id, string fullName, string avatarUrl)
    {
        await using var c = Conn();
        await c.ExecuteAsync(
            "UPDATE users SET full_name=@f, avatar_url=@a WHERE id=@id",
            new { id, f = fullName, a = avatarUrl });
    }
}
